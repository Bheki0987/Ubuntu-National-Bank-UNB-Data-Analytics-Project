-- Ubuntu National Bank (UNB)
-- Executive Analytics & Business Questions
-- Purpose: Answer executive-level questions using advanced SQL

USE unb_enterprise_data;

-- =====================================================
-- EXECUTIVE QUESTION 1
-- What is the month-on-month growth in transaction value?
-- =====================================================
SELECT
    yearmonth,
    total_transaction_value,
    total_transaction_value
      - LAG(total_transaction_value) OVER (ORDER BY yearmonth) AS mom_change_value
FROM (
    SELECT
        DATE_FORMAT(transaction_datetime, '%Y-%m') AS yearmonth,
        SUM(transaction_amount) AS total_transaction_value
    FROM transactions
    GROUP BY DATE_FORMAT(transaction_datetime, '%Y-%m')
) t
ORDER BY yearmonth;


-- =====================================================
-- EXECUTIVE QUESTION 2
-- Which customers generate the highest transaction value?
-- =====================================================
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(t.transaction_amount) AS total_transaction_value
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id
ORDER BY total_transaction_value DESC
LIMIT 10;

-- =====================================================
-- EXECUTIVE QUESTION 3
-- What percentage of accounts are dormant?
-- =====================================================
SELECT 
    ROUND(
        SUM(CASE WHEN ash.status_code = 'DORMANT' AND ash.status_end_date IS NULL THEN 1 ELSE 0 END) * 100.0
        / COUNT(DISTINCT a.account_id), 2
    ) AS dormant_account_percentage
FROM accounts a
JOIN account_status_history ash ON a.account_id = ash.account_id;

-- =====================================================
-- EXECUTIVE QUESTION 4
-- Which branches contribute the most net transaction value?
-- =====================================================
SELECT 
    b.branch_name,
    SUM(CASE 
        WHEN t.transaction_direction = 'CREDIT' THEN t.transaction_amount
        WHEN t.transaction_direction = 'DEBIT' THEN -t.transaction_amount
        ELSE 0 END) AS net_transaction_value
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY b.branch_name
ORDER BY net_transaction_value DESC;

-- =====================================================
-- EXECUTIVE QUESTION 5
-- What is the bank’s total outstanding loan exposure?
-- =====================================================
SELECT 
    SUM(outstanding_balance) AS total_outstanding_exposure
FROM vw_loan_exposure;

-- =====================================================
-- EXECUTIVE QUESTION 6
-- Identify customers with multiple products (cross-sell potential)
-- =====================================================
SELECT 
    customer_id,
    total_accounts,
    total_loans
FROM vw_customer_360
WHERE total_accounts >= 2 OR total_loans >= 1
ORDER BY total_accounts DESC, total_loans DESC;

-- =====================================================
-- EXECUTIVE QUESTION 7
-- Detect abnormal transaction spikes (risk monitoring)
-- =====================================================
SELECT
    transaction_date,
    transaction_volume,
    total_transaction_value,
    (SELECT AVG(transaction_volume) FROM vw_daily_transaction_summary) AS avg_volume
FROM vw_daily_transaction_summary
WHERE transaction_volume >
      (SELECT AVG(transaction_volume) FROM vw_daily_transaction_summary);


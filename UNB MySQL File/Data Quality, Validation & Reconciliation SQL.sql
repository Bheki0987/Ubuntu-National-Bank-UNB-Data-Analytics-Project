-- Ubuntu National Bank (UNB)
-- Data Quality, Validation & Reconciliation SQL
-- Objective: Ensure data accuracy, integrity, and financial reconciliation

USE unb_enterprise_data;

-- =============================================
-- 1. REFERENTIAL INTEGRITY CHECKS
-- =============================================

-- 1.1 Accounts without valid customers 
SELECT a.account_id, a.customer_id
FROM accounts a
LEFT JOIN customers c ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 1.2 Transactions linked to non-existent accounts
SELECT t.transaction_id, t.account_id
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

-- 1.3 Loans without valid customers
SELECT l.loan_id, l.customer_id
FROM loans l
LEFT JOIN customers c ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- =============================================
-- 2. ACCOUNT STATUS VALIDATION
-- =============================================

-- 2.1 Accounts with no status history (data governance issue)
SELECT a.account_id
FROM accounts a
LEFT JOIN account_status_history ash ON a.account_id = ash.account_id
WHERE ash.account_id IS NULL;

-- 2.2 Accounts with overlapping status periods (critical error)
SELECT ash1.account_id, ash1.status_start_date, ash1.status_end_date
FROM account_status_history ash1
JOIN account_status_history ash2
  ON ash1.account_id = ash2.account_id
 AND ash1.account_status_id <> ash2.account_status_id
WHERE ash1.status_start_date <= IFNULL(ash2.status_end_date, '9999-12-31')
  AND IFNULL(ash1.status_end_date, '9999-12-31') >= ash2.status_start_date;

-- =============================================
-- 3. TRANSACTION CONSISTENCY CHECKS
-- =============================================

-- 3.1 Negative transaction amounts (not allowed)
SELECT transaction_id, transaction_amount
FROM transactions
WHERE transaction_amount <= 0;

-- 3.2 Invalid transaction direction logic
SELECT transaction_id, transaction_amount, transaction_direction
FROM transactions
WHERE transaction_direction NOT IN ('CREDIT', 'DEBIT');

-- =============================================
-- 4. ACCOUNT BALANCE RECONCILIATION (DERIVED)
-- =============================================

-- 4.1 Derived account balances from transaction history
SELECT 
    a.account_id,
    SUM(CASE 
        WHEN t.transaction_direction = 'CREDIT' THEN t.transaction_amount
        WHEN t.transaction_direction = 'DEBIT' THEN -t.transaction_amount
        ELSE 0 END) AS derived_balance
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id;

-- 4.2 Accounts with activity but zero derived balance (risk flag)
SELECT account_id, derived_balance
FROM (
    SELECT 
        a.account_id,
        SUM(CASE 
            WHEN t.transaction_direction = 'CREDIT' THEN t.transaction_amount
            WHEN t.transaction_direction = 'DEBIT' THEN -t.transaction_amount
            ELSE 0 END) AS derived_balance
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    GROUP BY a.account_id
) balances
WHERE derived_balance = 0;

-- =============================================
-- 5. LOAN DATA RECONCILIATION
-- =============================================

-- 5.1 Loans without repayment schedules (policy violation)
SELECT l.loan_id
FROM loans l
LEFT JOIN loan_repayment_schedule rs ON l.loan_id = rs.loan_id
WHERE rs.loan_id IS NULL;

-- 5.2 Total scheduled vs total paid amounts per loan
SELECT 
    l.loan_id,
    SUM(rs.scheduled_amount) AS total_scheduled,
    IFNULL(SUM(lp.amount_paid), 0) AS total_paid,
    SUM(rs.scheduled_amount) - IFNULL(SUM(lp.amount_paid), 0) AS outstanding_amount
FROM loans l
LEFT JOIN loan_repayment_schedule rs ON l.loan_id = rs.loan_id
LEFT JOIN loan_payments lp ON l.loan_id = lp.loan_id
GROUP BY l.loan_id;

-- 5.3 Loans overpaid (critical financial exception)
SELECT loan_id, outstanding_amount
FROM (
    SELECT 
        l.loan_id,
        SUM(rs.scheduled_amount) - IFNULL(SUM(lp.amount_paid), 0) AS outstanding_amount
    FROM loans l
    LEFT JOIN loan_repayment_schedule rs ON l.loan_id = rs.loan_id
    LEFT JOIN loan_payments lp ON l.loan_id = lp.loan_id
    GROUP BY l.loan_id
) loan_check
WHERE outstanding_amount < 0;

-- =============================================
-- 6. CUSTOMER DATA QUALITY CHECKS
-- =============================================

-- 6.1 Duplicate national IDs (identity risk)
SELECT national_id, COUNT(*) AS occurrence_count
FROM customers
GROUP BY national_id
HAVING COUNT(*) > 1;

-- 6.2 Customers marked INACTIVE but holding active accounts
SELECT c.customer_id, c.customer_status
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN account_status_history ash ON a.account_id = ash.account_id
WHERE c.customer_status = 'INACTIVE'
  AND ash.status_code = 'ACTIVE'
  AND ash.status_end_date IS NULL;

-- =============================================
-- 7. OPERATIONAL MONITORING QUERIES
-- =============================================

-- 7.1 Daily transaction volumes (fraud & ops monitoring)
SELECT DATE(transaction_datetime) AS transaction_date,
       COUNT(*) AS transaction_count,
       SUM(transaction_amount) AS total_value
FROM transactions
GROUP BY DATE(transaction_datetime)
ORDER BY transaction_date DESC;

-- 7.2 High-value transactions (manual review threshold)
SELECT transaction_id, account_id, transaction_amount
FROM transactions
WHERE transaction_amount >= 100000;

-- END OF DELIVERABLE 6

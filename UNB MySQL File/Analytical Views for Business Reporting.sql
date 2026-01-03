-- Ubuntu National Bank (UNB)
-- Analytical Views for Business Reporting
-- Purpose: Create business-ready analytical layers for dashboards & decision-making

USE unb_enterprise_data;

-- =====================================================
-- 1. CUSTOMER 360 ANALYTICAL VIEW
-- =====================================================
CREATE OR REPLACE VIEW vw_customer_360 AS
SELECT 
    c.customer_id,
    c.national_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_status,
    c.customer_created_date,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT l.loan_id) AS total_loans
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
GROUP BY c.customer_id;

-- =====================================================
-- 2. ACCOUNT PERFORMANCE VIEW (BALANCE DERIVED)
-- =====================================================
CREATE OR REPLACE VIEW vw_account_performance AS
SELECT 
    a.account_id,
    a.account_number,
    a.account_type,
    a.branch_id,
    SUM(CASE 
        WHEN t.transaction_direction = 'CREDIT' THEN t.transaction_amount
        WHEN t.transaction_direction = 'DEBIT' THEN -t.transaction_amount
        ELSE 0 END) AS current_balance,
    COUNT(t.transaction_id) AS transaction_count,
    MAX(t.transaction_datetime) AS last_transaction_date
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id;

-- =====================================================
-- 3. DAILY TRANSACTION FACT VIEW
-- =====================================================
CREATE OR REPLACE VIEW vw_daily_transaction_summary AS
SELECT 
    DATE(transaction_datetime) AS transaction_date,
    COUNT(*) AS transaction_volume,
    SUM(transaction_amount) AS total_transaction_value
FROM transactions
GROUP BY DATE(transaction_datetime);

-- =====================================================
-- 4. LOAN RISK & EXPOSURE VIEW
-- =====================================================
CREATE OR REPLACE VIEW vw_loan_exposure AS
SELECT 
    l.loan_id,
    l.customer_id,
    l.loan_type,
    l.principal_amount,
    SUM(rs.scheduled_amount) AS total_scheduled_amount,
    IFNULL(SUM(lp.amount_paid), 0) AS total_paid_amount,
    SUM(rs.scheduled_amount) - IFNULL(SUM(lp.amount_paid), 0) AS outstanding_balance
FROM loans l
LEFT JOIN loan_repayment_schedule rs ON l.loan_id = rs.loan_id
LEFT JOIN loan_payments lp ON l.loan_id = lp.loan_id
GROUP BY l.loan_id;

-- =====================================================
-- 5. BRANCH PERFORMANCE VIEW
-- =====================================================
CREATE OR REPLACE VIEW vw_branch_performance AS
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(CASE 
        WHEN t.transaction_direction = 'CREDIT' THEN t.transaction_amount
        WHEN t.transaction_direction = 'DEBIT' THEN -t.transaction_amount
        ELSE 0 END) AS net_transaction_value
FROM branches b
LEFT JOIN accounts a ON b.branch_id = a.branch_id
LEFT JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY b.branch_id;

-- END OF DELIVERABLE 7

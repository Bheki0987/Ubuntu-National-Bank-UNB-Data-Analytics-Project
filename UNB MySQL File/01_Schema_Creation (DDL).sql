-- Ubuntu National Bank (UNB)
-- Physical MySQL Schema (DDL)

-- ================================
-- 1. DATABASE INITIALISATION
-- ================================
CREATE DATABASE IF NOT EXISTS unb_enterprise_data;
USE unb_enterprise_data;

-- ================================
-- 2. MASTER DATA TABLES
-- ================================

-- CUSTOMER
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    customer_status ENUM('ACTIVE','INACTIVE','DECEASED') NOT NULL,
    customer_created_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- CUSTOMER ADDRESS (HISTORICAL)
CREATE TABLE customer_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('RESIDENTIAL','POSTAL') NOT NULL,
    city VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    CONSTRAINT fk_address_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- BRANCH
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    branch_open_date DATE NOT NULL
) ENGINE=InnoDB;

-- EMPLOYEE
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    employee_role VARCHAR(50) NOT NULL,
    employment_start_date DATE NOT NULL,
    CONSTRAINT fk_employee_branch FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
) ENGINE=InnoDB;

-- ================================
-- 3. ACCOUNT & TRANSACTION TABLES
-- ================================

-- ACCOUNT
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type ENUM('SAVINGS','CURRENT','FIXED') NOT NULL,
    account_open_date DATE NOT NULL,
    account_close_date DATE,
    CONSTRAINT fk_account_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT fk_account_branch FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
) ENGINE=InnoDB;

-- ACCOUNT STATUS HISTORY
CREATE TABLE account_status_history (
    account_status_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    status_code ENUM('ACTIVE','DORMANT','CLOSED') NOT NULL,
    status_start_date DATE NOT NULL,
    status_end_date DATE,
    CONSTRAINT fk_status_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- TRANSACTION TYPE
CREATE TABLE transaction_types (
    transaction_type_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_code VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- TRANSACTION (IMMUTABLE)
CREATE TABLE transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type_id INT NOT NULL,
    transaction_datetime DATETIME NOT NULL,
    transaction_amount DECIMAL(12,2) NOT NULL,
    transaction_direction ENUM('CREDIT','DEBIT') NOT NULL,
    CONSTRAINT fk_transaction_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id),
    CONSTRAINT fk_transaction_type FOREIGN KEY (transaction_type_id)
        REFERENCES transaction_types(transaction_type_id)
) ENGINE=InnoDB;

-- ================================
-- 4. LOANS & CREDIT TABLES
-- ================================

-- LOAN
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_type ENUM('PERSONAL','HOME','SME') NOT NULL,
    principal_amount DECIMAL(14,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    loan_start_date DATE NOT NULL,
    loan_end_date DATE NOT NULL,
    CONSTRAINT fk_loan_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- LOAN REPAYMENT SCHEDULE
CREATE TABLE loan_repayment_schedule (
    repayment_schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    scheduled_payment_date DATE NOT NULL,
    scheduled_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_schedule_loan FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
) ENGINE=InnoDB;

-- LOAN PAYMENT (IMMUTABLE)
CREATE TABLE loan_payments (
    loan_payment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_payment_loan FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
) ENGINE=InnoDB;

-- ================================
-- 5. AUDIT & GOVERNANCE
-- ================================

-- AUDIT LOG
CREATE TABLE audit_log (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    action_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    action_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- ================================
-- 6. PERFORMANCE INDEXES
-- ================================
CREATE INDEX idx_account_customer ON accounts(customer_id);
CREATE INDEX idx_transaction_account ON transactions(account_id);
CREATE INDEX idx_transaction_datetime ON transactions(transaction_datetime);
CREATE INDEX idx_loan_customer ON loans(customer_id);



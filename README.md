# 🏦 Ubuntu National Bank (UNB) — Banking Data Analytics Project

![MySQL](https://img.shields.io/badge/Database-MySQL-blue?style=for-the-badge&logo=mysql)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Domain](https://img.shields.io/badge/Domain-Banking%20%26%20Finance-orange?style=for-the-badge)

## 📌 Project Overview

This repository hosts an end-to-end, real-world simulated banking data analytics project built using **MySQL**. It represents the data environment of a fictional financial institution, **Ubuntu National Bank (UNB)**.

This repository demonstrates the **full data lifecycle**—from business requirement gathering and conceptual modeling to data quality assurance, reconciliation, and executive analytics. It is designed to mirror the actual workflows of Data Analysts and Database Analysts in the financial sector.

---

## 📖 Table of Contents
1. [Business Context](#-business-context)
2. [Project Philosophy & Design](#-project-philosophy--design)
3. [Data Architecture](#-data-architecture)
4. [Technical Capabilities](#-technical-capabilities)
5. [Repository Structure](#-repository-structure)
6. [How to Run](#-how-to-run)
7. [Author](#-author)

---

## 🏦 Business Context

**Ubuntu National Bank (UNB)** is a fictional retail and commercial bank operating across multiple branches. The project models core banking functions including:

* **Customer Management:** KYC data, demographic segmentation, and relationship history.
* **Account Operations:** Savings, Cheque, and Credit account lifecycles.
* **Transaction Processing:** High-volume credits/debits, inter-branch transfers, and fees.
* **Lending:** Loan origination, repayment tracking, and exposure analysis.
* **Audit & Governance:** Staff activity logging and operational reconciliation.

### 🎯 Key Business Objectives
The analytics suite in this project solves specific business problems:
* **Customer 360:** Consolidating customer data for personalized service.
* **Risk Management:** Monitoring loan exposure and outstanding balances.
* **Operational Efficiency:** Evaluating branch-level performance and transaction volumes.

---

## 💡 Project Philosophy & Design

This project adheres to **banking data best practices**:

> **"Balances are derived, not stored."**

* **Immutable Transaction Modeling:** No data is overwritten. Balances are calculated dynamically from transaction history to ensure auditability.
* **Separation of Duties:** Distinct handling of transactional data (OLTP concepts) and master data.
* **Historical Tracking:** Implementation of logic to track status changes over time.
* **Reconciliation First:** Includes specific SQL scripts to validate that `Sum(Transactions) = Ending Balance`, ensuring data integrity before reporting.

---

## 🏗 Data Architecture
![Insert Entity Relationship Diagram Here](ERD-For-Ubuntu-National-Bank.png)

The database schema includes normalized tables designed for high referential integrity.

* **Conceptual Data Model:** High-level entity relationships.
* **Logical & Physical Models:** Detailed schema designs including constraints, primary/foreign keys, and indexes.

---

## 🛠 Technical Capabilities

### 💻 Tech Stack
* **Database:** MySQL
* **Tools:** MySQL Workbench

### 📊 SQL Skills Demonstrated
* **Advanced DDL:** Table creation with strict constraints and indexing strategies.
* **Complex DML:** Window functions (`RANK`, `LEAD`, `LAG`) for time-series analysis.
* **Data Quality:** Scripting for duplicate detection, null handling, and orphan record identification.
* **Reconciliation Logic:** Automated checks to verify ledger accuracy.
* **Reporting Views:** Creating abstraction layers for Executive KPIs and decision support.

---

## 📂 Repository Structure

```text
Ubuntu-National-Bank-UNB-Data-Analytics-Project/
├── 1️⃣ UNB Documentation/
│
├── 2️⃣ UNB MySQL File/
│
├── 3️⃣ UNB MySQL Screenshots/
│
├── LICENSE
└── README.md
```

## 🚀 How to Run
*1. Clone the Repository*
```
Bash

git clone https://github.com/Bheki0987/Ubuntu-National-Bank-UNB-Data-Analytics-Project.git
```
*2. Initialize Database*
  - Open your MySQL client (Workbench/DBeaver).
  - Execute the scripts in 2️⃣ UNB MySQL File/ in numeric order (01 -> 04).

*3. Run Analytics*
  - Execute the 04_Analytical_Views.sql to generate report tables.
  - Run specific KPI queries to see the "Customer 360" or "Branch Performance" reports.

## 👤 Author
Bheki Mogola
Data Analyst | Business Analyst | Database Analyst 

[LinkedIn](https://www.linkedin.com/in/bheki-mogola/)

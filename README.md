# Retail Sales Analytics System (SQL Project)

A beginner-friendly SQL Server project created to demonstrate **core SQL concepts** commonly required for **Data Analyst / Business Analyst (Fresher)** roles.

This project focuses on **clean database design**, **practical analytical queries**, and **real business-style questions**, without unnecessary complexity.

---

## 📦 Database Design

The project uses a **normalized retail database** with 4 tables:

- **Customers** – customer details (name, city, email)
- **Products** – product catalog with category and price
- **Orders** – order header information
- **Order_Items** – line-level order transactions

### Design Highlights
- Primary Keys & Foreign Keys
- Basic constraints (NOT NULL, CHECK)
- One-to-many relationships
- Realistic retail schema used in interviews

---

## 📊 SQL Skills Demonstrated

### ✔ Core SQL
- `SELECT`, `WHERE`, `GROUP BY`, `HAVING`
- `ORDER BY`
- Aggregate functions (`SUM`, `AVG`, `COUNT`)

### ✔ Joins
- `INNER JOIN`
- `LEFT JOIN`
- Multi-table joins (4-table queries)

### ✔ Subqueries
- Orders above average value
- Nested aggregations

### ✔ Window Functions (SQL Server)
- `RANK()` for customer ranking
- `ROW_NUMBER()` to find highest-value order per customer

### ✔ Conditional Logic
- `CASE WHEN` for customer segmentation

### ✔ EXISTS
- Customer purchase behavior analysis

### ✔ Views
- Reusable customer sales summary view

### ✔ CTAS (Create Table As Select)
- High-value orders table for reporting

---

## 📈 Business Questions Answered

- What is the total value of each order?
- Who are the top-spending customers?
- Which products and categories generate the most revenue?
- How does revenue vary by customer city?
- What are monthly revenue trends?
- Which customers place repeat or high-value orders?
- Which products or customers are inactive?

All queries are written with **business understanding**, not just syntax.

---

---

## 📊 Tableau Integration

For visualization purposes, a **flat (denormalized) dataset** is prepared using SQL joins.
This dataset is specifically created for Tableau reporting to simplify analysis and
avoid complex joins inside Tableau.

The flat-table SQL query used for Tableau is included in the project as:
**Part 8: Flat Table for Tableau Reporting**.

This approach reflects common BI practice where:
- SQL is used for data preparation
- Tableau is used for visualization

## 🗂 Project Structure

| File | Description |
|------|------------|
| `retail_project.sql` | Table creation, sample data, analytical queries |
| `README.md` | Project explanation |

---

## 🛠 Tools Used

- **SQL Server** (syntax aligned)
- **DB-Fiddle / GitHub** for hosting queries
- **Tableau Public** (basic dashboard for visualization)

> Note: This project is intentionally kept **simple and clear**, suitable for a fresher-level role.

---

## 🚀 How to Run

1. Open SQL Server / DB-Fiddle (SQL Server mode)
2. Run table creation scripts
3. Insert sample data
4. Execute analytical queries section-wise

---

## 👤 Author

**Ganesh J**  
Aspiring Data Analyst (Fresher)  
Skills: SQL Server, Excel, Tableau (Basics)

---

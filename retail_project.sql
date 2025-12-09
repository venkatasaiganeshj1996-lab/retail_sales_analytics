-- ==========================================
-- RETAIL SALES ANALYTICS SYSTEM (SQL PROJECT)
-- ==========================================
-- Author: Ganesh
-- Description: 4-table retail database + analysis queries
-- ==========================================

------------------------------------------------
-- PART 1: TABLES (CUSTOMERS, PRODUCTS, ORDERS)
------------------------------------------------

-- 1) Customers table: basic customer info
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE
);

-- 2) Products table: catalog of products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) CHECK (price > 0)
);

-- 3) Orders table: one row per order
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4) Order items table: line items inside each order
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

------------------------------------------------
-- PART 2: SAMPLE DATA
------------------------------------------------

-- Insert customers
INSERT INTO customers VALUES
(1, 'Asha', 'Delhi', 'asha@mail.com'),
(2, 'Ravi', 'Mumbai', 'ravi@mail.com'),
(3, 'Meena', 'Chennai', 'meena@mail.com');

-- Insert products
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000),
(102, 'Headphones', 'Electronics', 2000),
(103, 'Office Chair', 'Furniture', 7000);

-- Insert orders (header level)
INSERT INTO orders VALUES
(1001, 1, '2025-01-10'),
(1002, 2, '2025-01-12'),
(1003, 1, '2025-01-15');

-- Insert order line items
INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 2),
(3, 1002, 103, 1),
(4, 1003, 101, 1),
(5, 1003, 102, 1);

------------------------------------------------
-- PART 3: ANALYTICAL QUERIES
------------------------------------------------

-- Query 1: Total sales per order
-- Business use: find value of each order
SELECT o.order_id,
       SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;

-- Query 2: Total spend per customer
-- Business use: identify top customers by revenue
SELECT c.name,
       SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name;

-- Query 3: Top-selling products (by units sold)
SELECT p.product_name,
       SUM(oi.quantity) AS total_units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC;

-- Query 4: Monthly revenue using CTE
-- Note: MONTH(order_date) works in many SQL dialects; 
-- in some DBs you may need EXTRACT(MONTH FROM order_date)
WITH monthly_sales AS (
    SELECT 
        MONTH(order_date) AS month,
        SUM(oi.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY MONTH(order_date)
)
SELECT * FROM monthly_sales;

-- Query 5: Customer ranking by total spending (Window Function)
SELECT c.name,
       SUM(oi.quantity * p.price) AS total_spent,
       RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name;

-- Query 6: Highest value order for each customer
-- Uses ROW_NUMBER window function
SELECT customer_id, order_id, order_total
FROM (
    SELECT 
        o.customer_id, 
        o.order_id,
        SUM(oi.quantity * p.price) AS order_total,
        ROW_NUMBER() OVER(
            PARTITION BY o.customer_id 
            ORDER BY SUM(oi.quantity * p.price) DESC
        ) AS rn
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.customer_id, o.order_id
) t
WHERE rn = 1;

------------------------------------------------
-- PART 4: VIEW (REUSABLE CUSTOMER SUMMARY)
------------------------------------------------

-- View: customer_sales_summary
-- Business use: quick view of spend by city & customer
CREATE VIEW customer_sales_summary AS
SELECT 
    c.name, 
    c.city,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.name, c.city;

------------------------------------------------
-- PART 5: STORED PROCEDURE (LOGICAL EXAMPLE)
------------------------------------------------

-- NOTE:
-- Stored procedure syntax changes depending on database (MySQL / SQL Server / PostgreSQL).
-- This is a SQL Server–style example for interviews.
-- In some online tools you may need to adjust syntax.

-- Example stored procedure to get all orders for one customer
-- and their total order value.
-- (SQL Server style)
CREATE PROCEDURE GetCustomerOrders @customer_id INT
AS
BEGIN
    SELECT 
        o.order_id, 
        o.order_date,
        SUM(oi.quantity * p.price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.customer_id = @customer_id
    GROUP BY o.order_id, o.order_date;
END;

------------------------------------------------
-- PART 6: HIGH VALUE ORDERS TABLE (CTAS STYLE)
------------------------------------------------

-- Create a physical table with only high value orders
-- (order_total > 50000)
-- Note: exact CTAS syntax may vary by database.
CREATE TABLE high_value_orders AS
SELECT 
    o.order_id,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * p.price) > 50000;

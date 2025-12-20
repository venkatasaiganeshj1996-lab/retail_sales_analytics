-- ==========================================
-- RETAIL SALES ANALYTICS SYSTEM (SQL PROJECT)
-- ==========================================
-- Author: Ganesh
-- Tech Stack: SQL Server
-- Description:
-- A beginner-friendly retail analytics database
-- demonstrating core SQL concepts used in real business scenarios.
-- ==========================================

/* ==========================================
   PART 1: TABLE CREATION
   ========================================== */

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) CHECK (price > 0)
);

-- Orders table (order header)
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items table (order details)
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);




/* ==========================================
   PART 2: SAMPLE DATA INSERTION
   ========================================== */

-- Customers
INSERT INTO customers VALUES
(1, 'Asha', 'Delhi', 'asha@mail.com'),
(2, 'Ravi', 'Mumbai', 'ravi@mail.com'),
(3, 'Meena', 'Chennai', 'meena@mail.com');

-- Products
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000),
(102, 'Headphones', 'Electronics', 2000),
(103, 'Office Chair', 'Furniture', 7000);

-- Orders
INSERT INTO orders VALUES
(1001, 1, '2025-01-10'),
(1002, 2, '2025-01-12'),
(1003, 1, '2025-01-15');

-- Order Items
INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 2),
(3, 1002, 103, 1),
(4, 1003, 101, 1),
(5, 1003, 102, 1);




/* ==========================================
   PART 3: CORE ANALYTICAL QUERIES
   ========================================== */

-- Q1: Total sales per order
-- Business use: calculate order value
SELECT
    o.order_id,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id;


-- Q2: Total spending per customer
-- Business use: identify high-value customers
SELECT
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- Q3: Top-selling products (by quantity)
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;


-- Q4: Revenue by product category
SELECT
    p.category,
    SUM(oi.quantity * p.price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- Q5: Revenue by customer city
SELECT
    c.city,
    SUM(oi.quantity * p.price) AS city_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY city_revenue DESC;


-- Q6: Monthly revenue (SQL Server style)
SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY order_year, order_month;




/* ==========================================
   PART 4: WINDOW FUNCTIONS
   ========================================== */

-- Q7: Rank customers by total spending
SELECT
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spent,
    RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name;


-- Q8: Highest value order per customer
SELECT customer_id, order_id, order_total
FROM (
    SELECT
        o.customer_id,
        o.order_id,
        SUM(oi.quantity * p.price) AS order_total,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY SUM(oi.quantity * p.price) DESC
        ) AS rn
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.customer_id, o.order_id
) t
WHERE rn = 1;




/* ==========================================
   PART 5: INTERVIEW-SAFE ADVANCED QUERIES
   ========================================== */

-- Q9: Customers with NO orders (LEFT JOIN)
SELECT
    c.customer_id,
    c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q10: Products never sold
SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- Q11: Orders above average order value (Subquery)
SELECT
    o.order_id,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * p.price) >
(
    SELECT AVG(order_value)
    FROM (
        SELECT SUM(oi.quantity * p.price) AS order_value
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        GROUP BY o.order_id
    ) t
);


-- Q12: Customer segmentation using CASE
SELECT
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spent,
    CASE
        WHEN SUM(oi.quantity * p.price) > 50000 THEN 'High Value'
        WHEN SUM(oi.quantity * p.price) BETWEEN 20000 AND 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name;


-- Q13: Customers who bought Electronics (EXISTS)
SELECT
    c.customer_id,
    c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
      AND p.category = 'Electronics'
);




/* ==========================================
   PART 6: VIEW
   ========================================== */

-- Customer sales summary view
CREATE VIEW customer_sales_summary AS
SELECT
    c.customer_id,
    c.name,
    c.city,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name, c.city;




/* ==========================================
   PART 7: HIGH VALUE ORDERS TABLE
   ========================================== */

-- High value orders (for reporting)
CREATE TABLE high_value_orders AS
SELECT
    o.order_id,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * p.price) > 50000;

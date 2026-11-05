-- create a new database
create database Grocery_Store_Management;

-- whenever you want to perform any query on this DB 
use Grocery_Store_Management;

-- create each and every table with the relationship 

-- 1.supplier table
CREATE TABLE IF NOT EXISTS supplier (
    sup_id TINYINT PRIMARY KEY,
    sup_name VARCHAR(255),
    address TEXT
);

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    cat_id TINYINT PRIMARY KEY,
    cat_name VARCHAR(255)
);

-- 3. Employees Table
CREATE TABLE IF NOT EXISTS employees (
    emp_id TINYINT PRIMARY KEY,
    emp_name VARCHAR(255),
    hire_date VARCHAR(255)
);

-- 4. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    cust_id SMALLINT PRIMARY KEY,
    cust_name VARCHAR(255),
    address TEXT
);

-- 5. Products Table
CREATE TABLE IF NOT EXISTS products (
    prod_id TINYINT PRIMARY KEY,
    prod_name VARCHAR(255),
    sup_id TINYINT,
    cat_id TINYINT,
    price DECIMAL(10,2),
    FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    ord_id SMALLINT PRIMARY KEY,
    cust_id SMALLINT,
    emp_id TINYINT,
    order_date VARCHAR(255),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. Order_Details Table
CREATE TABLE IF NOT EXISTS order_details (
    ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    prod_id TINYINT,
    quantity TINYINT,
    each_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
 --  ********** additional tables for future use  ***********
 -- 8. User Type table
  -- Defines types of users in the system.
CREATE TABLE user_type (
    user_type_id TINYINT AUTO_INCREMENT PRIMARY KEY,
    user_type_name VARCHAR(50) NOT NULL
);

-- Insert default user types
INSERT INTO user_type (user_type_name) VALUES 
('Admin'),
('Employee'),
('Customer'),
('Supplier');

-- 9. Sales table
-- Stores finalized sale transactions.
CREATE TABLE sales (
    sale_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    cust_id SMALLINT,
    emp_id TINYINT,
    sale_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- 10. Payment table
-- Stores payment info for each sale.
CREATE TABLE payment (
    payment_id SMALLINT AUTO_INCREMENT PRIMARY KEY,
    sale_id SMALLINT,
    payment_date DATE,
    payment_method VARCHAR(50),
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(50),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);


-- import csv file steps
-- step1:- create all the tables with relationship
-- step2:-select the DB, expand the table section, on which table you want to import csv file. 
-- step3:-Click on table -> right click on table --> choose data import wizrd  -> browser -> select file -> next -> load
-- step3(a):-import data into table in order of --> employees,categories,customers,suppliers, products, orders , ordersdetails
-- step4:- check while import rows count will get it, otherwise it has error or Zero(0)rows 
-- step5:- if you feel any issue in step4 start again form step1

-- ******* Create EER Diagram **********
-- Database(chekc in top panel) -> Reverse Engimeer -> next -> enter password of mysql -> next -> select your current DB name ->
-- next(until get fininsh) -> finish 
-- if we want to connnect table manually-> select the table -> right click on it -> and make changes like foreign key 
-- to save as .mwb file --> top panel file -> save model 

-- ****** future implementation ******
--   a) Manage products
--   b) Stored all the data
--   c) Manage customer
--   d) Monitor the number of customer


-- *********  Data analyst begins ******


-- ########### 1 Customer Insights ##########
-- AIM:- Gain an understanding of customer engagement and purchasing behavior.

-- How many unique customers have placed orders?
SELECT COUNT(DISTINCT cust_id) AS unique_customers
FROM orders;

-- Which customers have placed the highest number of orders?
SELECT c.cust_id, 
       c.cust_name, 
       COUNT(o.ord_id) AS total_orders
FROM customers c
JOIN orders o 
  ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_orders DESC
LIMIT 1;

-- What is the total and average purchase value per customer?
SELECT 
    c.cust_id,
    c.cust_name,
    SUM(od.total_price) AS total_purchase_value,
    AVG(od.total_price) AS avg_purchase_value
FROM customers c
JOIN orders o 
    ON c.cust_id = o.cust_id
JOIN order_details od 
    ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_purchase_value DESC;

-- Who are the top 5 customers by total purchase amount?
SELECT 
    c.cust_id,
    c.cust_name,
    SUM(od.total_price) AS total_purchase_value
FROM customers c
JOIN orders o 
    ON c.cust_id = o.cust_id
JOIN order_details od 
    ON o.ord_id = od.ord_id
GROUP BY c.cust_id, c.cust_name
ORDER BY total_purchase_value DESC
LIMIT 5;

-- ########### 2. Product Performance ###########
-- AIM:-Evaluate how well products are performing in terms of sales and revenue.

-- How many products exist in each category?
SELECT 
    c.cat_id,
    c.cat_name,
    COUNT(p.prod_id) AS total_products
FROM categories c
LEFT JOIN products p 
    ON c.cat_id = p.cat_id
GROUP BY c.cat_id, c.cat_name
ORDER BY total_products DESC;

-- What is the average price of products by category?
SELECT 
    c.cat_id,
    c.cat_name,
    AVG(p.price) AS avg_price
FROM categories c
JOIN products p 
    ON c.cat_id = p.cat_id
GROUP BY c.cat_id, c.cat_name
ORDER BY avg_price DESC;

-- Which products have the highest total sales volume (by quantity)?
SELECT 
    p.prod_id,
    p.prod_name,
    SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od 
    ON p.prod_id = od.prod_id
GROUP BY p.prod_id, p.prod_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- What is the total revenue generated by each product?
SELECT 
    p.prod_id,
    p.prod_name,
    SUM(od.total_price) AS total_revenue
FROM products p
JOIN order_details od 
    ON p.prod_id = od.prod_id
GROUP BY p.prod_id, p.prod_name
ORDER BY total_revenue DESC;

-- How do product sales vary by category and supplier?
SELECT 
    c.cat_name AS category,
    s.sup_name AS supplier,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.total_price) AS total_revenue
FROM order_details od
JOIN products p 
    ON od.prod_id = p.prod_id
JOIN categories c 
    ON p.cat_id = c.cat_id
JOIN supplier s 
    ON p.sup_id = s.sup_id
GROUP BY c.cat_name, s.sup_name
ORDER BY c.cat_name, total_revenue DESC;

-- ########### 3. Sales and Order Trends ###########
-- AIM:-Analyze business performance through orders and revenue over time.

-- How many orders have been placed in total?
SELECT COUNT(*) AS total_orders
FROM orders;

-- What is the average value per order?
SELECT 
    AVG(order_total) AS avg_order_value
FROM (
    SELECT 
        ord_id,
        SUM(total_price) AS order_total
    FROM order_details
    GROUP BY ord_id
) AS order_summary;

-- On which dates were the most orders placed?
SELECT 
    order_date,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_date
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM orders
        GROUP BY order_date
    ) AS subquery
);

-- What are the monthly trends in order volume and revenue?
SELECT 
    DATE_FORMAT(STR_TO_DATE(o.order_date, '%d/%m/%Y'), '%Y-%m') AS month,
    COUNT(DISTINCT o.ord_id) AS total_orders,
    SUM(od.total_price) AS total_revenue
FROM orders o
JOIN order_details od 
    ON o.ord_id = od.ord_id
GROUP BY DATE_FORMAT(STR_TO_DATE(o.order_date, '%d/%m/%Y'), '%Y-%m')
ORDER BY month;

-- How do order patterns vary across weekdays and weekends?
   -- order by day of week
SELECT 
    DAYNAME(STR_TO_DATE(order_date, '%d/%m/%Y')) AS day_of_week,
    COUNT(*) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');
   -- Orders by Weekday vs Weekend
SELECT 
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(order_date, '%d/%m/%Y')) IN (1,7) 
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS total_orders
FROM orders
GROUP BY day_type;


-- ########### 4.Supplier Contribution  ###########
-- AIM:- Identify the most active and profitable suppliers.

-- How many suppliers are there in the database?
SELECT COUNT(*) AS total_suppliers
FROM supplier;

-- Which supplier provides the most products?
SELECT 
    s.sup_id,
    s.sup_name,
    COUNT(p.prod_id) AS total_products
FROM supplier s
JOIN products p 
    ON s.sup_id = p.sup_id
GROUP BY s.sup_id, s.sup_name
ORDER BY total_products DESC
LIMIT 1;

-- What is the average price of products from each supplier?
SELECT 
    s.sup_id,
    s.sup_name,
    AVG(p.price) AS avg_product_price
FROM supplier s
JOIN products p 
    ON s.sup_id = p.sup_id
GROUP BY s.sup_id, s.sup_name
ORDER BY avg_product_price DESC;

-- Which suppliers contribute the most to total product sales (by revenue)?
SELECT 
    s.sup_id,
    s.sup_name,
    SUM(od.total_price) AS total_revenue
FROM supplier s
JOIN products p 
    ON s.sup_id = p.sup_id
JOIN order_details od 
    ON p.prod_id = od.prod_id
GROUP BY s.sup_id, s.sup_name
ORDER BY total_revenue DESC;


-- ############# 5.Employee Performance #############
-- AIM:- Assess how employees are handling and influencing sales.

-- How many employees have processed orders?
SELECT COUNT(DISTINCT emp_id) AS employees_with_orders
FROM orders;

-- Which employees have handled the most orders?
SELECT 
    e.emp_id,
    e.emp_name,
    COUNT(o.ord_id) AS total_orders
FROM 
    employees e
JOIN 
    orders o ON e.emp_id = o.emp_id
GROUP BY 
    e.emp_id, e.emp_name
ORDER BY 
    total_orders DESC -- you can run till here also if you want all the employees and there totla orders
LIMIT 1; -- this is optional, this give one value of the toppest of all


-- What is the total sales value processed by each employee?
SELECT 
    e.emp_id,
    e.emp_name,
    SUM(od.total_price) AS total_sales
FROM 
    employees e
JOIN 
    orders o ON e.emp_id = o.emp_id
JOIN 
    order_details od ON o.ord_id = od.ord_id
GROUP BY 
    e.emp_id, e.emp_name
ORDER BY 
    total_sales DESC;
    
    
-- What is the average order value handled per employee?
SELECT 
    e.emp_id,
    e.emp_name,
    AVG(order_totals.total_order_value) AS avg_order_value
FROM 
    employees e
JOIN 
    orders o ON e.emp_id = o.emp_id
JOIN (
    SELECT 
        ord_id,
        SUM(total_price) AS total_order_value
    FROM 
        order_details
    GROUP BY 
        ord_id
) AS order_totals ON o.ord_id = order_totals.ord_id
GROUP BY 
    e.emp_id, e.emp_name
ORDER BY 
    avg_order_value DESC;


-- ###### 6.Order Details Deep Dive  ########
-- Explore item-level sales patterns and pricing behavior.

-- What is the relationship between quantity ordered and total price?
 -- step1- Average total price per quantity level:
SELECT 
    quantity,
    AVG(total_price) AS avg_total_price,
    COUNT(*) AS order_count
FROM 
    order_details
GROUP BY 
    quantity
ORDER BY 
    quantity;
 -- step2-Total quantity vs total sales:
 SELECT 
    SUM(quantity) AS total_quantity,
    SUM(total_price) AS total_sales,
    SUM(total_price) / SUM(quantity) AS avg_price_per_unit
FROM 
    order_details;
    
    
-- What is the average quantity ordered per product?
SELECT 
    p.prod_id,
    p.prod_name,
    AVG(od.quantity) AS avg_quantity_ordered
FROM 
    order_details od
JOIN 
    products p ON od.prod_id = p.prod_id
GROUP BY 
    p.prod_id, p.prod_name
ORDER BY 
    avg_quantity_ordered DESC;


-- How does the unit price vary across products and orders?
SELECT 
    od.ord_id,
    p.prod_id,
    p.prod_name,
    od.quantity,
    od.total_price,
    (od.total_price / od.quantity) AS unit_price_in_order,
    p.price AS listed_unit_price
FROM 
    order_details od
JOIN 
    products p ON od.prod_id = p.prod_id
ORDER BY 
    p.prod_id, od.ord_id;




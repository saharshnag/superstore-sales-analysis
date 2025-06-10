/*
Filename: 01_ETL_Data_Preparation.sql
Project: Superstore Sales Analysis
Purpose: Contains SQL scripts to perform data extraction, transformation, and loading (ETL) for the Superstore dataset.

Author: Saharsh Nagisetty
Notes:
- This file prepares the raw data for analysis.
- Steps include importing CSV data, cleaning duplicates, transforming fields, and creating normalized tables.
- The output of this file is used by 02_Core_Analysis.sql and 03_Advanced_Business_Insights.sql for business analysis and visualization.
*/

CREATE DATABASE superstore;
USE superstore;

/*orders table contains every line of an order - no deduplication
Order_ID & Product_ID combined makes composite key
Customer_ID & Product_ID are foreign keys pointing to customers and products table respectively*/

CREATE TABLE orders (
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(50),
    Sales DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(10,2),
    PRIMARY KEY (Order_ID, Product_ID)
);

/* Load the dataset from orders.csv file
--------------------------------------------------
Steps: 
1. Right-click your schema > Table Data Import Wizard
2. Select products.csv
3. Map columns to orders table
4.Finish import

Error occured duing loading process:
 - The date formats for order_Date and Ship_Date columns in the orders.csv file are in mm/dd/yyyy format 
 - MySQL expects date format yyyy-mm-dd.

Data Cleaning Approach:
- Used Excel 'Text-to-Columns' to split the above date columns using '/' delimiter.
- Used Excel DATE(yyyy, mm, dd) function to reformat columns into yyyy-mm-dd.
- Saved cleaned CSV for loading into MySQL.

Outcome:
- Orders table now contains properly formatted dates compatible with MySQL DATE columns.
*/



/* Deduplication Notes:
--------------------------------------------------
- Customers table is designed to contain 1 row per Customer.
- Deduplication of Customers was performed in Excel before import.
- Primary Key for Customers: Customer_ID (guaranteed unique).
*/

/* Note:
In this project, both deduplication in Excel and deduplication in SQL were used (depending on table and context).
*/

CREATE TABLE customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50)
);

/*Products Table - Data Import and Deduplication Process
------------------------------------------------------
Purpose:
- The Products table must contain 1 row per unique Product_ID.
- The source CSV (products.csv) may contain duplicate Product_ID entries.

Import Process:
1. Right-click your schema > Table Data Import Wizard
2. Select products.csv
3. Map columns to products_raw table
4. Finish import

Notes:
- The intermediate table 'products_raw' is used to load raw product data without constraints.
- At this point, products_raw may contain duplicate Product_IDs.

Example error if importing directly into Products table with PRIMARY KEY constraint:
Error Code: 1062. Duplicate entry 'FUR-CH-10001146' for key 'products.PRIMARY'

Cleaning Approach:
- Deduplicate the data by selecting the most appropriate entry per Product_ID.
- Insert the cleaned, deduplicated data into the final 'Products' table.

Constraints:
- Product_ID is the PRIMARY KEY in the final Products table (1 row per unique Product_ID).
*/

-- Create products_raw table that will all the data from products.csv

CREATE TABLE products_raw (
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(200),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50)
);

-- Check for duplicates in the products_raw table

SELECT 
    Product_ID, COUNT(*)
FROM
    products_raw
GROUP BY Product_ID; 

-- Output shows duplicate Product_IDs exist. Let's investigate further.

SELECT 
    *
FROM
    products_raw
ORDER BY Product_ID;

/*
Observation:
Upon review, some Product_IDs are associated with more than one Product_Name — a clear data quality issue.
Example:
Product_ID 'FUR-BO-10002213' has two names:
1. 'Sauder Forest Hills Library, Woodland Oak Finish'
2. 'DMI Eclipse Executive Suite Bookcases'

Next: Confirm how many such Product_IDs exist.
*/

-- Find Product_IDs with more than one distinct Product_Name

SELECT 
    Product_ID, COUNT(DISTINCT Product_Name) AS name_variants
FROM
    products_raw
GROUP BY Product_ID
HAVING name_variants > 1;

-- Result: 32 Product_IDs have conflicting product names.

-- Inspect the full rows for these conflicting Product_IDs

SELECT 
    Product_ID, Product_Name, Category, Sub_Category
FROM
    products_raw
WHERE
    Product_ID IN (SELECT 
            Product_ID
        FROM
            products_raw
        GROUP BY Product_ID
        HAVING COUNT(DISTINCT Product_Name) > 1)
ORDER BY Product_ID , Product_Name;

/*
Discussion:
In a real-world scenario, resolving these conflicts would typically involve consulting the product owner or domain/department expert to determine the correct product names.

Since this is a self-led portfolio project, we must make assumptions.

Two potential approaches:

1. Manual Resolution:
   - Manually review all 32 duplicate entries.
   - Choose the most accurate or intended product name.
   - Ensures maximum accuracy, but time-intensive.

2. Automated Resolution (Recommended for project speed):
   - Use a WINDOW function (ROW_NUMBER) to rank product names per Product_ID.
   - Retain the most frequently occurring product name.
   - Assumes the most common name is the correct one — practical and fast for portfolio use.
*/



/*
Step: Create Cleaned Products Table for Analysis
------------------------------------------------
Purpose:
- Create the final 'products' table to store 1 row per unique Product_ID.
- Deduplicate entries from products_raw by selecting the most frequently used Product_Name per Product_ID.

Process:
- Use ROW_NUMBER() to rank Product_Name per Product_ID based on frequency.
- Insert only the top-ranked (most frequent) Product_Name for each Product_ID into the 'products' table.
*/

-- Create products table structure

CREATE TABLE products (
    Product_ID VARCHAR(50) PRIMARY KEY,
    Product_Name VARCHAR(200),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50)
);

-- Insert deduplicated product records into products table

INSERT INTO products (Product_ID, Product_Name, Category, Sub_Category)
SELECT Product_ID, Product_Name, Category, Sub_Category
FROM (
    SELECT 
        Product_ID,
        Product_Name,
        Category,
        Sub_Category,
        ROW_NUMBER() OVER (
            PARTITION BY Product_ID
            ORDER BY freq DESC
        ) AS rn
    FROM (
		-- Count frequency of each Product_Name per Product_ID
        SELECT 
            Product_ID,
            Product_Name,
            Category,
            Sub_Category,
            COUNT(*) AS freq
        FROM products_raw
        GROUP BY Product_ID, Product_Name, Category, Sub_Category
        ORDER BY Product_ID
    ) AS counted
) AS ranked
WHERE rn = 1;


/*
Step: Add Foreign Key Constraints to Orders Table
-------------------------------------------------
Purpose:
- Enforce data integrity by establishing foreign key relationships between Orders → Customers and Orders → Products.
- Benefits:
  * Enforces referential integrity in the database.
  * Helps prevent insertion of invalid Customer_ID or Product_ID values in Orders.
  * Leads to more reliable dashboards and reduces risk of incorrect analysis.
*/

-- Add foreign key constraint: Orders → Customers

ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_ID) REFERENCES customers(Customer_ID);

-- Add foreign key constraint: Orders → Products

ALTER TABLE orders
ADD CONSTRAINT fk_product
FOREIGN KEY (product_ID) REFERENCES products(Product_ID);

/*
Filename: 01_ETL_Data_Preparation.sql
Project: Superstore Sales Analysis
Summary:
- Data extraction, transformation, and loading completed.
- Raw data cleaned and normalized.
- Final tables prepared for use in downstream analysis and BI dashboards.

Author: Saharsh Nagisetty
Notes:
- Maintain ETL scripts carefully if raw data source changes.
- Ensure consistency in data quality for all future analysis.
*/

set @@global.sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); 
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');
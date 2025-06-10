/*
Filename: 02_Core_Analysis.sql
Project: Superstore Sales Analysis
Purpose: Contains analytical SQL queries to explore sales, profitability, customer loyalty, and product performance.

Author: Saharsh Nagisetty
Notes:
- This file complements 01_ETL_Data_Preparation.sql, which performs initial data extraction and cleaning.
- Queries in this file are designed to discover key insights, support dashboard visuals and executive reporting.
*/


/*
---------------------------------------------------
Analysis: Total Sales, Profit, and Orders by Region
---------------------------------------------------
Purpose:
- Understand regional performance in terms of sales volume, profitability, and order count.
- Identify top-performing regions and potential underperformers.

Business Questions:
- Which regions generate the highest sales and profit?
- Are certain regions driving a disproportionate share of revenue?
--------------------------------------------------
*/

SELECT 
    c.Region,
    COUNT(DISTINCT o.Order_ID) AS Number_of_Orders,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit
FROM
    orders o
        JOIN
    customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------------------
Analysis: Total Sales, Profit, Orders, and Profit Margin by Customer Segment
---------------------------------------------------------------------------
Purpose:
- Evaluate segment performance across Consumer, Corporate, and Home Office.
- Support strategic marketing and product positioning decisions.

Business Questions:
1. How do profit margins differ across Consumer, Corporate, and Home Office segments?
2. Are we over-relying on any single customer segment?
3. Are there segments that generate high sales but low profitability?
Metric Note:
- Profit Margin calculated as Total_Profit / Total_Sales.
---------------------------------------------------------------------------
*/

SELECT 
    c.Segment,
    COUNT(DISTINCT o.Order_ID) AS Number_of_Orders,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit,
    (SUM(o.Profit) / SUM(o.Sales) ) AS Profit_Margin
FROM
    orders o
        JOIN
    customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Segment
ORDER BY Total_Sales DESC;



/*
------------------------------------------------------------------------------
Analysis: Total Sales, Profit, and Orders by Product Category and Sub-Category
------------------------------------------------------------------------------
Purpose:
- Analyze product performance at both category and sub-category levels.
- Support product strategy and inventory planning.

Business Questions:
- Which product categories and sub-categories drive the most revenue and profit?
- Are there specific sub-categories with high sales but poor profitability?
- Where should we focus promotional and inventory efforts?
------------------------------------------------------------------------------
*/

SELECT 
    p.Category,
    p.Sub_Category,
    COUNT(DISTINCT o.Order_ID) AS Number_of_Orders,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit
FROM
    orders o
        JOIN
    products p ON o.Product_ID = p.Product_ID
GROUP BY p.Category , p.Sub_Category
ORDER BY Total_Sales DESC;

/*
-------------------------------
Analysis: Monthly Revenue Trend
-------------------------------
Purpose:
- Track revenue and profitability trends over time.
- Identify seasonal patterns or growth/decline periods.

Business Questions:
- Are there clear revenue cycles in the business?
- Are certain months consistently higher or lower in sales or profit?
----------------------------------------------------------------------
*/

SELECT 
    date_format(Order_Date, '%Y-%m') AS Order_Month,     
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Number_of_Orders
FROM
    orders
GROUP BY Order_Month
ORDER BY Order_Month;

/*
---------------------------------------------
Analysis: Top 10 Products by Sales and Profit
---------------------------------------------
Purpose:
- Identify top-performing products by both revenue and profitability.
- Support product strategy, promotion planning, and inventory focus.

Business Questions:
- Which products drive the highest sales?
- Which products are most profitable?
- Are high-sales products also high-margin?
--------------------------------------------------------------------
*/
SELECT 
    o.Product_ID,
    p.Product_Name,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit
FROM
    orders o
		JOIN
	products p ON o.Product_ID = p.Product_ID
GROUP BY Product_ID
ORDER BY Total_Sales DESC
LIMIT 10;

/*
-------------------------------------------------------------------------------
Analysis: Customer Lifetime Value (CLV) — Top 10 Customers by Revenue or Profit
-------------------------------------------------------------------------------
Purpose:
- Identify most valuable customers for loyalty programs or targeted marketing.
- Support account-based marketing efforts and retention strategy.

Business Questions:
- Who are our top 10 customers by revenue/profit?
- What is their ordering behavior (number of orders)?
- Should we prioritize relationship management with these customers?
-------------------------------------------------------------------------------
*/

SELECT 
    o.Customer_ID,
    c.Customer_Name,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit,
    COUNT(DISTINCT o.Order_ID) AS Number_of_Orders
FROM
    orders o
        JOIN
    customers c ON o.Customer_ID = c.Customer_ID
GROUP BY o.Customer_ID, c.Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

/*
-----------------------------------------------------------------------------------
Analysis: Product Performance Across Categories — High vs Low Margin Sub-Categories
-----------------------------------------------------------------------------------
Purpose:
- Identify high-margin and low-margin sub-categories.
- Support product line prioritization, promotional strategy, and pruning decisions.

Business Questions:
- Which sub-categories have the highest profit margins?
- Are there sub-categories generating strong sales but low profit margins?
- Where should we focus promotional or product improvement efforts?
-----------------------------------------------------------------------------------
*/

SELECT 
    p.Category,
    p.Sub_Category,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit,
    ROUND((SUM(o.Profit) / SUM(o.Sales) * 100), 2) AS Profit_Margin_Percent,
    COUNT(DISTINCT o.Order_ID) AS Number_of_Orders
FROM
    orders o
        JOIN
    products p ON o.Product_ID = p.Product_ID
GROUP BY p.Category , p.Sub_Category
ORDER BY Profit_Margin_Percent DESC
LIMIT 5;

/*
------------------------------------------------
Analysis: Customer Segment Performance by Region
------------------------------------------------
Purpose:
- Understand how customer segments (Consumer, Corporate, Home Office) perform across different regions.
- Support geo-targeted marketing campaigns and regional strategy decisions.

Business Questions:
- Which customer segments are most profitable in each region?
- Are there regions where certain segments are under-penetrated?
- Can we tailor marketing messages based on segment-regional performance?

--------------------------------------------------------------------------
*/

SELECT 
    c.Segment, c.Region, SUM(o.Sales) AS Total_Sales, SUM(o.Profit) AS Total_Profit
FROM
    orders o
        JOIN
    customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region, c.Segment
ORDER BY c.Region, Total_Sales DESC;

/*
-------------------------------------
Analysis: Order Frequency by Customer
-------------------------------------
Purpose:
- Identify customers who place the most orders.
- Spot potential brand advocates, loyalty program candidates, or subscription opportunities.

Business Questions:
- Who are our most frequent buyers?
- When did they first start ordering, and when was their last purchase?
- Should we offer loyalty incentives to top customers?

Metrics:
- Orders_Placed = number of distinct orders per customer.
- First_Order = first purchase date.
- Last_Order = most recent purchase date.
----------------------------------------------------------
*/

SELECT 
    Customer_ID,
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Orders_Placed,
    MIN(Order_Date) AS First_Order,
    MAX(Order_Date) AS Last_Order
FROM Orders
JOIN Customers USING (Customer_ID)
GROUP BY Customer_ID
ORDER BY Orders_Placed DESC
LIMIT 10;

/*
----------------------------------------
Analysis: Top Cities by Sales and Profit
----------------------------------------
Purpose:
- Identify top-performing cities based on sales and profitability.
- Support location strategy, local promotions, and expansion planning.

Business Questions:
- Which cities drive the highest sales and profit?
- Are there cities where we should expand marketing or operations?
- Should we target specific high-performing cities for premium services or new offerings?
------------------------------------------------------------------------------------------
*/

SELECT 
    c.City,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit
FROM
    orders o
        JOIN
    customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.City
ORDER BY Total_Sales DESC , Total_Profit DESC
LIMIT 10;

/*
--------------------------------------------------------------------------------
Analysis: Customer Reorder Frequency — Key Metric for CRM and Inventory Planning
--------------------------------------------------------------------------------
Purpose:
- Understand customer reorder behavior and frequency.
- Support both CRM/loyalty strategy and inventory management/replenishment planning.

Business Questions:
CRM / Loyalty:
- On average, how many days between customer orders?
- Are there customers with short or long reorder cycles?
- How can we time campaigns or loyalty offers based on reorder patterns?

Inventory Planning:
- What is the typical reorder cycle length, to inform stock planning?
- Are there customers or segments that require faster replenishment cycles?
- Can we improve inventory forecasting using this reorder data?

Metrics:
- AVG_Days_Between_Orders: Average time between orders per customer.
- Min_Days_Between_Orders: Shortest observed reorder interval.
- Max_Days_Between_Orders: Longest observed reorder interval.
--------------------------------------------------------------------------------
*/

-- Step 1: Extract Order Dates per Customer

SELECT 
    Customer_ID,
    Order_ID,
    Order_Date
FROM
    orders;
    
-- Step 2: Calculate Days Between Orders (Using LAG Function)

SELECT 
    Customer_ID, 
    Order_ID,
    Order_Date,
    LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS previous_order,
    DATEDIFF(Order_Date, LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date)) AS Days_Between_Orders
FROM
    orders 
ORDER BY Customer_ID, Order_ID;

-- Step 3: Aggregate to Customer-Level Reorder Frequency
/*
Purpose:
- Summarize reorder behavior at the customer level.
- Calculate average, minimum, and maximum days between orders for each customer.

Metrics:
- AVG_Days_Between_Orders: Average time between orders for each customer.
- Min_Days_Between_Orders: Shortest time observed between orders.
- Max_Days_Between_Orders: Longest gap between orders.
*/

SELECT
t.Customer_ID,
ROUND(AVG(Days_Between_Orders),0) AS AVG_Days_Between_Orders,
MIN(Days_Between_Orders) AS Min_Days_Between_Orders,
MAX(Days_Between_Orders) AS Max_Days_Between_Orders
FROM (
	SELECT 
		Customer_ID, 
		Order_ID,
		Order_Date,
		LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date) AS previous_order,
		DATEDIFF(Order_Date, LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date)) AS Days_Between_Orders
	FROM
		orders o
	) AS t
WHERE Days_Between_Orders > 0 -- Exclude first/single orders and invalid zero gaps
GROUP BY t.Customer_ID
ORDER BY AVG_Days_Between_Orders;

/*
--------------------------------------------------------------
Analysis: % of Customers with Only 1 Order vs Repeat Customers
--------------------------------------------------------------
Purpose:
- Understand customer retention profile.
- Support loyalty and lifecycle marketing strategies.

Business Questions:
- What % of customers order only once?
- What % of customers place repeat orders?
- Are we acquiring loyal customers, or mostly one-time buyers?

Metrics:
- OneTime_Customers_Count: # of customers with exactly 1 order.
- Repeat_Customers_Count: # of customers with more than 1 order.
- % One-Time vs Repeat Customers.
--------------------------------------------------------------
*/

WITH customer_orders AS (
    SELECT 
        Customer_ID,
        COUNT(Order_ID) AS Orders_Count
    FROM orders
    GROUP BY Customer_ID
),
classification AS (
    SELECT
        SUM(CASE WHEN Orders_Count = 1 THEN 1 ELSE 0 END) AS OneTime_Customers_Count,
        SUM(CASE WHEN Orders_Count > 1 THEN 1 ELSE 0 END) AS Repeat_Customers_Count
    FROM customer_orders
)

SELECT 
    OneTime_Customers_Count,
    Repeat_Customers_Count,
    ROUND((OneTime_Customers_Count * 100.0) / (OneTime_Customers_Count + Repeat_Customers_Count), 2) AS Percent_OneTime_Customers,
    ROUND((Repeat_Customers_Count * 100.0) / (OneTime_Customers_Count + Repeat_Customers_Count), 2) AS Percent_Repeat_Customers
FROM classification;

/*
============================================
Section: Loyalty & Retention Analysis
============================================

Purpose:
- Understand reorder behavior and customer loyalty patterns.
- Identify segments and regions where customers reorder more frequently.
- Classify customers as 1-time or repeat buyers.
- Support targeted loyalty campaigns and better inventory planning.

Key Business Questions:
- What is the average time between customer orders (reorder cycle)?
- Which customer segments and regions have more loyal buyers?
- What % of customers are repeat buyers vs 1-time buyers?
- Who are our most frequent buyers?
- Can we use this to guide loyalty offers or retention strategies?
--------------------------------------------------------------------
*/

-- Step 1: Create common order intervals using a window function

WITH order_intervals AS (
    SELECT
        o.Order_ID,
        o.Customer_ID,
        o.Sales,
        o.Order_Date,
        LAG(o.Order_Date) OVER (PARTITION BY o.Customer_ID ORDER BY o.Order_Date) AS Previous_Order_Date,
        DATEDIFF(o.Order_Date, LAG(o.Order_Date) OVER (PARTITION BY o.Customer_ID ORDER BY o.Order_Date)) AS Days_Between_Orders
    FROM orders o
) 

-- Step 2: Average Days Between Orders by Region (for loyalty insights)
SELECT 
    c.Region,
    ROUND(AVG(t.Days_Between_Orders), 0) AS AVG_Days_Between_Orders
FROM order_intervals t
JOIN customers c ON t.Customer_ID = c.Customer_ID
WHERE t.Days_Between_Orders IS NOT NULL
GROUP BY c.Region
ORDER BY AVG_Days_Between_Orders;

-- Step 3: Average Days Between Orders by Segment (target high-LTV segments)
SELECT 
    c.Segment,
    COUNT(*) AS Total_Orders_Count,
    SUM(t.Sales) AS Total_Revenue,
    ROUND(AVG(t.Days_Between_Orders), 0) AS AVG_Days_Between_Orders,
    MIN(t.Days_Between_Orders) AS Min_Days_Between_Orders,
    MAX(t.Days_Between_Orders) AS Max_Days_Between_Orders
FROM order_intervals t 													-- order_intervals CTE above
JOIN customers c ON t.Customer_ID = c.Customer_ID
WHERE t.Days_Between_Orders IS NOT NULL
GROUP BY c.Segment
ORDER BY AVG_Days_Between_Orders;

-- Step 4: Reorder Frequency Metrics (customer-level)
SELECT
    Customer_ID,
    COUNT(*) AS Total_Orders,
    COUNT(Days_Between_Orders) AS Repeat_Orders,
    ROUND(AVG(Days_Between_Orders), 2) AS Avg_Days_Between_Orders,
    MIN(Days_Between_Orders) AS Min_Days_Between,
    MAX(Days_Between_Orders) AS Max_Days_Between
FROM order_intervals													-- order_intervals CTE above
WHERE Days_Between_Orders IS NOT NULL
GROUP BY Customer_ID
ORDER BY Avg_Days_Between_Orders;

-- Step 5: Customer Loyalty Classification (1-time vs Repeat)

WITH customer_orders AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Orders_Count
    FROM orders
    GROUP BY Customer_ID
),
customer_classification AS (
    SELECT
        Customer_ID,
        CASE 
            WHEN Orders_Count = 1 THEN '1-time Buyer'
            ELSE 'Repeat Customer'
        END AS Customer_Type
    FROM customer_orders
)

-- Loyalty Distribution Table (for donut chart)

SELECT
    Customer_Type,
    COUNT(*) AS Num_Customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Percent_Customers
FROM customer_classification
GROUP BY Customer_Type;


-- Classification Table (joinable with Customers for slicers)

SELECT
    Customer_ID,
    Customer_Type
FROM customer_classification;										-- customer_classification CTE above


/*
==================================================
View: vw_EnhancedDaysBetweenOrders
==================================================

Purpose:
- Calculate Days Between Orders for each customer using the LAG() window function.
- Enrich the result with customer segment, region, and product hierarchy data.
- Support advanced loyalty analysis, reorder cycle insights, and inventory planning.

Business Use Cases:
- Analyze typical reorder patterns per segment, region, and product category.
- Power BI dashboards → enable slicers for Segment, Region, and Category.
- Drive loyalty program targeting and replenishment campaign optimization.

Technical Notes:
- LAG() OVER (PARTITION BY Customer_ID ORDER BY Order_Date) is used to compute Previous_Order_Date.
- DATEDIFF is used to compute Days_Between_Orders.
- Only rows with Days_Between_Orders > 0 are included in the final result.
--------------------------------------------------------------------------------------------------
*/

CREATE OR REPLACE VIEW vw_EnhancedDaysBetweenOrders AS
WITH order_intervals AS (
    SELECT
        o.Customer_ID,
        c.Segment,
        c.Region,
        o.Product_ID,
        p.Category,
        p.Sub_Category,
        o.Order_ID,
        o.Order_Date,
        LAG(o.Order_Date) OVER (PARTITION BY o.Customer_ID ORDER BY o.Order_Date) AS Previous_Order_Date,
        DATEDIFF(o.Order_Date, LAG(o.Order_Date) OVER (PARTITION BY o.Customer_ID ORDER BY o.Order_Date)) AS Days_Between_Orders
    FROM Orders o
    JOIN Customers c ON o.Customer_ID = c.Customer_ID
    JOIN Products p ON o.Product_ID = p.Product_ID
)

SELECT
    Order_Date,
    Days_Between_Orders,
    Customer_ID,
    Segment,
    Region,
    Product_ID,
    Category,
    Sub_Category
FROM order_intervals
WHERE Days_Between_Orders IS NOT NULL;


/*
---------------------------------------------------------------
End of File — 02_Core_Analysis.sql
Project: Superstore Sales Analysis
Summary:
- Core Business Analysis completed.
- Loyalty & Retention Insights provided.

Next Steps:
- Continue enhancing dashboards based on these outputs.
- Monitor data quality and refresh processes regularly.
- Consider additional deep-dives based on business questions.

Author: Saharsh Nagisetty
---------------------------------------------------------------
*/


set @@global.sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); 
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');

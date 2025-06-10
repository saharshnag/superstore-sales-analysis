/*
------------------------------------------------------------
Filename: 03_Advanced_Business_Insights.sql
Project: Superstore Sales Analysis
Purpose: Contains advanced analytical SQL queries to explore operational performance, customer profitability, and business growth trends.

Author: Saharsh Nagisetty
Notes:
- This file complements 02_Core_Analysis.sql by providing additional business insights beyond core sales and retention analysis.
- Queries in this file are designed to support advanced dashboard visuals, cross-functional reporting, and strategic decision-making.
------------------------------------------------------------
*/



/*
====================================================
Section: Bonus Analyses — Advanced Business Insights
====================================================

Purpose:
- Provide additional advanced insights beyond core business metrics.
- Support cross-functional needs such as inventory management, marketing strategy, and operational optimization.

Key Topics Covered:
- Shipping performance and delivery delays.
- Product bundling and cross-sell opportunities.
- Customer profit segmentation.
- Year-over-Year (YoY) sales growth trends.

Value to Business:
- Helps drive strategic decision-making.
- Uncovers hidden trends and actionable insights.
- Demonstrates advanced SQL skills and data storytelling.

---------------------------------------------------------------
*/

/*
------------------------------------------------------
Analysis: Average Delivery Time (Shipping Performance)
------------------------------------------------------

Purpose:
- Calculate average delivery time (Ship_Date - Order_Date) by Region and Segment.

Business Questions:
- How quickly are we delivering orders on average?
- Are certain regions or segments experiencing longer delivery times?
- Can we improve customer experience by reducing delivery delays?

Technical Notes:
- Uses DATEDIFF to calculate delivery duration.
- Groups by Region and Segment.
- Filters not required.
--------------------------------------------------
*/
SELECT 
    c.Region,
    c.Segment,
    ROUND(AVG(DATEDIFF(o.Ship_Date, o.Order_Date)), 2) AS Avg_Delivery_Days
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region, c.Segment
ORDER BY Avg_Delivery_Days;

/*
----------------------------------------------------------
Analysis: % of Orders Delivered within N Days by Region
----------------------------------------------------------

Purpose:
- Analyze delivery performance by region using % of orders delivered within target timeframes.

Business Questions:
- What % of orders are delivered within 3 days, 5 days, or delayed beyond 5 days?
- Are there regional differences in delivery efficiency?
- Can we improve customer experience by optimizing delivery times?

Technical Notes:
- Uses DATEDIFF between Ship_Date and Order_Date.
- Bins orders into 3 categories: ≤ 3 days, ≤ 5 days, > 5 days.
- Groups by Region to show geographic differences.

----------------------------------------------------------
*/

SELECT 
    c.Region,
    ROUND(SUM(CASE WHEN DATEDIFF(o.Ship_Date, o.Order_Date) <= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Percent_Within_3_Days,
    ROUND(SUM(CASE WHEN DATEDIFF(o.Ship_Date, o.Order_Date) <= 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Percent_Within_5_Days,
    ROUND(SUM(CASE WHEN DATEDIFF(o.Ship_Date, o.Order_Date) > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Percent_Delayed_Over_5_Days
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region
ORDER BY Percent_Within_3_Days DESC;

/*
---------------------------------------------------------------------
Analysis: Product Bundling Insights (Common Products Bought Together)
---------------------------------------------------------------------

Purpose:
- Identify pairs of products frequently bought together.
- Support cross-sell opportunities, bundle offers, and promotion planning.

Business Questions:
- Which products are commonly purchased together in the same order?
- Can we use bundling to increase average order value?

Technical Notes:
- Self-join on Orders table by Order_ID.
- Uses condition o1.Product_ID < o2.Product_ID to avoid duplicate pairs.
- Orders grouped and counted.
----------------------------------------------------------------------------
*/

SELECT 
    o1.Product_ID AS Product_1,
    o2.Product_ID AS Product_2,
    COUNT(*) AS Times_Bought_Together
FROM orders o1
JOIN orders o2 
    ON o1.Order_ID = o2.Order_ID AND o1.Product_ID < o2.Product_ID
GROUP BY o1.Product_ID, o2.Product_ID
ORDER BY Times_Bought_Together DESC
LIMIT 10;

/*
-----------------------------------------------
Analysis: Customer Profit Distribution (Binned)
-----------------------------------------------

Purpose:
- Segment customers by total profit contribution.
- Identify distribution of customer profitability.

Business Questions:
- What % of customers contribute < $100, $100–$500, $501–$1000, or > $1000 in profit?
- Are we overly dependent on a small set of highly profitable customers?

Technical Notes:
- Inner query aggregates total profit per customer.
- Outer query bins customers into ranges using CASE.
- Results grouped and ordered by bin.
--------------------------------------------------
*/

SELECT 
    CASE 
        WHEN Total_Profit < 100 THEN '<$100'
        WHEN Total_Profit BETWEEN 100 AND 500 THEN '$100–$500'
        WHEN Total_Profit BETWEEN 501 AND 1000 THEN '$501–$1000'
        ELSE '>$1000'
    END AS Profit_Bin,
    COUNT(*) AS Customer_Count
FROM (
    SELECT 
        Customer_ID,
        SUM(Profit) AS Total_Profit
    FROM orders
    GROUP BY Customer_ID
) AS customer_profits
GROUP BY Profit_Bin
ORDER BY Customer_Count DESC;

/*
-----------------------------------------
Analysis: Year-over-Year Sales Growth (%)
-----------------------------------------

Purpose:
- Track annual growth in sales.
- Evaluate company performance trends over time.

Business Questions:
- What is the Year-over-Year (YoY) % growth in sales?
- Are we growing faster, slower, or consistently over time?

Technical Notes:
- Groups by YEAR(Order_Date).
- Uses LAG window function to compare sales vs prior year.
- Uses NULLIF to handle division by 0.
------------------------------------------------------------
*/

SELECT 
    YEAR(Order_Date) AS Year,
    SUM(Sales) AS Total_Sales,
    LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date)) AS Previous_Year_Sales,
    ROUND(
        100.0 * (SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date))) / 
        NULLIF(LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date)), 0), 2
    ) AS YoY_Growth_Percent
FROM orders
GROUP BY YEAR(Order_Date)
ORDER BY Year;

/*
------------------------------------------------------------
End of File — 03_Advanced_Business_Insights.sql
Project: Superstore Sales Analysis
Summary:
- Advanced Business Analysis completed.
- Cross-functional insights provided to complement core analysis.
- Ready for integration into BI dashboards and portfolio presentation.

Author: Saharsh Nagisetty
Notes:
- Consider extending this file with future advanced analyses (cohort analysis, churn prediction, customer lifetime value modeling).
- Maintain consistency in formatting and documentation for all new queries added to this file.
------------------------------------------------------------
*/

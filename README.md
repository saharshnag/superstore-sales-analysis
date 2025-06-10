🏍️ Superstore Sales Analysis Project
📌 Executive Summary

This project explores Superstore sales data to uncover actionable business insights across regional performance, customer loyalty, product profitability, and operational efficiency.
Using SQL and Power BI, we built a structured ETL process, analytical queries, and interactive dashboards to support business stakeholders in strategic decision-making.
🌟 Project Goals

    Build a reliable data model from raw Excel sales data.
    Analyze key sales and profit trends across segments and regions.
    Uncover customer retention and reorder behavior.
    Analyze advanced insights such as shipping performance and customer profitability.
    Create a dynamic dashboard for business users.
    Document insights and make the project portfolio-ready.

🛠️ Tools & Technologies

    MySQL 8.0
    Power BI Desktop
    Excel (Data pre-processing)
    GitHub (Documentation & hosting)

📂 Data Sources

    Orders.csv (from Superstore Excel file)
    Customers.csv (manually split from Orders)
    Products.csv (manually split from Orders)

🔄 ETL Process Summary

    Cleaned and deduplicated customer and product data.
    Created normalized SQL tables: Orders, Customers, Products.
    Connected Power BI to MySQL database.
    Built relationships to support dynamic slicers and DAX measures.
    Created Customer_Reorder_Classification table and vw_EnhancedDaysBetweenOrders view.

📊 Dashboards & Outputs
Dashboard 1 — Overview

    Sales & Profit by Region.
    Revenue Over Time.
    Profit by Category.
    Profitability by Segment.
    KPI Cards: Total Sales, Total Profit, Orders, Unique Customers.

Dashboard 2 — Retention / Loyalty Analysis

    Order Frequency by Region and Segment.
    Reorder Frequency (by Month).
    % Repeat Customers vs 1-time Buyers (Donut Chart).
    Average Days Between Orders Over Time.
    Order Frequency by Product Category.
    Revenue by Month.

Dashboard 3 — Advanced Business Insights

    Avg Delivery Days, % Delivered within 3 Days, Max Delivery Days.
    % Delivered within N Days by Region.
    Year-over-Year Sales Growth % (YoY).
    Customer Profit Distribution.
    Product Bundling — Top 10 Product Pairs.
    Revenue & Profit by Shipping Mode.

📂 Outputs / Visuals

Available in outputs/charts/ folder:

    dashboard-overview.png
    dashboard-retention.png
    dashboard-advanced.png

Optional full dashboard PDF:

    outputs/Superstore_Dashboard.pdf

💡 Key Business Insights

    Customer Loyalty: ~98% of customers are repeat buyers, driving ~99% of revenue.
    Regional Trends: Western region leads in sales and profitability.
    Reorder Cycle: Avg reorder cycle 45–60 days; Office Supplies reorder faster.
    Segment Profitability: Home Office segment has higher profit margins percent.
    Shipping: ~32% of orders delivered within 3 days; opportunities to optimize for certain regions.
    Customer Profitability: Top 10 customers contribute ~14% of total profit.
    Growth: Year-over-Year sales growth of 130.25% (last year vs prior year).

📖 Project Process & Technical Walkthrough Detailed walkthrough of ETL process, key queries, customer loyalty analysis, reorder behavior, and advanced business insights is documented in:

    01_ETL_Data_Preparation.sql
    02_Core_Analysis.sql
    03_Advanced_Business_Insights.sql

🗃️ Project Folder Structure

superstore-sales-analysis/
├── README.md
├── sql/
│   ├── 01_ETL_Data_Preparation.sql
│   ├── 02_Core_Analysis.sql
│   ├── 03_Advanced_Business_Insights.sql
├── dashboards/
│   └── Superstore_Dashboard.pbix
├── outputs/
│   ├── Superstore_Dashboard.pdf
│   └── charts/
│       ├── dashboard-overview.png
│       ├── dashboard-retention.png
│       ├── dashboard-advanced.png
└── data/
    ├── orders.csv
    ├── customers.csv
    └── products.csv


🚀 How to Run
- Clone the repo.
- Set up MySQL and import the data using provided SQL scripts.
- Open Power BI Desktop and connect to MySQL.
- Use provided .pbix file or build your visuals from scratch.
- Export visuals or publish Power BI report as needed.

💌 Contact
For questions or collaboration:
Saharsh Nagisetty | www.linkedin.com/in/saharsh-nagisetty-3718009b

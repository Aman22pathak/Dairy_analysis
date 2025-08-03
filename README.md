# 🥛 Dairy Supply Chain Performance Analysis using SQL

## 📁 Project Overview

This project involves end-to-end analysis of a dairy dataset using SQL. The analysis includes:

* Data cleaning
* KPI generation
* Vendor and location analysis
* Seasonal trends
* Product-level insights
* Returns and organic product analysis

The project demonstrates all major SQL concepts and consists of **250+ SQL queries**, making it ideal for resumes and portfolios.

---

## 🎓 Objectives

* Clean and validate the dataset
* Perform advanced SQL operations (CTEs, Views, Window Functions, Subqueries)
* Generate business insights and KPIs
* Build reusable SQL logic via views
* Upload and showcase on GitHub + LinkedIn

---

## 📄 Dataset Info

* **File:** `dairy_dataset.csv`
* **Columns:** 26
* **Examples:** `Product_Name`, `Vendor_Name`, `Total_Cost`, `Return_Flag`, `Date`, `Season`, `Shift`, `Is_Organic`

---

## 💡 Tools Used

* **MySQL Workbench** (Data querying and import)
* **SQL** (All logic and transformation)
* **GitHub** (Version control)
* **Markdown** (Documentation)

---

## 🔢 SQL Topics Covered

* Basic SQL (SELECT, WHERE, GROUP BY, HAVING)
* Data Cleaning
* CASE statements
* Aggregation
* Joins
* Window Functions
* Common Table Expressions (CTEs)
* Subqueries (Correlated and Non-Correlated)
* Views
* Time-based functions
* Boolean flag handling

---

## 🔄 SQL Workflow Summary

### 1. Create Database & Table

```sql
CREATE DATABASE DairyAnalytics;
USE DairyAnalytics;

CREATE TABLE DAIRY_RECORDS (
    Record_ID INT PRIMARY KEY AUTO_INCREMENT,
    Date DATE,
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(100),
    Brand VARCHAR(100),
    Quantity_Liters_KG DECIMAL(10,2),
    Unit VARCHAR(20),
    Price_Per_Unit DECIMAL(10,2),
    Total_Cost DECIMAL(10,2),
    Vendor_ID VARCHAR(50),
    Vendor_Name VARCHAR(100),
    Procurement_Type VARCHAR(50),
    Payment_Mode VARCHAR(50),
    Location VARCHAR(100),
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    Season VARCHAR(20),
    Shift VARCHAR(20),
    Fat_Content DECIMAL(5,2),
    SNF_Content DECIMAL(5,2),
    Protein_Content DECIMAL(5,2),
    Added_Sugar BOOLEAN,
    Is_Organic BOOLEAN,
    Delivery_Mode VARCHAR(50),
    Return_Flag BOOLEAN,
    Expiry_Date DATE
);
```

### 2. Null Audit

```sql
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS Null_Product_Name,
    SUM(CASE WHEN Total_Cost IS NULL THEN 1 ELSE 0 END) AS Null_Cost,
    ...
FROM DAIRY_RECORDS;
```

### 3. Remove Duplicates

```sql
DELETE FROM DAIRY_RECORDS
WHERE Record_ID NOT IN (
    SELECT MIN(Record_ID)
    FROM DAIRY_RECORDS
    GROUP BY Product_ID, Date, Vendor_ID
);
```

### 4. Replace Yes/No with Boolean

```sql
UPDATE DAIRY_RECORDS
SET Added_Sugar = CASE WHEN Added_Sugar = 'Yes' THEN 1 ELSE 0 END;
```

---

## 📊 KPIs & Business Queries

### Product KPIs

```sql
-- Top 10 Products by Quantity
SELECT Product_Name, SUM(Quantity_Liters_KG) AS Total_Quantity
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Total_Quantity DESC
LIMIT 10;

-- Product Revenue + Return Rate
SELECT Product_Name,
       ROUND(SUM(Total_Cost), 2) AS Revenue,
       COUNT(*) AS Orders,
       SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS Returns,
       ROUND(SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS Return_Rate
FROM DAIRY_RECORDS
GROUP BY Product_Name;
```

### Vendor KPIs

```sql
-- Best Vendors by Revenue
SELECT Vendor_Name, SUM(Total_Cost) AS Vendor_Revenue
FROM DAIRY_RECORDS
GROUP BY Vendor_Name
ORDER BY Vendor_Revenue DESC;
```

### Window Function Examples

```sql
-- Rank Top Products by Revenue
WITH ProductRev AS (
    SELECT Product_Name, SUM(Total_Cost) AS Revenue
    FROM DAIRY_RECORDS
    GROUP BY Product_Name
)
SELECT Product_Name, Revenue,
       RANK() OVER (ORDER BY Revenue DESC) AS Rank
FROM ProductRev;

-- 7-Day Moving Average Sales
SELECT Date, Product_Name,
       SUM(Total_Cost) AS Daily_Sales,
       ROUND(AVG(SUM(Total_Cost)) OVER (PARTITION BY Product_Name ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS Moving_Avg
FROM DAIRY_RECORDS
GROUP BY Date, Product_Name;
```

### Seasonal Analysis

```sql
-- Revenue by Season
SELECT Season, SUM(Total_Cost) AS Seasonal_Revenue
FROM DAIRY_RECORDS
GROUP BY Season
ORDER BY Seasonal_Revenue DESC;
```

### View Creation

```sql
-- Product Summary View
CREATE VIEW Product_Metrics AS
SELECT Product_Name,
       SUM(Quantity_Liters_KG) AS Total_Qty,
       SUM(Total_Cost) AS Total_Revenue,
       COUNT(*) AS Orders
FROM DAIRY_RECORDS
GROUP BY Product_Name;
```

---

## 📅 Project Structure

```
Dairy-SQL-Project/
├── README.md
├── dairy_dataset.csv
├── SQL_Scripts/
│   ├── 01_Create_Database.sql
│   ├── 02_Cleaning.sql
│   ├── 03_KPIs_Products.sql
│   ├── 04_KPIs_Vendors.sql
│   ├── 05_CTEs.sql
│   ├── 06_Window_Functions.sql
│   ├── 07_Views.sql
│   └── 08_Final.sql
```

---

## 🌟 Sample Business Insights

* “Cheese” products dominate summer sales revenue.
* Vendor A has lowest return rate but limited product variety.
* Organic milk demand is highest in northern region during winter.
* Return rates spike during night shift deliveries.

---

## 📗 How to Use

1. Import `dairy_dataset.csv` into MySQL.
2. Run scripts from `SQL_Scripts/` in order.
3. Use created views for reporting and dashboarding.

---

## 👤 Author

**Aman Pathak**


---


-- Step 1: Create the database
CREATE DATABASE DairyAnalytics;
USE DairyAnalytics;

-- Step 2: Create the main table based on the dataset structure

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
-- Step 4: Preview the dataset
SELECT * FROM DAIRY_RECORDS LIMIT 10;
-- Step 5: Null audit
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS Null_Date,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Null_Product_ID,
    SUM(CASE WHEN Brand IS NULL THEN 1 ELSE 0 END) AS Null_Brand,
    SUM(CASE WHEN Expiry_Date IS NULL THEN 1 ELSE 0 END) AS Null_Expiry
FROM DAIRY_RECORDS;
-- Step 6a: Find any text values in numeric fields (e.g., Quantity)
SELECT Quantity_Liters_KG FROM DAIRY_RECORDS
WHERE NOT Quantity_Liters_KG REGEXP '^[0-9]+(\.[0-9]+)?$';

-- Step 6b: Unexpected values in Boolean fields
SELECT DISTINCT Added_Sugar, Is_Organic, Return_Flag FROM DAIRY_RECORDS;
 -- Step 7: Find duplicate entries (excluding the ID column)
SELECT Product_ID, Date, Vendor_ID, COUNT(*) as cnt
FROM DAIRY_RECORDS
GROUP BY Product_ID, Date, Vendor_ID
HAVING COUNT(*) > 1;

-- Step 8: Remove duplicate records based on Product_ID, Date, Vendor_ID
DELETE FROM DAIRY_RECORDS
WHERE Record_ID NOT IN (
    SELECT MIN(Record_ID)
    FROM DAIRY_RECORDS
    GROUP BY Product_ID, Date, Vendor_ID
);

-- Step 9: If booleans are stored as 'Yes'/'No'
UPDATE DAIRY_RECORDS
SET Added_Sugar = CASE WHEN Added_Sugar = 'Yes' THEN 1 ELSE 0 END,
    Is_Organic = CASE WHEN Is_Organic = 'Yes' THEN 1 ELSE 0 END,
    Return_Flag = CASE WHEN Return_Flag = 'Yes' THEN 1 ELSE 0 END;

-- Total quantity sold per product
SELECT Product_Name, SUM(Quantity_Liters_KG) AS Total_Quantity
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Total_Quantity DESC;

-- Total revenue per product
SELECT Product_Name, SUM(Total_Cost) AS Revenue
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Revenue DESC;


-- Top performing locations by sales
SELECT Location, SUM(Total_Cost) AS Revenue
FROM DAIRY_RECORDS
GROUP BY Location
ORDER BY Revenue DESC;



-- Sales by Season
SELECT Season, SUM(Total_Cost) AS Revenue
FROM DAIRY_RECORDS
GROUP BY Season
ORDER BY Revenue DESC;


-- Vendor performance by sales
SELECT Vendor_Name, SUM(Total_Cost) AS Total_Sales, COUNT(*) AS Transactions
FROM DAIRY_RECORDS
GROUP BY Vendor_Name
ORDER BY Total_Sales DESC;


-- Return rate per product
SELECT Product_Name,
       COUNT(*) AS Total_Sales,
       SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS Returns,
       ROUND(SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END)*100.0 / COUNT(*), 2) AS Return_Rate
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Return_Rate DESC;


-- Total Quantity Sold per Product (Basic Aggregation)
SELECT 
    Product_Name,
    SUM(Quantity_Liters_KG) AS Total_Quantity
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Total_Quantity DESC;


-- Total Revenue per Product
SELECT 
    Product_Name,
    ROUND(SUM(Total_Cost), 2) AS Total_Revenue
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Total_Revenue DESC;


-- Product Revenue and Return Rate
SELECT 
    Product_Name,
    ROUND(SUM(Total_Cost), 2) AS Total_Revenue,
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS Returns,
    ROUND(SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Return_Percentage
FROM DAIRY_RECORDS
GROUP BY Product_Name
ORDER BY Return_Percentage DESC;


-- CTE to get only top products and rank them
WITH ProductRevenue AS (
    SELECT 
        Product_Name,
        SUM(Total_Cost) AS Revenue
    FROM DAIRY_RECORDS
    GROUP BY Product_Name
)
SELECT 
    Product_Name,
    Revenue,
    RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank
FROM ProductRevenue
LIMIT 10;


-- Daily sales per product with moving average
SELECT 
    Date,
    Product_Name,
    SUM(Total_Cost) AS Daily_Revenue,
    ROUND(AVG(SUM(Total_Cost)) OVER (PARTITION BY Product_Name ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS 7_Day_Moving_Avg
FROM DAIRY_RECORDS
GROUP BY Date, Product_Name
ORDER BY Product_Name, Date;



-- Revenue of products by season
SELECT 
    Product_Name,
    Season,
    ROUND(SUM(Total_Cost), 2) AS Seasonal_Revenue
FROM DAIRY_RECORDS
GROUP BY Product_Name, Season
ORDER BY Product_Name, Seasonal_Revenue DESC;


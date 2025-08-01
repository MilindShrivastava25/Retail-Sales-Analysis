
/*
=======================================================================================
This phase involves TRANSFORMING the exported retail datasets into a clean,
structured format suitable for analytical processing.

Raw data containing inconsistencies, null values, and incorrect data types is 
systematically cleaned, standardized, and enriched using SQL Server. 

Key transformation tasks include handling missing values, normalizing column formats, 
converting data types, and preparing relational integrity across tables.

Subsequently, Power BI is employed to connect to the transformed data and 
deliver interactive dashboards and visual analytics, enabling stakeholders
to derive actionable, data-driven business insights.
=======================================================================================
*/



/*
=============================================================================================
Since Stores serves as the fact table, we begin by validating and enforcing the primary key.
Stores:- Store, Type, Size
=============================================================================================
*/


SELECT 
	Store,
	COUNT(*) "Null Count"
FROM dbo.stores
WHERE Store IS NULL
GROUP BY Store;

SELECT 
	Store,
	COUNT(store) "Unique Count"
FROM dbo.stores 
GROUP BY store
HAVING COUNT(*) > 1;

ALTER TABLE Stores
ADD CONSTRAINT PK_Stores_Store PRIMARY KEY (Store);

-- ===============================
-- Primary Key Column is clean.
-- ===============================


SELECT 
	Type,
	COUNT(*) "Null Count"
FROM dbo.stores
WHERE Type IS NULL
GROUP BY Type;


SELECT	
	Size,
	COUNT(*) "Null Count"
FROM dbo.stores
WHERE size IS NULL
GROUP BY size;

-- ====================================================================================================================
-- Initiating the transformation process on the Sales table to cleanse and prepare the data for analytical consumption.
-- Sales:- Stores, Dept, Date, Weekly_sales, Isholiday
-- ====================================================================================================================

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Store
FOREIGN KEY (Store) REFERENCES Stores(Store);


SELECT 
	store,
	COUNT(*) "Null Count"
FROM dbo.Sales
WHERE store IS NULL
GROUP BY store;

SELECT	
	Dept,
	COUNT(*) "Null Count"
FROM dbo.sales
WHERE Dept IS NULL
GROUP BY Dept;

SELECT 
	Date,
	COUNT(*) "Null count"
FROM dbo.sales
WHERE Date IS NULL
GROUP BY Date;

SELECT 
	Weekly_Sales,
	COUNT(*) "Null Count"
FROM dbo.sales
WHERE Weekly_sales IS NULL
GROUP BY Weekly_sales;

SELECT 
	IsHoliday,
	COUNT(*) "Null Count"
FROM dbo.sales
WHERE ISHoliday IS NULL
GROUP BY ISHoliday;

UPDATE sales
SET weekly_sales = 0 
WHERE Weekly_sales IS NULL;


-- ======================================================================================================================================
-- Initiating the transformation process on the Features table to cleanse and prepare the data for analytical consumption.
-- Features:- Store, Date, Temperature, Fuel_Price, MarkDown1, MarkDown2, MarkDown3, MarkDown4, MarkDown5, CPI, Unqmployment, IsHoliday
-- ======================================================================================================================================


ALTER TABLE Features
ADD CONSTRAINT FK_Features_Store
FOREIGN KEY (Store) REFERENCES Stores(Store);

SELECT
	COUNT(*)
FROM Features
WHERE Store IS NULL
	OR Date IS NULL
	OR Temperature IS NULL
	OR Fuel_Price IS NULL
	OR MarkDown1 IS NULL
	OR MarkDown2 IS NULL
	OR MarkDown3 IS NULL
	OR MarkDown4 IS NULL
	OR MarkDown5 IS NULL
	OR CPI IS NULL
	OR Unemployment IS NULL
	OR IsHoliday IS NULL;


UPDATE Features 
SET		
	Temperature = ISNULL(Temperature, 0),
	Fuel_Price = ISNULL(Fuel_price, 0),
    MarkDown1 = ISNULL(MarkDown1, 0),
    MarkDown2 = ISNULL(MarkDown2, 0),
    MarkDown3 = ISNULL(MarkDown3, 0),
    MarkDown4 = ISNULL(MarkDown4, 0),
    MarkDown5 = ISNULL(MarkDown5, 0),
    CPI = ISNULL(CPI, 0),
    Unemployment = ISNULL(Unemployment, 0)
WHERE Temperature IS NULL
	OR Fuel_Price IS NULL
    OR MarkDown1 IS NULL
    OR MarkDown2 IS NULL
    OR MarkDown3 IS NULL
    OR MarkDown4 IS NULL
    OR MarkDown5 IS NULL
    OR CPI IS NULL
    OR Unemployment IS NULL;


SELECT COUNT(*) AS NullRows
FROM Features
WHERE Temperature IS NULL
    OR Fuel_Price IS NULL
    OR MarkDown1 IS NULL
    OR MarkDown2 IS NULL
    OR MarkDown3 IS NULL
    OR MarkDown4 IS NULL
    OR MarkDown5 IS NULL
    OR CPI IS NULL
    OR Unemployment IS NULL;


ALTER TABLE Features
ALTER COLUMN MarkDown1 FLOAT;

ALTER TABLE Features
ALTER COLUMN MarkDown2 FLOAT;

ALTER TABLE Features
ALTER COLUMN MarkDown3 FLOAT;

ALTER TABLE Features
ALTER COLUMN MarkDown4 FLOAT;

ALTER TABLE Features
ALTER COLUMN MarkDown5 FLOAT;

EXEC sp_help 'Features';

/*
=====================================================================================================================================
Summary
-------------------------------------------------------------------------------------------------------------------------------------
The following has been done in this Transform phase:
	1. Null Handling: Identified and imputed or removed all NULL values across all datasets to ensure data completeness.
	2. Duplicate Elimination: Detected and removed duplicate records to maintain data integrity and accuracy.
	3. Data Type Standardization: Validated and corrected column data types (e.g., VARCHAR to INT, FLOAT) 
	   to support proper relational modeling and analytical operations.
	4. Date Format Consistency: Ensured uniformity in date formats across tables to enable accurate time-series analysis and joins.
=====================================================================================================================================

================================================================================================================================================
The dataset is now fully transformed, cleansed, and structured—ready for seamless integration into Power BI for data modeling and visualization.
================================================================================================================================================
*/

/*
=====================================================================================================================================
To optimize performance and streamline data modeling in Power BI, instead of connecting to raw base tables, SQL views were created.
=====================================================================================================================================
*/

CREATE VIEW Features_View AS
	SELECT * FROM Features;

CREATE VIEW Sales_View AS
	SELECT * FROM Sales;

CREATE VIEW Stores_View AS
	SELECT * FROM stores;


/*
=============================================
 This file focuses on query-driven analysis.
=============================================
*/

-- Store with highest overall sales
SELECT TOP 1
	Stores_View.Store,
	SUM(Sales_View.Store) "Total sales"
FROM Stores_View 
JOIN Sales_View 
ON Stores_View.Store = Sales_View.Store
GROUP BY Stores_View.Store
ORDER BY "Total Sales" DESC;


-- Top 5 Stores By Average Weekly Sales
SELECT TOP 5
	Stores_View.Store,
	AVG(Sales_View.Weekly_Sales) "Average Sales"
FROM Stores_View 
JOIN Sales_View
ON Stores_View.Store = Sales_View.Store
GROUP BY Stores_View.Store
ORDER BY "Average Sales" DESC;


-- Department underperfoming 
SELECT TOP 1
	Dept,
	SUM(Weekly_Sales) "Total Sales"
FROM Sales_View
GROUP BY Dept
ORDER BY "Total Sales";


-- Total Weekly Sales for Each Store Type
SELECT 
	Stores_View.Type,
	SUM(Sales_View.Weekly_Sales) "Total Sales"
FROM Stores_View 
JOIN Sales_view 
ON Stores_View.Store = Sales_View.Store
GROUP BY Stores_View.Type;


-- Average weekly sales during markdown periods vs non-markdown periods
SELECT 
    CASE 
        WHEN (f.MarkDown1 > 0 OR f.MarkDown2 > 0 OR f.MarkDown3 > 0 OR f.MarkDown4 > 0 OR f.MarkDown5 > 0)
             THEN 'Markdown_Applied'
        ELSE 'No_Markdown'
    END AS Markdown_Status,
    ROUND(AVG(s.Weekly_Sales), 2) AS Avg_Weekly_Sales
FROM Sales_View s
JOIN Features_View f
  ON s.Store = f.Store AND s.Date = f.Date
GROUP BY 
    CASE 
        WHEN (f.MarkDown1 > 0 OR f.MarkDown2 > 0 OR f.MarkDown3 > 0 OR f.MarkDown4 > 0 OR f.MarkDown5 > 0)
             THEN 'Markdown_Applied'
        ELSE 'No_Markdown'
    END;


-- Top 3 Dates with highest total sales
SELECT TOP 3
	Date,
	ROUND(SUM(Weekly_Sales), 2) "Total Sales"
FROM Sales_View
GROUP BY Date 
ORDER BY "Total Sales";


-- Avg Weekly Sales during holiday and non holiday
SELECT	
	CASE 
		WHEN IsHoliday = 1 THEN 'Holiday'
		ELSE 'Non-Holiday'
	END "Day Status",
	AVG(Weekly_Sales) " Average Sales"
FROM Sales_View
GROUP BY 
	CASE
		WHEN IsHoliday = 1 THEN 'Holiday'
		ELSE 'Non-Holiday'
	END;


-- Highest Sale On holiday
SELECT TOP 1
	Date,
	ROUND(SUM(Weekly_Sales), 2) "Total Sales"
FROM Sales_View
WHERE ISHoliday = 1
GROUP BY Date
ORDER BY "Total Sales" DESC;


-- Stores performed best on holidays
SELECT 
	Stores_View.Type,
	ROUND(SUM(Sales_View.Weekly_Sales), 2) "Total Sales"
FROM Stores_View 
JOIN Sales_View
ON Stores_View.Store = Sales_View.Store
WHERE Sales_View.IsHoliday = 1
GROUP BY Stores_View.Type;


-- Holiday effect on fuel_price
SELECT
    CASE 
        WHEN Sales_View.IsHoliday = 1 THEN 'Holiday'
        ELSE 'Non-Holiday'
    END AS "Day Status",
    ROUND(AVG(Features_View.Fuel_Price), 2) AS "Fuel Price"
FROM Sales_View
JOIN Features_View
ON Sales_View.Store = Features_View.Store
AND Sales_View.Date = Features_View.Date
GROUP BY
    CASE 
        WHEN Sales_View.IsHoliday = 1 THEN 'Holiday'
        ELSE 'Non-Holiday'
    END;


-- Top Performaing Department for each store
SELECT 
    Type,
    Dept,
    Total_Sales
FROM (
    SELECT
        Stores_View.Type,
        Sales_View.Dept,
        ROUND(SUM(Sales_View.Weekly_Sales), 2) AS Total_Sales,
        ROW_NUMBER() OVER (PARTITION BY Stores_View.Type ORDER BY SUM(Sales_View.Weekly_Sales) DESC) AS dept_rank
    FROM Sales_View
    JOIN Stores_View
      ON Sales_View.Store = Stores_View.Store
    GROUP BY Stores_View.Type, Sales_View.Dept
) AS ranked_sales
WHERE dept_rank = 1
ORDER BY Type;


--  The rolling average of weekly sales (3-week window) for each department.
SELECT
    Store,
    Dept,
    Date,
    Weekly_Sales,
    ROUND(
        AVG(Weekly_Sales) OVER (PARTITION BY Dept ORDER BY Date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS Rolling_Avg_3Weeks
FROM Sales_View
ORDER BY Dept, Date;
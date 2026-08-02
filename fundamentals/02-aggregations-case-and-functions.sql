-- ============================================================
-- Module 02: Aggregations, GROUP BY, CASE Expressions & Functions
-- Description: Aggregate functions, GROUP BY/HAVING, CASE, String and DateTime functions
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- 1. AGGREGATIONS & GROUP BY
-- ------------------------------------------------------------

-- Aggregations & Null behavior (COUNT(*) vs COUNT(Column))
SELECT 
    COUNT(*) AS AllRows, 
    COUNT(Score) AS NonNullRows, 
    AVG(Score * 1.0) AS ScoreAvg
FROM dbo.GroupTable;
GO

-- Multi-Level GROUP BY with HAVING
SELECT 
    EmployeeID,
    COUNT(OrderID) AS Num
FROM dbo.Orders AS O
WHERE EmployeeID <> 8
GROUP BY EmployeeID
HAVING COUNT(OrderID) > 70;
GO


-- ------------------------------------------------------------
-- 2. CASE EXPRESSIONS & CUSTOM SORTING
-- ------------------------------------------------------------

-- Simple vs Searched CASE
SELECT 
    ProductID, UnitPrice,
    CASE
        WHEN UnitPrice < 50 THEN N'کمتر از 50'
        WHEN UnitPrice BETWEEN 50 AND 100 THEN N'بین 50 تا 100'
        ELSE N'بیشتر از 100'
    END AS UnitPriceCategory
FROM dbo.OrderDetails AS OD;
GO

-- Sorting NULLs at the end
SELECT CustomerID, Region
FROM dbo.Customers AS C
ORDER BY CASE WHEN Region IS NULL THEN 1 ELSE 0 END, Region, CustomerID DESC;
GO


-- ------------------------------------------------------------
-- 3. STRING & DATETIME FUNCTIONS
-- ------------------------------------------------------------

-- String Functions
SELECT LEN(N'سلام') AS CharCount, DATALENGTH(N'سلام') AS ByteSize;
SELECT SUBSTRING('My String', 1, 2) AS SubPart;
SELECT REPLACE('my-string-is-simple', '-', ' ') AS CleanString;
SELECT CONCAT(State, N'*', Region, N'*', City) AS LocationConcat FROM dbo.Customers;
GO

-- Date Conversions & Calculations
SELECT CAST('20160506' AS DATETIME) AS CastDate;
SELECT CONVERT(DATETIME, '20160506') AS ConvertDate;
SELECT 
    GETDATE() AS Today,
    DATEADD(month, 1, GETDATE()) AS NextMonth,
    DATEDIFF(day, '20140101', GETDATE()) AS DaysDifference;
GO

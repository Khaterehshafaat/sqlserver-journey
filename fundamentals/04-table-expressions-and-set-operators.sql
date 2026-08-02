-- ============================================================
-- Course: SQL Server Querying
-- Module 04: Table Expressions & Set Operators
-- Description: Derived Tables, Non-Recursive & Recursive CTEs, Set Operators (UNION, INTERSECT, EXCEPT)
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- 1. DERIVED TABLES & THREE RULES
-- ------------------------------------------------------------

SELECT Tmp.CompanyName, Tmp.Num
FROM (
    SELECT
        C.CompanyName,
        (
            SELECT COUNT(O.OrderID) 
            FROM dbo.Orders AS O
            WHERE C.CustomerID = O.CustomerID
            HAVING COUNT(O.OrderID) > 10
        ) AS Num
    FROM dbo.Customers AS C
) AS Tmp
WHERE Tmp.Num IS NOT NULL;
GO


-- ------------------------------------------------------------
-- 2. COMMON TABLE EXPRESSIONS (CTEs)
-- ------------------------------------------------------------

-- Non-Recursive CTE
WITH Tehran_Customers AS (
    SELECT C.CustomerID, C.CompanyName
    FROM dbo.Customers AS C
    WHERE C.City = N'تهران'
)
SELECT * FROM Tehran_Customers;
GO

-- Multiple CTEs (Yearly Growth Calculation)
WITH Current_Year AS (
    SELECT YEAR(OrderDate) AS OrderYear, COUNT(DISTINCT CustomerID) AS Cust_Num
    FROM dbo.Orders
    GROUP BY YEAR(OrderDate)
),
Previous_Year AS (
    SELECT YEAR(OrderDate) AS OrderYear, COUNT(DISTINCT CustomerID) AS Cust_Num
    FROM dbo.Orders
    GROUP BY YEAR(OrderDate)
)
SELECT
    CY.OrderYear, CY.Cust_Num,
    ISNULL(PY.Cust_Num, 0) AS Previous_Cust_Num,
    CY.Cust_Num - ISNULL(PY.Cust_Num, 0) AS Growth
FROM Current_Year AS CY
LEFT JOIN Previous_Year AS PY ON CY.OrderYear = PY.OrderYear + 1;
GO

-- Recursive CTE (Hierarchical Subordinates)
WITH Employees_CTE AS (
    SELECT EmployeeID, Mgrid, FirstName, LastName
    FROM dbo.Employees
    WHERE EmployeeID = 2 -- Anchor Member

    UNION ALL

    SELECT E.EmployeeID, E.Mgrid, E.FirstName, E.LastName
    FROM Employees_CTE AS Emp_CTE
    INNER JOIN dbo.Employees AS E ON E.mgrid = Emp_CTE.EmployeeID -- Recursive Member
)
SELECT * FROM Employees_CTE;
GO


-- ------------------------------------------------------------
-- 3. SET OPERATORS
-- ------------------------------------------------------------

-- UNION ALL (Keep duplicates) vs UNION (Distinct)
SELECT State, Region, City FROM dbo.Employees
UNION ALL
SELECT State, Region, City FROM dbo.Customers;
GO

-- INTERSECT (Common rows)
SELECT State, Region, City FROM dbo.Employees
INTERSECT
SELECT State, Region, City FROM dbo.Customers;
GO

-- EXCEPT (Difference)
SELECT State, Region, City FROM dbo.Employees
EXCEPT
SELECT State, Region, City FROM dbo.Customers;
GO

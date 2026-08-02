-- ============================================================
-- Module 01: SELECT Basics, WHERE Filtering, Sorting & Pagination
-- Description: Core SELECT statements, schema notation, operators, NULLs, TOP, OFFSET-FETCH
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- 1. SELECT BASICS & SCHEMAS
-- ------------------------------------------------------------

-- Literals and Calculations without a Table
SELECT 1 AS ConstantNum;
SELECT N'سحر' AS StringLiteral;
SELECT 10 / 2 AS CalculatedResult;
GO

-- Explicit Schema Notation & Table Aliases (AS)
SELECT 
    O.OrderID, 
    O.OrderDate, 
    O.Freight
FROM dbo.Orders AS O;
GO

-- Delimiters for identifiers with spaces
SELECT * FROM dbo.[Order Details];
GO


-- ------------------------------------------------------------
-- 2. WHERE CLAUSE & OPERATORS
-- ------------------------------------------------------------

-- In Predicate
SELECT CustomerID, EmployeeID, OrderID, OrderDate
FROM dbo.Orders AS O
WHERE O.OrderID IN (10248, 10253, 10320);
GO

-- Between Predicate
SELECT EmployeeID, OrderID
FROM dbo.Orders AS O
WHERE O.EmployeeID BETWEEN 3 AND 7;
GO

-- LIKE Pattern Matching
SELECT EmployeeID, FirstName, LastName
FROM dbo.Employees AS E
WHERE E.LastName LIKE N'ا%'; -- Starts with 'ا'
GO

SELECT EmployeeID, FirstName, LastName
FROM dbo.Employees AS E
WHERE E.LastName LIKE N'[ا-پ]%'; -- Character Range
GO

SELECT EmployeeID, FirstName, LastName
FROM dbo.Employees AS E
WHERE E.FirstName LIKE N'س__'; -- Exactly 3 characters starting with 'س'
GO

-- Arithmetic Operations & Precedence with Parentheses
SELECT 
    OrderID, ProductID, Qty, UnitPrice, Discount,
    Qty * UnitPrice * (1 - Discount) AS TotalVal
FROM dbo.OrderDetails AS OD;
GO


-- ------------------------------------------------------------
-- 3. SORTING, DISTINCT & PAGINATION
-- ------------------------------------------------------------

-- Multi-column Sorting (ASC / DESC)
SELECT EmployeeID, YEAR(OrderDate) AS OrderYear
FROM dbo.Orders AS O
WHERE O.CustomerID = 71
ORDER BY EmployeeID DESC, OrderYear ASC;
GO

-- DISTINCT Filtering
SELECT DISTINCT EmployeeID, YEAR(OrderDate) AS OrderYear
FROM dbo.Orders AS O
WHERE O.CustomerID = 71;
GO

-- TOP Filtering
SELECT TOP (5) WITH TIES 
    OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders AS O
ORDER BY O.OrderDate DESC;
GO

-- OFFSET-FETCH Paging (Skip 10, Fetch 5)
SELECT OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders AS O
ORDER BY O.OrderDate DESC, O.OrderID DESC
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;
GO


-- ------------------------------------------------------------
-- 4. NULL HANDLING & THREE-VALUED LOGIC (3VL)
-- ------------------------------------------------------------

SELECT CustomerID, State, Region, City
FROM dbo.Customers AS C
WHERE C.Region IS NULL;
GO

SELECT CustomerID, State, Region, City
FROM dbo.Customers AS C
WHERE ISNULL(C.Region, '') <> N'جنوب';
GO

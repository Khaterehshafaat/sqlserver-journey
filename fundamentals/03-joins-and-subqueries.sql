-- ============================================================
-- Course: SQL Server Querying
-- Module 03: JOINS & Subqueries
-- Description: CROSS, INNER, OUTER & SELF JOINs, Scalar, Multi-valued & Correlated Subqueries, EXISTS
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- 1. JOINS (CROSS, INNER, OUTER, SELF)
-- ------------------------------------------------------------

-- CROSS JOIN
SELECT C.CustomerID, E.EmployeeID
FROM dbo.Customers AS C
CROSS JOIN dbo.Employees AS E;
GO

-- INNER JOIN with Non-Equi Condition (Unique Employee Pairs)
SELECT
    E1.EmployeeID AS Emp1, E2.EmployeeID AS Emp2
FROM dbo.Employees AS E1
INNER JOIN dbo.Employees AS E2 ON E1.EmployeeID < E2.EmployeeID;
GO

-- LEFT OUTER JOIN (Find Customers without Orders)
SELECT C.CustomerID, C.CompanyName, O.OrderID
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL;
GO

-- SELF LEFT JOIN (Employees and their Direct Managers)
SELECT 
    E.EmployeeID,
    E.FirstName + N' ' + E.LastName AS EmployeeName,
    M.FirstName + N' ' + M.LastName AS ManagerName
FROM dbo.Employees AS E
LEFT JOIN dbo.Employees AS M ON E.mgrid = M.EmployeeID;
GO


-- ------------------------------------------------------------
-- 2. SUBQUERIES
-- ------------------------------------------------------------

-- Scalar Subquery in WHERE
SELECT EmployeeID, CustomerID, OrderID
FROM dbo.Orders
WHERE OrderID = (SELECT MAX(OrderID) FROM dbo.Orders);
GO

-- Multi-valued Subquery (IN / NOT IN)
SELECT EmployeeID, OrderID
FROM dbo.Orders
WHERE EmployeeID IN (
    SELECT E.EmployeeID 
    FROM dbo.Employees AS E 
    WHERE E.LastName LIKE N'ت%'
);
GO

-- Correlated Subquery & EXISTS
SELECT C.CustomerID, C.CompanyName
FROM dbo.Customers AS C
WHERE EXISTS (
    SELECT 1 
    FROM dbo.Orders AS O 
    WHERE O.CustomerID = C.CustomerID
);
GO







-- ------------------------------------------------------------
-- Finding the Newest Order of Each Customer (GROUP BY vs. Correlated Subquery)
-- ------------------------------------------------------------

-- Method 1: Using GROUP BY
SELECT 
    CustomerID, 
    MAX(OrderID) AS NewestOrderID
FROM dbo.Orders
GROUP BY CustomerID;
GO

-- Method 2: Global Max OrderID (Scalar Subquery - Note: Returns only 1 global max, not per customer)
SELECT 
    CustomerID, 
    OrderID
FROM dbo.Orders
WHERE OrderID = (SELECT MAX(OrderID) FROM dbo.Orders);
GO

-- Method 3: Correlated Subquery in SELECT (Using DISTINCT)
SELECT DISTINCT 
    O.CustomerID,
    (
        SELECT MAX(O1.OrderID) 
        FROM dbo.Orders AS O1 
        WHERE O1.CustomerID = O.CustomerID
    ) AS NewestOrderID
FROM dbo.Orders AS O;
GO

-- Method 4: Correlated Subquery in SELECT (Using GROUP BY)
SELECT
    O.CustomerID,
    (
        SELECT MAX(O1.OrderID) 
        FROM dbo.Orders AS O1 
        WHERE O1.CustomerID = O.CustomerID
    ) AS NewestOrderID
FROM dbo.Orders AS O
GROUP BY O.CustomerID;
GO

-- Method 5: Correlated Subquery on Customers table (Includes Customers with 0 Orders)
SELECT
    C.CustomerID,
    (
        SELECT MAX(O.OrderID) 
        FROM dbo.Orders AS O 
        WHERE O.CustomerID = C.CustomerID
    ) AS NewestOrderID
FROM dbo.Customers AS C;
GO

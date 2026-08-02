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

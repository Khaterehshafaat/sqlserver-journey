-- ============================================================
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
FROM Orders
GROUP BY CustomerID;
GO

-- Method 2: Global Max OrderID (Scalar Subquery)
SELECT 
    CustomerID, 
    OrderID
FROM Orders
WHERE OrderID = (SELECT MAX(OrderID) FROM Orders);
GO

-- Method 3: Correlated Subquery in SELECT (Using DISTINCT)
SELECT DISTINCT 
    O.CustomerID,
    (
        SELECT MAX(O1.OrderID) 
        FROM Orders AS O1 
        WHERE O1.CustomerID = O.CustomerID
    ) AS NewestOrderID
FROM Orders AS O;
GO

-- Method 4: Correlated Subquery in SELECT (Using GROUP BY)
SELECT
    O.CustomerID,
    (
        SELECT MAX(O1.OrderID) 
        FROM Orders AS O1 
        WHERE O1.CustomerID = O.CustomerID
    ) AS NewestOrderID
FROM Orders AS O
GROUP BY O.CustomerID;
GO

-- Method 5: Correlated Subquery on Customers table
SELECT
    C.CustomerID,
    (
        SELECT MAX(O.OrderID) 
        FROM Orders AS O 
        WHERE O.CustomerID = C.CustomerID
    ) AS NewestOrderID
FROM Customers AS C;
GO




-- ------------------------------------------------------------
-- All Customers Who Placed At Least One Order
-- Comparing INNER JOIN (with DISTINCT) vs. EXISTS
-- ------------------------------------------------------------

-- Method 1: Using INNER JOIN & DISTINCT
SELECT DISTINCT 
    C.CustomerID, 
    C.CompanyName
FROM Customers AS C 
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID;
GO

-- Method 2: Using EXISTS in WHERE clause
SELECT 
    C.CustomerID, 
    C.CompanyName
FROM Customers AS C 
WHERE EXISTS (
    SELECT 1 
    FROM Orders AS O 
    WHERE O.CustomerID = C.CustomerID
);
GO


-- ------------------------------------------------------------
-- All Customers Who Have NOT Placed Any Orders
-- Comparing NOT EXISTS vs. LEFT JOIN with IS NULL
-- ------------------------------------------------------------

-- Method 1: Using NOT EXISTS
SELECT 
    C.CustomerID, 
    C.CompanyName
FROM Customers AS C 
WHERE NOT EXISTS (
    SELECT 1 
    FROM Orders AS O 
    WHERE O.CustomerID = C.CustomerID
);
GO

-- Method 2: Using LEFT JOIN & IS NULL
SELECT 
    C.CustomerID, 
    C.CompanyName
FROM Customers AS C 
LEFT JOIN Orders AS O ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL;
GO




-- ------------------------------------------------------------
-- Class Exercise: Employees who processed orders for Customer #18
-- Comparing JOIN (with DISTINCT), IN Subquery, and EXISTS
-- ------------------------------------------------------------

-- Method 1: Using INNER JOIN & DISTINCT
SELECT DISTINCT 
    E.FirstName, 
    E.LastName, 
    O.CustomerID
FROM Employees AS E 
INNER JOIN Orders AS O ON E.EmployeeID = O.EmployeeID
WHERE O.CustomerID = 18;
GO

-- Method 2: Using Multi-Valued Subquery with IN
SELECT 
    E.FirstName, 
    E.LastName
FROM Employees AS E 
WHERE E.EmployeeID IN (
    SELECT EmployeeID 
    FROM Orders 
    WHERE CustomerID = 18
);
GO

-- Method 3: Using Correlated Subquery with EXISTS
SELECT 
    E.FirstName, 
    E.LastName
FROM Employees AS E 
WHERE EXISTS (
    SELECT 1 
    FROM Orders AS O 
    WHERE E.EmployeeID = O.EmployeeID 
      AND O.CustomerID = 18
);
GO

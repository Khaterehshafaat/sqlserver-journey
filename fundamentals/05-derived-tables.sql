-- ============================================================
-- Module 05: Derived Tables & Query Strategies
-- Description: Finding Customers with > 10 Orders using
--              JOINs, Correlated Subqueries, and Derived Tables
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- Problem: Retrieve Customers with More Than 10 Orders
-- ------------------------------------------------------------

-- Strategy 1: Standard INNER JOIN with GROUP BY & HAVING
SELECT 
    C.CustomerID, 
    COUNT(O.OrderID) AS NUM
FROM Customers AS C 
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
HAVING COUNT(O.OrderID) > 10;
GO

-- Strategy 2: Correlated Subquery in SELECT with GROUP BY on Orders
SELECT 
    (
        SELECT C.CompanyName 
        FROM Customers AS C 
        WHERE C.CustomerID = O.CustomerID
    ) AS COMPANYNAME,
    COUNT(O.OrderID) AS NUM
FROM Orders AS O
GROUP BY O.CustomerID
HAVING COUNT(O.OrderID) > 10;
GO

-- Strategy 3: Subquery on Customers with HAVING
-- Note: Returns NULL for customers with <= 10 orders
SELECT 
    C.CompanyName, 
    (
        SELECT COUNT(OrderID) 
        FROM Orders AS O 
        WHERE C.CustomerID = O.CustomerID 
        HAVING COUNT(O.OrderID) > 10
    ) AS ORDERNUM
FROM Customers AS C
GROUP BY C.CompanyName, C.CustomerID;
GO

-- Strategy 4: Using Derived Table to Filter NULLs (Approach 1)
SELECT 
    SB.ORDERNUM, 
    SB.COMPANYNAME
FROM (
    SELECT 
        C.CompanyName, 
        (
            SELECT COUNT(OrderID) 
            FROM Orders AS O 
            WHERE C.CustomerID = O.CustomerID 
            HAVING COUNT(O.OrderID) > 10
        ) AS ORDERNUM
    FROM Customers AS C
    GROUP BY C.CompanyName, C.CustomerID
) AS SB 
WHERE SB.ORDERNUM IS NOT NULL;
GO

-- Strategy 5 (Smarter Approach): Derived Table with Outer WHERE Filter (> 10)
SELECT 
    SB.ORDERNUM, 
    SB.COMPANYNAME
FROM (
    SELECT 
        C.CompanyName, 
        (
            SELECT COUNT(OrderID) 
            FROM Orders AS O 
            WHERE C.CustomerID = O.CustomerID
        ) AS ORDERNUM
    FROM Customers AS C
    GROUP BY C.CompanyName, C.CustomerID
) AS SB 
WHERE SB.ORDERNUM > 10;
GO

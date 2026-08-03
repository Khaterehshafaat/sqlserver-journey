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






-- ============================================================
-- Module 05: Derived Tables & Class Exercises
-- Description: Finding Customers who ordered more than 5 product 
--              items in a single order invoice using JOINs, 
--              Subqueries, and Derived Tables
-- ============================================================

USE TehranDataDB;
GO

-- ------------------------------------------------------------
-- Class Exercise: Identify Customers with > 5 Item Types per Invoice
-- ------------------------------------------------------------

-- Method 1: Using Multi-table INNER JOINs with GROUP BY & HAVING
SELECT 
    C.CustomerID, 
    O.OrderID,
    COUNT(OD.OrderID) AS NUMORDER
FROM Customers AS C 
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, O.OrderID
HAVING COUNT(OD.OrderID) > 5;
GO

-- Method 2: Using a Derived Table with Correlated Subquery
SELECT DISTINCT 
    DD.CustomerID,
    DD.NUM
FROM (
    SELECT
        O.CustomerID, 
        (
            SELECT COUNT(OD.OrderID) 
            FROM OrderDetails AS OD 
            WHERE OD.OrderID = O.OrderID
        ) AS NUM
    FROM Orders AS O
) AS DD
WHERE DD.NUM IS NOT NULL 
  AND DD.NUM > 5;
GO

-- Method 3: Using Subquery in SELECT with GROUP BY on OrderDetails
SELECT DISTINCT 
    (
        SELECT O.CustomerID 
        FROM Orders AS O 
        WHERE O.OrderID = OD.OrderID
    ) AS CUSTOMERS,
    COUNT(OD.OrderID) AS NUM
FROM OrderDetails AS OD
GROUP BY OD.OrderID
HAVING COUNT(OD.OrderID) > 5;
GO



-- ------------------------------------------------------------
-- Count of Distinct Customers Per Order Year Using a Derived Table
-- ------------------------------------------------------------

SELECT 
    OO.OrderYear, 
    COUNT(DISTINCT OO.CustomerID) AS CustomerCount
FROM (
    SELECT 
        YEAR(O.OrderDate) AS OrderYear, 
        O.CustomerID
    FROM Orders AS O
) AS OO
GROUP BY OO.OrderYear;
GO


-- ============================================================
-- Module 06: ctes
-- ============================================================
--corrected SQL query
WITH CUST_CP AS (
    SELECT 
        YEAR(O.OrderDate) AS ORDERYEAR, 
        COUNT(DISTINCT O.CustomerID) AS NUM
    FROM Orders AS O
    GROUP BY YEAR(O.OrderDate)
)
SELECT 
    C.ORDERYEAR, 
    C.NUM,
    ISNULL(C2.NUM, 0) AS previousnum, 
    C.NUM - ISNULL(C2.NUM, 0) AS growth
FROM CUST_CP AS C 
LEFT JOIN CUST_CP AS C2
    ON C.ORDERYEAR = C2.ORDERYEAR + 1;
--Alternative using Window Functions (LAG)
WITH CUST_CP AS (
    SELECT 
        YEAR(O.OrderDate) AS ORDERYEAR, 
        COUNT(DISTINCT O.CustomerID) AS NUM
    FROM Orders AS O
    GROUP BY YEAR(O.OrderDate)
)
SELECT 
    ORDERYEAR,
    NUM,
    ISNULL(LAG(NUM) OVER (ORDER BY ORDERYEAR), 0) AS previousnum,
    NUM - ISNULL(LAG(NUM) OVER (ORDER BY ORDERYEAR), 0) AS growth
FROM CUST_CP;





-- SQL Server | Using CTEs and Correlated Subqueries to Find Customers with Orders Containing More Than 5 Items

WITH CT1 AS (
    SELECT 
        O.CustomerID,
        (
            SELECT COUNT(OD.OrderID)
            FROM OrderDetails AS OD
            WHERE OD.OrderID = O.OrderID
        ) AS NUM
    FROM Orders AS O
),
CT2 AS (
    SELECT 
        C.CustomerID,
        C.NUM
    FROM CT1 AS C
    WHERE C.NUM > 5
)
SELECT DISTINCT
    T.CustomerID
FROM CT2 AS T;





-- SQL Server | Recursive CTE to Generate Numbers from 1 to 100

;WITH CTE AS
(
    -- Anchor Member
    SELECT 1 AS NUM

    UNION ALL

    -- Recursive Member
    SELECT NUM + 1
    FROM CTE
    WHERE NUM < 100
)
SELECT *
FROM CTE;




-- SQL Server | Recursive CTE to Display All Subordinates of Employee 5

;WITH EMPLOYEE_CTE AS
(
    -- Anchor Member: Start with Employee 5
    SELECT
        EmployeeID,
        mgrid,
        FirstName,
        LastName
    FROM Employees
    WHERE EmployeeID = 5

    UNION ALL

    -- Recursive Member: Find employees who report to the current employee
    SELECT
        E.EmployeeID,
        E.mgrid,
        E.FirstName,
        E.LastName
    FROM EMPLOYEE_CTE AS EMP_CTE
    INNER JOIN Employees AS E
        ON E.mgrid = EMP_CTE.EmployeeID
)
SELECT *
FROM EMPLOYEE_CTE;

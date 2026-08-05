
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

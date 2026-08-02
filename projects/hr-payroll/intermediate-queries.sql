-- ============================================================
-- HR & Payroll SQL Server Case Study
-- Level: Intermediate Questions (Questions 16 to 35)
-- Each question includes 3 solutions: Standard Query, Subquery, and CTE
-- ============================================================


-- ------------------------------------------------------------
-- Question 16: Employees with salary above company average
-- Show employees whose BaseSalary is higher than the overall average BaseSalary
-- ------------------------------------------------------------

-- Solution 1: Standard Query (CROSS JOIN)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
CROSS JOIN (
    SELECT AVG(BaseSalary) AS CompanyAvg 
    FROM Employees
) AS x
WHERE e.BaseSalary > x.CompanyAvg;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
WHERE e.BaseSalary > (
    SELECT AVG(e2.BaseSalary) 
    FROM Employees AS e2
);

-- Solution 3: CTE
WITH CompanyAvg AS (
    SELECT AVG(BaseSalary) AS AvgSalary 
    FROM Employees
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
CROSS JOIN CompanyAvg AS c
WHERE e.BaseSalary > c.AvgSalary;


-- ------------------------------------------------------------
-- Question 17: Employees with salary above their department average
-- Find employees whose BaseSalary is higher than their department's average
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Window Function)
SELECT 
    x.EmployeeID,
    x.FullName,
    x.DepartmentName,
    x.BaseSalary,
    x.DeptAvg
FROM (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        d.DepartmentName,
        e.BaseSalary,
        AVG(e.BaseSalary) OVER (PARTITION BY e.DepartmentID) AS DeptAvg
    FROM Employees AS e
    INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
) AS x
WHERE x.BaseSalary > x.DeptAvg;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
WHERE e.BaseSalary > (
    SELECT AVG(e2.BaseSalary)
    FROM Employees AS e2
    WHERE e2.DepartmentID = e.DepartmentID
);

-- Solution 3: CTE
WITH DeptAvg AS (
    SELECT 
        DepartmentID,
        AVG(BaseSalary) AS AvgSalary
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary,
    da.AvgSalary
FROM Employees AS e
INNER JOIN DeptAvg AS da ON da.DepartmentID = e.DepartmentID
WHERE e.BaseSalary > da.AvgSalary;


-- ------------------------------------------------------------
-- Question 18: Top 3 employees by Base Salary
-- Display top 3 employees based on BaseSalary
-- ------------------------------------------------------------

-- Solution 1: Standard Query (TOP)
SELECT TOP (3)
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
ORDER BY e.BaseSalary DESC;

-- Solution 2: Subquery
SELECT 
    x.EmployeeID,
    x.FullName,
    x.BaseSalary
FROM (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.BaseSalary,
        (
            SELECT COUNT(*) 
            FROM Employees AS e2 
            WHERE e2.BaseSalary > e.BaseSalary
        ) AS HigherCount
    FROM Employees AS e
) AS x
WHERE x.HigherCount < 3
ORDER BY x.BaseSalary DESC;

-- Solution 3: CTE (ROW_NUMBER)
WITH Ranked AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.BaseSalary,
        ROW_NUMBER() OVER (ORDER BY e.BaseSalary DESC) AS rn
    FROM Employees AS e
)
SELECT EmployeeID, FullName, BaseSalary
FROM Ranked
WHERE rn <= 3
ORDER BY BaseSalary DESC;


-- ------------------------------------------------------------
-- Question 19: Salary ranking within each Department
-- Rank employees in each department based on BaseSalary
-- ------------------------------------------------------------

-- Solution 1: Standard Query (DENSE_RANK)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    d.DepartmentName,
    e.BaseSalary,
    DENSE_RANK() OVER (
        PARTITION BY e.DepartmentID 
        ORDER BY e.BaseSalary DESC
    ) AS SalaryRank
FROM Employees AS e
INNER JOIN Departments AS d ON d.DepartmentID = e.DepartmentID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary,
    1 + (
        SELECT COUNT(DISTINCT e2.BaseSalary)
        FROM Employees AS e2
        WHERE e2.DepartmentID = e.DepartmentID 
          AND e2.BaseSalary > e.BaseSalary
    ) AS SalaryRank
FROM Employees AS e;

-- Solution 3: CTE
WITH Ranked AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.DepartmentID,
        e.BaseSalary,
        DENSE_RANK() OVER (
            PARTITION BY e.DepartmentID 
            ORDER BY e.BaseSalary DESC
        ) AS SalaryRank
    FROM Employees AS e
)
SELECT * FROM Ranked;


-- ------------------------------------------------------------
-- Question 20: Second highest salary in each Department
-- Show employee(s) who have the second highest salary per department
-- ------------------------------------------------------------

-- Solution 1: Standard Query (DENSE_RANK Subquery)
SELECT 
    x.DepartmentID,
    x.FullName,
    x.BaseSalary
FROM (
    SELECT 
        e.DepartmentID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.BaseSalary,
        DENSE_RANK() OVER (
            PARTITION BY e.DepartmentID 
            ORDER BY e.BaseSalary DESC
        ) AS rk
    FROM Employees AS e
) AS x
WHERE x.rk = 2;

-- Solution 2: Subquery
SELECT 
    e.DepartmentID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary
FROM Employees AS e
WHERE 1 = (
    SELECT COUNT(DISTINCT e2.BaseSalary)
    FROM Employees AS e2
    WHERE e2.DepartmentID = e.DepartmentID 
      AND e2.BaseSalary > e.BaseSalary
);

-- Solution 3: CTE
WITH Ranked AS (
    SELECT 
        e.DepartmentID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.BaseSalary,
        DENSE_RANK() OVER (
            PARTITION BY e.DepartmentID 
            ORDER BY e.BaseSalary DESC
        ) AS rk
    FROM Employees AS e
)
SELECT DepartmentID, FullName, BaseSalary
FROM Ranked
WHERE rk = 2;


-- ------------------------------------------------------------
-- Question 21: Department with highest average Base Salary
-- Find the department that has the highest average BaseSalary
-- ------------------------------------------------------------

-- Solution 1: Standard Query (TOP 1)
SELECT TOP (1)
    d.DepartmentName,
    AVG(e.BaseSalary) AS AvgBaseSalary
FROM Departments AS d
INNER JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY AVG(e.BaseSalary) DESC;

-- Solution 2: Subquery
SELECT 
    x.DepartmentName,
    x.AvgBaseSalary
FROM (
    SELECT 
        d.DepartmentName,
        (
            SELECT AVG(e.BaseSalary) 
            FROM Employees AS e 
            WHERE e.DepartmentID = d.DepartmentID
        ) AS AvgBaseSalary
    FROM Departments AS d
) AS x
WHERE x.AvgBaseSalary = (
    SELECT MAX(y.AvgBaseSalary)
    FROM (
        SELECT (
            SELECT AVG(e2.BaseSalary) 
            FROM Employees AS e2 
            WHERE e2.DepartmentID = d2.DepartmentID
        ) AS AvgBaseSalary
        FROM Departments AS d2
    ) AS y
);

-- Solution 3: CTE
WITH DeptAvg AS (
    SELECT 
        d.DepartmentName,
        AVG(e.BaseSalary) AS AvgBaseSalary
    FROM Departments AS d
    INNER JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentName
)
SELECT TOP (1)
    DepartmentName,
    AvgBaseSalary
FROM DeptAvg
ORDER BY AvgBaseSalary DESC;


-- ------------------------------------------------------------
-- Question 22: Department share percentage of total employees
-- Show each department's headcount share percentage
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Window COUNT)
SELECT 
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    COUNT(e.EmployeeID) * 100.0 / NULLIF(COUNT(*) OVER (), 0) AS PercentOfAllRows
FROM Departments AS d
LEFT JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    (
        SELECT COUNT(*) 
        FROM Employees AS e 
        WHERE e.DepartmentID = d.DepartmentID
    ) * 100.0 / NULLIF((SELECT COUNT(*) FROM Employees), 0) AS DeptPercent
FROM Departments AS d;

-- Solution 3: CTE
WITH DeptCounts AS (
    SELECT 
        DepartmentID,
        COUNT(*) AS EmployeeCount
    FROM Employees
    GROUP BY DepartmentID
),
TotalCount AS (
    SELECT COUNT(*) AS AllEmployees FROM Employees
)
SELECT 
    d.DepartmentName,
    ISNULL(dc.EmployeeCount, 0) * 100.0 / NULLIF(tc.AllEmployees, 0) AS DeptPercent
FROM Departments AS d
LEFT JOIN DeptCounts AS dc ON dc.DepartmentID = d.DepartmentID
CROSS JOIN TotalCount AS tc;


-- ------------------------------------------------------------
-- Question 23: Total Net Salary per Month/Fiscal Year
-- Calculate sum of NetSalary for each fiscal year and month
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    p.FiscalYear,
    p.FiscalMonth,
    SUM(sp.NetSalary) AS TotalNetSalary
FROM SalaryPayments AS sp
INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
GROUP BY p.FiscalYear, p.FiscalMonth
ORDER BY p.FiscalYear, p.FiscalMonth;

-- Solution 2: Subquery
SELECT 
    p.FiscalYear,
    p.FiscalMonth,
    (
        SELECT SUM(sp.NetSalary)
        FROM SalaryPayments AS sp
        WHERE sp.PeriodID = p.PeriodID
    ) AS TotalNetSalary
FROM PayrollPeriods AS p;

-- Solution 3: CTE
WITH MonthlyNet AS (
    SELECT 
        p.FiscalYear,
        p.FiscalMonth,
        SUM(sp.NetSalary) AS TotalNetSalary
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
    GROUP BY p.FiscalYear, p.FiscalMonth
)
SELECT * FROM MonthlyNet
ORDER BY FiscalYear, FiscalMonth;


-- ------------------------------------------------------------
-- Question 24: Employees paid in ALL payroll periods
-- Find employees who have a payment record for every registered period
-- ------------------------------------------------------------

-- Solution 1: Standard Query (HAVING)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
CROSS JOIN PayrollPeriods AS p
LEFT JOIN SalaryPayments AS sp ON sp.EmployeeID = e.EmployeeID AND sp.PeriodID = p.PeriodID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
HAVING COUNT(p.PeriodID) = COUNT(sp.PaymentID);

-- Solution 2: Subquery (NOT EXISTS)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
WHERE NOT EXISTS (
    SELECT 1 
    FROM PayrollPeriods AS p
    WHERE NOT EXISTS (
        SELECT 1 
        FROM SalaryPayments AS sp 
        WHERE sp.EmployeeID = e.EmployeeID 
          AND sp.PeriodID = p.PeriodID
    )
);

-- Solution 3: CTE
WITH EmployeePeriods AS (
    SELECT 
        EmployeeID,
        COUNT(DISTINCT PeriodID) AS PaidPeriods
    FROM SalaryPayments
    GROUP BY EmployeeID
),
TotalPeriods AS (
    SELECT COUNT(*) AS PeriodCount FROM PayrollPeriods
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
INNER JOIN EmployeePeriods AS ep ON ep.EmployeeID = e.EmployeeID
CROSS JOIN TotalPeriods AS tp
WHERE ep.PaidPeriods = tp.PeriodCount;


-- ------------------------------------------------------------
-- Question 25: Employees with NO leave requests
-- Display employees who do not have any record in LeaveRequests
-- ------------------------------------------------------------

-- Solution 1: Standard Query (LEFT JOIN)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
LEFT JOIN LeaveRequests AS l ON l.EmployeeID = e.EmployeeID
WHERE l.LeaveID IS NULL;

-- Solution 2: Subquery (NOT EXISTS)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
WHERE NOT EXISTS (
    SELECT 1 
    FROM LeaveRequests AS l 
    WHERE l.EmployeeID = e.EmployeeID
);

-- Solution 3: CTE
WITH HasLeave AS (
    SELECT DISTINCT EmployeeID 
    FROM LeaveRequests
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
LEFT JOIN HasLeave AS h ON h.EmployeeID = e.EmployeeID
WHERE h.EmployeeID IS NULL;


-- ------------------------------------------------------------
-- Question 26: Over 10 overtime hours in a single period
-- Show employees who logged > 10 overtime hours in any period
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    a.EmployeeID,
    a.PeriodID,
    SUM(a.OvertimeHours) AS TotalOvertime
FROM Attendance AS a
GROUP BY a.EmployeeID, a.PeriodID
HAVING SUM(a.OvertimeHours) > 10;

-- Solution 2: Subquery
SELECT 
    x.EmployeeID,
    x.PeriodID,
    x.TotalOvertime
FROM (
    SELECT DISTINCT 
        a.EmployeeID,
        a.PeriodID,
        (
            SELECT SUM(a2.OvertimeHours)
            FROM Attendance AS a2
            WHERE a2.EmployeeID = a.EmployeeID 
              AND a2.PeriodID = a.PeriodID
        ) AS TotalOvertime
    FROM Attendance AS a
) AS x
WHERE x.TotalOvertime > 10;

-- Solution 3: CTE
WITH OvertimeByPeriod AS (
    SELECT 
        EmployeeID,
        PeriodID,
        SUM(OvertimeHours) AS TotalOvertime
    FROM Attendance
    GROUP BY EmployeeID, PeriodID
)
SELECT * 
FROM OvertimeByPeriod
WHERE TotalOvertime > 10;


-- ------------------------------------------------------------
-- Question 27: Total late minutes per Employee
-- Calculate sum of LateMinutes for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    SUM(a.LateMinutes) AS TotalLateMinutes
FROM Employees AS e
INNER JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT SUM(a.LateMinutes)
        FROM Attendance AS a
        WHERE a.EmployeeID = e.EmployeeID
    ) AS TotalLateMinutes
FROM Employees AS e;

-- Solution 3: CTE
WITH LateSum AS (
    SELECT 
        EmployeeID,
        SUM(LateMinutes) AS TotalLateMinutes
    FROM Attendance
    GROUP BY EmployeeID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    ISNULL(ls.TotalLateMinutes, 0) AS TotalLateMinutes
FROM Employees AS e
LEFT JOIN LateSum AS ls ON ls.EmployeeID = e.EmployeeID;


-- ------------------------------------------------------------
-- Question 28: Employees whose Net Salary increased from previous period
-- Display rows where NetSalary is higher than the employee's previous period
-- ------------------------------------------------------------

-- Solution 1: Standard Query (LAG Window Function)
SELECT 
    x.EmployeeID,
    x.PeriodID,
    x.NetSalary,
    x.PrevNetSalary
FROM (
    SELECT 
        sp.EmployeeID,
        sp.PeriodID,
        sp.NetSalary,
        LAG(sp.NetSalary) OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY p.FiscalYear, p.FiscalMonth
        ) AS PrevNetSalary
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
) AS x
WHERE x.NetSalary > x.PrevNetSalary;

-- Solution 2: Subquery
SELECT 
    sp.EmployeeID,
    sp.PeriodID,
    sp.NetSalary
FROM SalaryPayments AS sp
INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
WHERE sp.NetSalary > (
    SELECT TOP 1 sp2.NetSalary
    FROM SalaryPayments AS sp2
    INNER JOIN PayrollPeriods AS p2 ON p2.PeriodID = sp2.PeriodID
    WHERE sp2.EmployeeID = sp.EmployeeID
      AND (
          p2.FiscalYear < p.FiscalYear 
          OR (p2.FiscalYear = p.FiscalYear AND p2.FiscalMonth < p.FiscalMonth)
      )
    ORDER BY p2.FiscalYear DESC, p2.FiscalMonth DESC
);

-- Solution 3: CTE
WITH OrderedPayments AS (
    SELECT 
        sp.EmployeeID,
        sp.PeriodID,
        sp.NetSalary,
        p.FiscalYear,
        p.FiscalMonth,
        LAG(sp.NetSalary) OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY p.FiscalYear, p.FiscalMonth
        ) AS PrevNetSalary
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
)
SELECT 
    EmployeeID,
    PeriodID,
    NetSalary,
    PrevNetSalary
FROM OrderedPayments
WHERE NetSalary > PrevNetSalary;


-- ------------------------------------------------------------
-- Question 29: Compare employee salary with Job Range
-- Check if BaseSalary is Below Range, Above Range, or In Range for their Job
-- ------------------------------------------------------------

-- Solution 1: Standard Query (CASE Expression)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    j.JobTitle,
    e.BaseSalary,
    j.MinSalary,
    j.MaxSalary,
    CASE 
        WHEN e.BaseSalary < j.MinSalary THEN N'Below Range'
        WHEN e.BaseSalary > j.MaxSalary THEN N'Above Range'
        ELSE N'In Range'
    END AS SalaryStatus
FROM Employees AS e
INNER JOIN Jobs AS j ON j.JobID = e.JobID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary,
    (SELECT j.MinSalary FROM Jobs AS j WHERE j.JobID = e.JobID) AS MinSalary,
    (SELECT j.MaxSalary FROM Jobs AS j WHERE j.JobID = e.JobID) AS MaxSalary
FROM Employees AS e;

-- Solution 3: CTE
WITH JobRange AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        j.JobTitle,
        e.BaseSalary,
        j.MinSalary,
        j.MaxSalary
    FROM Employees AS e
    INNER JOIN Jobs AS j ON j.JobID = e.JobID
)
SELECT 
    EmployeeID,
    FullName,
    JobTitle,
    BaseSalary,
    MinSalary,
    MaxSalary,
    CASE 
        WHEN BaseSalary < MinSalary THEN N'Below Range'
        WHEN BaseSalary > MaxSalary THEN N'Above Range'
        ELSE N'In Range'
    END AS SalaryStatus
FROM JobRange;


-- ------------------------------------------------------------
-- Question 30: Salary Gap in each Department
-- Difference between Maximum and Minimum BaseSalary in each department
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    d.DepartmentName,
    MAX(e.BaseSalary) - MIN(e.BaseSalary) AS SalaryGap
FROM Departments AS d
INNER JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    (
        SELECT MAX(e.BaseSalary) - MIN(e.BaseSalary)
        FROM Employees AS e
        WHERE e.DepartmentID = d.DepartmentID
    ) AS SalaryGap
FROM Departments AS d;

-- Solution 3: CTE
WITH DeptGap AS (
    SELECT 
        DepartmentID,
        MAX(BaseSalary) - MIN(BaseSalary) AS SalaryGap
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    d.DepartmentName,
    dg.SalaryGap
FROM Departments AS d
LEFT JOIN DeptGap AS dg ON dg.DepartmentID = d.DepartmentID;


-- ------------------------------------------------------------
-- Question 31: Average Net Salary of last 3 periods per Employee
-- Calculate average NetSalary across last 3 periods for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query (ROW_NUMBER Subquery)
SELECT 
    x.EmployeeID,
    AVG(x.NetSalary) AS AvgLast3NetSalary
FROM (
    SELECT 
        sp.EmployeeID,
        sp.NetSalary,
        ROW_NUMBER() OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY p.FiscalYear DESC, p.FiscalMonth DESC
        ) AS rn
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
) AS x
WHERE x.rn <= 3
GROUP BY x.EmployeeID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    (
        SELECT AVG(y.NetSalary)
        FROM (
            SELECT TOP (3) sp.NetSalary
            FROM SalaryPayments AS sp
            INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
            WHERE sp.EmployeeID = e.EmployeeID
            ORDER BY p.FiscalYear DESC, p.FiscalMonth DESC
        ) AS y
    ) AS AvgLast3NetSalary
FROM Employees AS e;

-- Solution 3: CTE
WITH RankedPayments AS (
    SELECT 
        sp.EmployeeID,
        sp.NetSalary,
        ROW_NUMBER() OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY p.FiscalYear DESC, p.FiscalMonth DESC
        ) AS rn
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
)
SELECT 
    EmployeeID,
    AVG(NetSalary) AS AvgLast3NetSalary
FROM RankedPayments
WHERE rn <= 3
GROUP BY EmployeeID;


-- ------------------------------------------------------------
-- Question 32: Last leave request for each Employee
-- Display latest leave request based on RequestDate for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query (MAX Date Filter)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    l.LeaveType,
    l.RequestDate
FROM Employees AS e
INNER JOIN LeaveRequests AS l ON l.EmployeeID = e.EmployeeID
WHERE l.RequestDate = (
    SELECT MAX(l2.RequestDate)
    FROM LeaveRequests AS l2
    WHERE l2.EmployeeID = e.EmployeeID
);

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT TOP 1 l2.LeaveType
        FROM LeaveRequests AS l2
        WHERE l2.EmployeeID = e.EmployeeID
        ORDER BY l2.RequestDate DESC
    ) AS LastLeaveType,
    (
        SELECT MAX(l3.RequestDate)
        FROM LeaveRequests AS l3
        WHERE l3.EmployeeID = e.EmployeeID
    ) AS LastRequestDate
FROM Employees AS e;

-- Solution 3: CTE
WITH RankedLeaves AS (
    SELECT 
        l.*,
        ROW_NUMBER() OVER (
            PARTITION BY l.EmployeeID 
            ORDER BY l.RequestDate DESC
        ) AS rn
    FROM LeaveRequests AS l
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    rl.LeaveType,
    rl.RequestDate
FROM Employees AS e
INNER JOIN RankedLeaves AS rl ON rl.EmployeeID = e.EmployeeID AND rl.rn = 1;


-- ------------------------------------------------------------
-- Question 33: Remote work days count per Period
-- Count total Attendance records with IsRemote = 1 for each period
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    PeriodID,
    COUNT(*) AS RemoteDays
FROM Attendance
WHERE IsRemote = 1
GROUP BY PeriodID;

-- Solution 2: Subquery
SELECT 
    p.PeriodID,
    (
        SELECT COUNT(*)
        FROM Attendance AS a
        WHERE a.PeriodID = p.PeriodID 
          AND a.IsRemote = 1
    ) AS RemoteDays
FROM PayrollPeriods AS p;

-- Solution 3: CTE
WITH RemoteCounts AS (
    SELECT 
        PeriodID,
        COUNT(*) AS RemoteDays
    FROM Attendance
    WHERE IsRemote = 1
    GROUP BY PeriodID
)
SELECT 
    p.PeriodID,
    ISNULL(rc.RemoteDays, 0) AS RemoteDays
FROM PayrollPeriods AS p
LEFT JOIN RemoteCounts AS rc ON rc.PeriodID = p.PeriodID;


-- ------------------------------------------------------------
-- Question 34: Employees with BOTH Bonuses and Deductions in same Period
-- Show employees who have records in both Bonuses and Deductions in a period
-- ------------------------------------------------------------

-- Solution 1: Standard Query (INNER JOIN)
SELECT DISTINCT 
    b.EmployeeID,
    b.PeriodID
FROM Bonuses AS b
INNER JOIN Deductions AS d ON d.EmployeeID = b.EmployeeID AND d.PeriodID = b.PeriodID;

-- Solution 2: Subquery (EXISTS)
SELECT DISTINCT 
    b.EmployeeID,
    b.PeriodID
FROM Bonuses AS b
WHERE EXISTS (
    SELECT 1 
    FROM Deductions AS d 
    WHERE d.EmployeeID = b.EmployeeID 
      AND d.PeriodID = b.PeriodID
);

-- Solution 3: CTE
WITH BonusPeriods AS (
    SELECT DISTINCT EmployeeID, PeriodID FROM Bonuses
),
DeductionPeriods AS (
    SELECT DISTINCT EmployeeID, PeriodID FROM Deductions
)
SELECT 
    bp.EmployeeID,
    bp.PeriodID
FROM BonusPeriods AS bp
INNER JOIN DeductionPeriods AS dp ON dp.EmployeeID = bp.EmployeeID AND dp.PeriodID = bp.PeriodID;


-- ------------------------------------------------------------
-- Question 35: Maximum Bonus Amount in each Period
-- Display highest bonus amount for every period
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    PeriodID,
    MAX(Amount) AS MaxBonusAmount
FROM Bonuses
GROUP BY PeriodID;

-- Solution 2: Subquery
SELECT 
    p.PeriodID,
    (
        SELECT MAX(b.Amount)
        FROM Bonuses AS b
        WHERE b.PeriodID = p.PeriodID
    ) AS MaxBonusAmount
FROM PayrollPeriods AS p;

-- Solution 3: CTE
WITH MaxBonus AS (
    SELECT 
        PeriodID,
        MAX(Amount) AS MaxBonusAmount
    FROM Bonuses
    GROUP BY PeriodID
)
SELECT 
    p.PeriodID,
    mb.MaxBonusAmount
FROM PayrollPeriods AS p
LEFT JOIN MaxBonus AS mb ON mb.PeriodID = p.PeriodID;

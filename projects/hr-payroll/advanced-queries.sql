-- ============================================================
-- HR & Payroll SQL Server Case Study
-- Level: Advanced Questions (Questions 36 to 50)
-- Each question includes 3 solutions: Standard Query, Subquery, and CTE
-- ============================================================


-- ------------------------------------------------------------
-- Question 36: Tax Ratio over 10% of Gross Salary
-- Show payments where TaxAmount / GrossSalary > 0.10
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    sp.PaymentID,
    sp.EmployeeID,
    sp.GrossSalary,
    sp.TaxAmount,
    sp.TaxAmount / NULLIF(sp.GrossSalary, 0) AS TaxRatio
FROM SalaryPayments AS sp
WHERE sp.TaxAmount / NULLIF(sp.GrossSalary, 0) > 0.10;

-- Solution 2: Subquery
SELECT 
    sp.PaymentID,
    sp.EmployeeID,
    sp.GrossSalary,
    sp.TaxAmount
FROM SalaryPayments AS sp
WHERE (
    SELECT sp2.TaxAmount / NULLIF(sp2.GrossSalary, 0)
    FROM SalaryPayments AS sp2
    WHERE sp2.PaymentID = sp.PaymentID
) > 0.10;

-- Solution 3: CTE
WITH TaxCalc AS (
    SELECT 
        PaymentID,
        EmployeeID,
        GrossSalary,
        TaxAmount,
        TaxAmount / NULLIF(GrossSalary, 0) AS TaxRatio
    FROM SalaryPayments
)
SELECT * 
FROM TaxCalc
WHERE TaxRatio > 0.10;


-- ------------------------------------------------------------
-- Question 37: Departments with Budget lower than Total Base Salary
-- Show departments where BudgetAmount < SUM(BaseSalary) of their employees
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    d.DepartmentName,
    d.BudgetAmount,
    SUM(e.BaseSalary) AS TotalBaseSalary
FROM Departments AS d
INNER JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName, d.BudgetAmount
HAVING d.BudgetAmount < SUM(e.BaseSalary);

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    d.BudgetAmount,
    (
        SELECT SUM(e.BaseSalary)
        FROM Employees AS e
        WHERE e.DepartmentID = d.DepartmentID
    ) AS TotalBaseSalary
FROM Departments AS d
WHERE d.BudgetAmount < (
    SELECT SUM(e.BaseSalary)
    FROM Employees AS e
    WHERE e.DepartmentID = d.DepartmentID
);

-- Solution 3: CTE
WITH DeptPayroll AS (
    SELECT 
        DepartmentID,
        SUM(BaseSalary) AS TotalBaseSalary
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    d.DepartmentName,
    d.BudgetAmount,
    dp.TotalBaseSalary
FROM Departments AS d
INNER JOIN DeptPayroll AS dp ON dp.DepartmentID = d.DepartmentID
WHERE d.BudgetAmount < dp.TotalBaseSalary;


-- ------------------------------------------------------------
-- Question 38: Managers whose team average salary exceeds company average
-- Find managers whose direct team average BaseSalary is above overall company average
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName,
    AVG(e.BaseSalary) AS TeamAvgSalary
FROM Employees AS m
INNER JOIN Employees AS e ON e.ManagerID = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING AVG(e.BaseSalary) > (
    SELECT AVG(BaseSalary) FROM Employees
);

-- Solution 2: Subquery
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName
FROM Employees AS m
WHERE (
    SELECT AVG(e.BaseSalary)
    FROM Employees AS e
    WHERE e.ManagerID = m.EmployeeID
) > (
    SELECT AVG(BaseSalary) FROM Employees
);

-- Solution 3: CTE
WITH TeamAvg AS (
    SELECT 
        ManagerID,
        AVG(BaseSalary) AS TeamAvgSalary
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
),
CompanyAvg AS (
    SELECT AVG(BaseSalary) AS AvgSalary FROM Employees
)
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName,
    t.TeamAvgSalary
FROM TeamAvg AS t
INNER JOIN Employees AS m ON m.EmployeeID = t.ManagerID
CROSS JOIN CompanyAvg AS c
WHERE t.TeamAvgSalary > c.AvgSalary;


-- ------------------------------------------------------------
-- Question 39: First hired employee in each Department
-- Find the earliest HireDate in each department and show corresponding employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query (ROW_NUMBER Subquery)
SELECT 
    x.DepartmentID,
    x.FullName,
    x.HireDate
FROM (
    SELECT 
        e.DepartmentID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.HireDate,
        ROW_NUMBER() OVER (
            PARTITION BY e.DepartmentID 
            ORDER BY e.HireDate ASC
        ) AS rn
    FROM Employees AS e
) AS x
WHERE x.rn = 1;

-- Solution 2: Subquery
SELECT 
    e.DepartmentID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.HireDate
FROM Employees AS e
WHERE e.HireDate = (
    SELECT MIN(e2.HireDate)
    FROM Employees AS e2
    WHERE e2.DepartmentID = e.DepartmentID
);

-- Solution 3: CTE
WITH RankedHire AS (
    SELECT 
        e.DepartmentID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        e.HireDate,
        ROW_NUMBER() OVER (
            PARTITION BY e.DepartmentID 
            ORDER BY e.HireDate ASC
        ) AS rn
    FROM Employees AS e
)
SELECT DepartmentID, FullName, HireDate
FROM RankedHire
WHERE rn = 1;


-- ------------------------------------------------------------
-- Question 40: Employees with more than 1 distinct Leave Type
-- Show employees who have taken more than 1 distinct LeaveType
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    COUNT(DISTINCT l.LeaveType) AS LeaveTypeCount
FROM Employees AS e
INNER JOIN LeaveRequests AS l ON l.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
HAVING COUNT(DISTINCT l.LeaveType) > 1;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees AS e
WHERE (
    SELECT COUNT(DISTINCT l.LeaveType)
    FROM LeaveRequests AS l
    WHERE l.EmployeeID = e.EmployeeID
) > 1;

-- Solution 3: CTE
WITH LeaveKinds AS (
    SELECT 
        EmployeeID,
        COUNT(DISTINCT LeaveType) AS LeaveTypeCount
    FROM LeaveRequests
    GROUP BY EmployeeID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    lk.LeaveTypeCount
FROM Employees AS e
INNER JOIN LeaveKinds AS lk ON lk.EmployeeID = e.EmployeeID
WHERE lk.LeaveTypeCount > 1;


-- ------------------------------------------------------------
-- Question 41: Period with highest Total Overtime Hours
-- Find the period with the highest sum of OvertimeHours
-- ------------------------------------------------------------

-- Solution 1: Standard Query (TOP 1)
SELECT TOP (1)
    PeriodID,
    SUM(OvertimeHours) AS TotalOvertime
FROM Attendance
GROUP BY PeriodID
ORDER BY SUM(OvertimeHours) DESC;

-- Solution 2: Subquery
SELECT 
    x.PeriodID,
    x.TotalOvertime
FROM (
    SELECT 
        p.PeriodID,
        (
            SELECT SUM(a.OvertimeHours)
            FROM Attendance AS a
            WHERE a.PeriodID = p.PeriodID
        ) AS TotalOvertime
    FROM PayrollPeriods AS p
) AS x
WHERE x.TotalOvertime = (
    SELECT MAX(y.TotalOvertime)
    FROM (
        SELECT (
            SELECT SUM(a2.OvertimeHours)
            FROM Attendance AS a2
            WHERE a2.PeriodID = p2.PeriodID
        ) AS TotalOvertime
        FROM PayrollPeriods AS p2
    ) AS y
);

-- Solution 3: CTE
WITH PeriodOvertime AS (
    SELECT 
        PeriodID,
        SUM(OvertimeHours) AS TotalOvertime
    FROM Attendance
    GROUP BY PeriodID
)
SELECT TOP (1)
    PeriodID,
    TotalOvertime
FROM PeriodOvertime
ORDER BY TotalOvertime DESC;


-- ------------------------------------------------------------
-- Question 42: Highest paid employee (NetSalary) per Fiscal Year/Month
-- Show the employee with maximum NetSalary for each fiscal year and month
-- ------------------------------------------------------------

-- Solution 1: Standard Query (ROW_NUMBER Subquery)
SELECT 
    x.FiscalYear,
    x.FiscalMonth,
    x.EmployeeID,
    x.NetSalary
FROM (
    SELECT 
        p.FiscalYear,
        p.FiscalMonth,
        sp.EmployeeID,
        sp.NetSalary,
        ROW_NUMBER() OVER (
            PARTITION BY p.FiscalYear, p.FiscalMonth
            ORDER BY sp.NetSalary DESC
        ) AS rn
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
) AS x
WHERE x.rn = 1;

-- Solution 2: Subquery
SELECT 
    p.FiscalYear,
    p.FiscalMonth,
    sp.EmployeeID,
    sp.NetSalary
FROM SalaryPayments AS sp
INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
WHERE sp.NetSalary = (
    SELECT MAX(sp2.NetSalary)
    FROM SalaryPayments AS sp2
    WHERE sp2.PeriodID = sp.PeriodID
);

-- Solution 3: CTE
WITH RankedMonthly AS (
    SELECT 
        p.FiscalYear,
        p.FiscalMonth,
        sp.EmployeeID,
        sp.NetSalary,
        ROW_NUMBER() OVER (
            PARTITION BY p.FiscalYear, p.FiscalMonth
            ORDER BY sp.NetSalary DESC
        ) AS rn
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
)
SELECT 
    FiscalYear,
    FiscalMonth,
    EmployeeID,
    NetSalary
FROM RankedMonthly
WHERE rn = 1;


-- ------------------------------------------------------------
-- Question 43: Identify potential duplicate payment records
-- Find EmployeeID and PeriodID combinations with more than 1 payment record
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    EmployeeID,
    PeriodID,
    COUNT(*) AS DuplicateCount
FROM SalaryPayments
GROUP BY EmployeeID, PeriodID
HAVING COUNT(*) > 1;

-- Solution 2: Subquery
SELECT DISTINCT 
    sp.EmployeeID,
    sp.PeriodID,
    (
        SELECT COUNT(*)
        FROM SalaryPayments AS sp2
        WHERE sp2.EmployeeID = sp.EmployeeID
          AND sp2.PeriodID = sp.PeriodID
    ) AS DuplicateCount
FROM SalaryPayments AS sp
WHERE (
    SELECT COUNT(*)
    FROM SalaryPayments AS sp2
    WHERE sp2.EmployeeID = sp.EmployeeID
      AND sp2.PeriodID = sp.PeriodID
) > 1;

-- Solution 3: CTE
WITH DupPayments AS (
    SELECT 
        EmployeeID,
        PeriodID,
        COUNT(*) AS DuplicateCount
    FROM SalaryPayments
    GROUP BY EmployeeID, PeriodID
)
SELECT * 
FROM DupPayments
WHERE DuplicateCount > 1;


-- ------------------------------------------------------------
-- Question 44: Reporting chain up to 2 levels (Manager and Upper Manager)
-- Display Direct Manager and Manager's Manager for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Double Self Join)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
    CONCAT(m1.FirstName, N' ', m1.LastName) AS DirectManager,
    CONCAT(m2.FirstName, N' ', m2.LastName) AS UpperManager
FROM Employees AS e
LEFT JOIN Employees AS m1 ON m1.EmployeeID = e.ManagerID
LEFT JOIN Employees AS m2 ON m2.EmployeeID = m1.ManagerID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
    (
        SELECT CONCAT(m1.FirstName, N' ', m1.LastName)
        FROM Employees AS m1
        WHERE m1.EmployeeID = e.ManagerID
    ) AS DirectManager,
    (
        SELECT CONCAT(m2.FirstName, N' ', m2.LastName)
        FROM Employees AS m2
        WHERE m2.EmployeeID = (
            SELECT m1.ManagerID
            FROM Employees AS m1
            WHERE m1.EmployeeID = e.ManagerID
        )
    ) AS UpperManager
FROM Employees AS e;

-- Solution 3: CTE
WITH Mgmt AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
        m1.EmployeeID AS DirectManagerID,
        CONCAT(m1.FirstName, N' ', m1.LastName) AS DirectManager,
        m2.EmployeeID AS UpperManagerID,
        CONCAT(m2.FirstName, N' ', m2.LastName) AS UpperManager
    FROM Employees AS e
    LEFT JOIN Employees AS m1 ON m1.EmployeeID = e.ManagerID
    LEFT JOIN Employees AS m2 ON m2.EmployeeID = m1.ManagerID
)
SELECT * FROM Mgmt;


-- ------------------------------------------------------------
-- Question 45: Top Managers without a Manager (ManagerID IS NULL)
-- Display employees who act as a manager but have a NULL ManagerID
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT DISTINCT 
    m.EmployeeID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName
FROM Employees AS m
INNER JOIN Employees AS e ON e.ManagerID = m.EmployeeID
WHERE m.ManagerID IS NULL;

-- Solution 2: Subquery (EXISTS)
SELECT 
    m.EmployeeID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName
FROM Employees AS m
WHERE m.ManagerID IS NULL
  AND EXISTS (
      SELECT 1 
      FROM Employees AS e 
      WHERE e.ManagerID = m.EmployeeID
  );

-- Solution 3: CTE
WITH Managers AS (
    SELECT DISTINCT ManagerID
    FROM Employees
    WHERE ManagerID IS NOT NULL
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS ManagerName
FROM Employees AS e
INNER JOIN Managers AS m ON m.ManagerID = e.EmployeeID
WHERE e.ManagerID IS NULL;


-- ------------------------------------------------------------
-- Question 46: Employees whose Net Salary decreased from previous period
-- Show payment records where NetSalary is lower than previous period
-- ------------------------------------------------------------

-- Solution 1: Standard Query (LAG Subquery)
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
WHERE x.NetSalary < x.PrevNetSalary;

-- Solution 2: Subquery
SELECT 
    sp.EmployeeID,
    sp.PeriodID,
    sp.NetSalary
FROM SalaryPayments AS sp
INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
WHERE sp.NetSalary < (
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
        LAG(sp.NetSalary) OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY p.FiscalYear, p.FiscalMonth
        ) AS PrevNetSalary
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
)
SELECT * 
FROM OrderedPayments
WHERE NetSalary < PrevNetSalary;


-- ------------------------------------------------------------
-- Question 47: Largest Net Salary growth compared to previous period
-- Calculate NetSalary growth and find the single largest increase
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT TOP (1)
    x.EmployeeID,
    x.PeriodID,
    x.NetSalary - x.PrevNetSalary AS GrowthAmount
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
WHERE x.PrevNetSalary IS NOT NULL
ORDER BY GrowthAmount DESC;

-- Solution 2: Subquery
SELECT TOP (1)
    sp.EmployeeID,
    sp.PeriodID,
    sp.NetSalary - (
        SELECT TOP 1 sp2.NetSalary
        FROM SalaryPayments AS sp2
        INNER JOIN PayrollPeriods AS p2 ON p2.PeriodID = sp2.PeriodID
        WHERE sp2.EmployeeID = sp.EmployeeID
          AND (
              p2.FiscalYear < p.FiscalYear 
              OR (p2.FiscalYear = p.FiscalYear AND p2.FiscalMonth < p.FiscalMonth)
          )
        ORDER BY p2.FiscalYear DESC, p2.FiscalMonth DESC
    ) AS GrowthAmount
FROM SalaryPayments AS sp
INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
ORDER BY GrowthAmount DESC;

-- Solution 3: CTE
WITH GrowthCTE AS (
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
)
SELECT TOP (1)
    EmployeeID,
    PeriodID,
    NetSalary - PrevNetSalary AS GrowthAmount
FROM GrowthCTE
WHERE PrevNetSalary IS NOT NULL
ORDER BY GrowthAmount DESC;


-- ------------------------------------------------------------
-- Question 48: Employee avg hours worked vs Department avg
-- Show employees whose average HoursWorked exceeds their department's average
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Window Function OVER PARTITION BY)
SELECT 
    x.EmployeeID,
    x.EmployeeAvg,
    x.DeptAvg
FROM (
    SELECT 
        e.EmployeeID,
        AVG(a.HoursWorked) AS EmployeeAvg,
        AVG(AVG(a.HoursWorked)) OVER (PARTITION BY e.DepartmentID) AS DeptAvg
    FROM Employees AS e
    INNER JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID
    GROUP BY e.EmployeeID, e.DepartmentID
) AS x
WHERE x.EmployeeAvg > x.DeptAvg;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    AVG(a.HoursWorked) AS EmployeeAvg
FROM Employees AS e
INNER JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.DepartmentID
HAVING AVG(a.HoursWorked) > (
    SELECT AVG(a2.HoursWorked)
    FROM Employees AS e2
    INNER JOIN Attendance AS a2 ON a2.EmployeeID = e2.EmployeeID
    WHERE e2.DepartmentID = e.DepartmentID
);

-- Solution 3: CTE
WITH EmployeeAvg AS (
    SELECT 
        e.EmployeeID,
        e.DepartmentID,
        AVG(a.HoursWorked) AS EmployeeAvg
    FROM Employees AS e
    INNER JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID
    GROUP BY e.EmployeeID, e.DepartmentID
),
DeptAvg AS (
    SELECT 
        e.DepartmentID,
        AVG(a.HoursWorked) AS DeptAvg
    FROM Employees AS e
    INNER JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID
    GROUP BY e.DepartmentID
)
SELECT 
    ea.EmployeeID,
    ea.EmployeeAvg,
    da.DeptAvg
FROM EmployeeAvg AS ea
INNER JOIN DeptAvg AS da ON da.DepartmentID = ea.DepartmentID
WHERE ea.EmployeeAvg > da.DeptAvg;


-- ------------------------------------------------------------
-- Question 49: Managers with at least 3 'Active' direct reports
-- Find managers who manage 3 or more active employees
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    m.EmployeeID AS ManagerID,
    COUNT(e.EmployeeID) AS ActiveTeamSize
FROM Employees AS m
INNER JOIN Employees AS e ON e.ManagerID = m.EmployeeID
WHERE e.EmploymentStatus = N'Active'
GROUP BY m.EmployeeID
HAVING COUNT(e.EmployeeID) >= 3;

-- Solution 2: Subquery
SELECT 
    m.EmployeeID AS ManagerID
FROM Employees AS m
WHERE (
    SELECT COUNT(*)
    FROM Employees AS e
    WHERE e.ManagerID = m.EmployeeID
      AND e.EmploymentStatus = N'Active'
) >= 3;

-- Solution 3: CTE
WITH ActiveTeams AS (
    SELECT 
        ManagerID,
        COUNT(*) AS ActiveTeamSize
    FROM Employees
    WHERE ManagerID IS NOT NULL
      AND EmploymentStatus = N'Active'
    GROUP BY ManagerID
)
SELECT 
    ManagerID,
    ActiveTeamSize
FROM ActiveTeams
WHERE ActiveTeamSize >= 3;


-- ------------------------------------------------------------
-- Question 50: Comprehensive Annual Report for Fiscal Year 2026
-- Generate report with Total NetSalary, Bonuses, Deductions, and Overtime per employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    SUM(sp.NetSalary) AS TotalNetSalary,
    SUM(ISNULL(b.Amount, 0)) AS TotalBonus,
    SUM(ISNULL(d.Amount, 0)) AS TotalDeduction,
    SUM(ISNULL(a.OvertimeHours, 0)) AS TotalOvertimeHours
FROM Employees AS e
LEFT JOIN SalaryPayments AS sp ON sp.EmployeeID = e.EmployeeID
LEFT JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
LEFT JOIN Bonuses AS b ON b.EmployeeID = e.EmployeeID AND b.PeriodID = sp.PeriodID
LEFT JOIN Deductions AS d ON d.EmployeeID = e.EmployeeID AND d.PeriodID = sp.PeriodID
LEFT JOIN Attendance AS a ON a.EmployeeID = e.EmployeeID AND a.PeriodID = sp.PeriodID
WHERE p.FiscalYear = 2026
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT SUM(sp.NetSalary)
        FROM SalaryPayments AS sp
        INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
        WHERE sp.EmployeeID = e.EmployeeID AND p.FiscalYear = 2026
    ) AS TotalNetSalary,
    (
        SELECT SUM(b.Amount)
        FROM Bonuses AS b
        INNER JOIN PayrollPeriods AS p ON p.PeriodID = b.PeriodID
        WHERE b.EmployeeID = e.EmployeeID AND p.FiscalYear = 2026
    ) AS TotalBonus,
    (
        SELECT SUM(d.Amount)
        FROM Deductions AS d
        INNER JOIN PayrollPeriods AS p ON p.PeriodID = d.PeriodID
        WHERE d.EmployeeID = e.EmployeeID AND p.FiscalYear = 2026
    ) AS TotalDeduction,
    (
        SELECT SUM(a.OvertimeHours)
        FROM Attendance AS a
        INNER JOIN PayrollPeriods AS p ON p.PeriodID = a.PeriodID
        WHERE a.EmployeeID = e.EmployeeID AND p.FiscalYear = 2026
    ) AS TotalOvertimeHours
FROM Employees AS e;

-- Solution 3: CTE
WITH Pay AS (
    SELECT 
        sp.EmployeeID,
        SUM(sp.NetSalary) AS TotalNetSalary
    FROM SalaryPayments AS sp
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = sp.PeriodID
    WHERE p.FiscalYear = 2026
    GROUP BY sp.EmployeeID
),
Bonus AS (
    SELECT 
        b.EmployeeID,
        SUM(b.Amount) AS TotalBonus
    FROM Bonuses AS b
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = b.PeriodID
    WHERE p.FiscalYear = 2026
    GROUP BY b.EmployeeID
),
Ded AS (
    SELECT 
        d.EmployeeID,
        SUM(d.Amount) AS TotalDeduction
    FROM Deductions AS d
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = d.PeriodID
    WHERE p.FiscalYear = 2026
    GROUP BY d.EmployeeID
),
OT AS (
    SELECT 
        a.EmployeeID,
        SUM(a.OvertimeHours) AS TotalOvertimeHours
    FROM Attendance AS a
    INNER JOIN PayrollPeriods AS p ON p.PeriodID = a.PeriodID
    WHERE p.FiscalYear = 2026
    GROUP BY a.EmployeeID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    ISNULL(p.TotalNetSalary, 0) AS TotalNetSalary,
    ISNULL(b.TotalBonus, 0) AS TotalBonus,
    ISNULL(d.TotalDeduction, 0) AS TotalDeduction,
    ISNULL(o.TotalOvertimeHours, 0) AS TotalOvertimeHours
FROM Employees AS e
LEFT JOIN Pay AS p ON p.EmployeeID = e.EmployeeID
LEFT JOIN Bonus AS b ON b.EmployeeID = e.EmployeeID
LEFT JOIN Ded AS d ON d.EmployeeID = e.EmployeeID
LEFT JOIN OT AS o ON o.EmployeeID = e.EmployeeID;

-- ============================================================
-- HR & Payroll SQL Server Case Study
-- Level: Beginner Questions (Questions 1 to 15)
-- Each question includes 3 solutions: Standard Query, Subquery, and CTE
-- ============================================================


-- ------------------------------------------------------------
-- Question 1: Employee list with Department Name
-- Show EmployeeID, Full Name, and Department Name
-- ------------------------------------------------------------

-- Solution 1: Standard Query (JOIN)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON d.DepartmentID = e.DepartmentID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT d.DepartmentName 
        FROM Departments d 
        WHERE d.DepartmentID = e.DepartmentID
    ) AS DepartmentName
FROM Employees e;

-- Solution 3: CTE
WITH EmpDept AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
        d.DepartmentName
    FROM Employees e
    INNER JOIN Departments d ON d.DepartmentID = e.DepartmentID
)
SELECT * FROM EmpDept;


-- ------------------------------------------------------------
-- Question 2: Active Employees
-- Display all employees whose EmploymentStatus is 'Active'
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.EmploymentStatus
FROM Employees e
WHERE e.EmploymentStatus = N'Active';

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.EmploymentStatus
FROM Employees e
WHERE e.EmployeeID IN (
    SELECT e2.EmployeeID
    FROM Employees e2
    WHERE e2.EmploymentStatus = N'Active'
);

-- Solution 3: CTE
WITH ActiveEmployees AS (
    SELECT * 
    FROM Employees
    WHERE EmploymentStatus = N'Active'
)
SELECT 
    EmployeeID,
    CONCAT(FirstName, N' ', LastName) AS FullName,
    EmploymentStatus
FROM ActiveEmployees;


-- ------------------------------------------------------------
-- Question 3: Employees hired after 2022-01-01
-- Show employees hired after January 1, 2022
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.HireDate
FROM Employees e
WHERE e.HireDate > '2022-01-01';

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.HireDate
FROM Employees e
WHERE e.EmployeeID IN (
    SELECT e2.EmployeeID
    FROM Employees e2
    WHERE e2.HireDate > '2022-01-01'
);

-- Solution 3: CTE
WITH RecentHires AS (
    SELECT * 
    FROM Employees
    WHERE HireDate > '2022-01-01'
)
SELECT 
    EmployeeID,
    CONCAT(FirstName, N' ', LastName) AS FullName,
    HireDate
FROM RecentHires;


-- ------------------------------------------------------------
-- Question 4: Employees in Tehran
-- Show employees located in Tehran
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.City
FROM Employees e
WHERE e.City = N'Tehran';

-- Solution 2: Subquery (EXISTS)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.City
FROM Employees e
WHERE EXISTS (
    SELECT 1 
    FROM Employees e2 
    WHERE e2.EmployeeID = e.EmployeeID 
      AND e2.City = N'Tehran'
);

-- Solution 3: CTE
WITH TehranEmployees AS (
    SELECT * 
    FROM Employees
    WHERE City = N'Tehran'
)
SELECT 
    EmployeeID,
    CONCAT(FirstName, N' ', LastName) AS FullName,
    City
FROM TehranEmployees;


-- ------------------------------------------------------------
-- Question 5: Employee count per Department
-- Calculate total employees for each department
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    (
        SELECT COUNT(*)
        FROM Employees e
        WHERE e.DepartmentID = d.DepartmentID
    ) AS EmployeeCount
FROM Departments d;

-- Solution 3: CTE
WITH DeptCounts AS (
    SELECT 
        DepartmentID,
        COUNT(*) AS EmployeeCount
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    d.DepartmentName,
    ISNULL(dc.EmployeeCount, 0) AS EmployeeCount
FROM Departments d
LEFT JOIN DeptCounts dc ON dc.DepartmentID = d.DepartmentID;


-- ------------------------------------------------------------
-- Question 6: Average Base Salary per Department
-- Display average BaseSalary for each department
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    d.DepartmentName,
    AVG(e.BaseSalary) AS AvgBaseSalary
FROM Departments d
INNER JOIN Employees e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    (
        SELECT AVG(e.BaseSalary)
        FROM Employees e
        WHERE e.DepartmentID = d.DepartmentID
    ) AS AvgBaseSalary
FROM Departments d;

-- Solution 3: CTE
WITH AvgSalary AS (
    SELECT 
        DepartmentID,
        AVG(BaseSalary) AS AvgBaseSalary
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    d.DepartmentName,
    a.AvgBaseSalary
FROM Departments d
LEFT JOIN AvgSalary a ON a.DepartmentID = d.DepartmentID;


-- ------------------------------------------------------------
-- Question 7: Maximum Base Salary per Department
-- Display maximum BaseSalary for each department
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    d.DepartmentName,
    MAX(e.BaseSalary) AS MaxBaseSalary
FROM Departments d
INNER JOIN Employees e ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;

-- Solution 2: Subquery
SELECT 
    d.DepartmentName,
    (
        SELECT MAX(e.BaseSalary)
        FROM Employees e
        WHERE e.DepartmentID = d.DepartmentID
    ) AS MaxBaseSalary
FROM Departments d;

-- Solution 3: CTE
WITH MaxSalary AS (
    SELECT 
        DepartmentID,
        MAX(BaseSalary) AS MaxBaseSalary
    FROM Employees
    GROUP BY DepartmentID
)
SELECT 
    d.DepartmentName,
    m.MaxBaseSalary
FROM Departments d
LEFT JOIN MaxSalary m ON m.DepartmentID = d.DepartmentID;


-- ------------------------------------------------------------
-- Question 8: Employees with Direct Manager
-- Display Employee Name and their Direct Manager Name
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Self Join)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName
FROM Employees e
INNER JOIN Employees m ON m.EmployeeID = e.ManagerID;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
    (
        SELECT CONCAT(m.FirstName, N' ', m.LastName)
        FROM Employees m
        WHERE m.EmployeeID = e.ManagerID
    ) AS ManagerName
FROM Employees e
WHERE e.ManagerID IS NOT NULL;

-- Solution 3: CTE
WITH EmployeeManagers AS (
    SELECT 
        e.EmployeeID,
        CONCAT(e.FirstName, N' ', e.LastName) AS EmployeeName,
        CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName
    FROM Employees e
    INNER JOIN Employees m ON m.EmployeeID = e.ManagerID
)
SELECT * FROM EmployeeManagers;


-- ------------------------------------------------------------
-- Question 9: Team size for each Manager
-- Display Manager ID, Manager Name, and count of direct reports
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName,
    COUNT(e.EmployeeID) AS TeamSize
FROM Employees m
INNER JOIN Employees e ON e.ManagerID = m.EmployeeID
GROUP BY m.EmployeeID, m.FirstName, m.LastName;

-- Solution 2: Subquery
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName,
    (
        SELECT COUNT(*)
        FROM Employees e
        WHERE e.ManagerID = m.EmployeeID
    ) AS TeamSize
FROM Employees m
WHERE EXISTS (
    SELECT 1 FROM Employees e WHERE e.ManagerID = m.EmployeeID
);

-- Solution 3: CTE
WITH TeamCounts AS (
    SELECT 
        ManagerID,
        COUNT(*) AS TeamSize
    FROM Employees
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
SELECT 
    m.EmployeeID AS ManagerID,
    CONCAT(m.FirstName, N' ', m.LastName) AS ManagerName,
    tc.TeamSize
FROM TeamCounts tc
INNER JOIN Employees m ON m.EmployeeID = tc.ManagerID;


-- ------------------------------------------------------------
-- Question 10: Annual Salary per Employee
-- Calculate BaseSalary * 12 for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary,
    e.BaseSalary * 12 AS AnnualSalary
FROM Employees e;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    e.BaseSalary,
    (
        SELECT e2.BaseSalary * 12
        FROM Employees e2
        WHERE e2.EmployeeID = e.EmployeeID
    ) AS AnnualSalary
FROM Employees e;

-- Solution 3: CTE
WITH SalaryCTE AS (
    SELECT 
        EmployeeID,
        CONCAT(FirstName, N' ', LastName) AS FullName,
        BaseSalary,
        BaseSalary * 12 AS AnnualSalary
    FROM Employees
)
SELECT * FROM SalaryCTE;


-- ------------------------------------------------------------
-- Question 11: Total Approved Leave Days per Employee
-- Sum of DaysCount for 'Approved' requests per employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    SUM(l.DaysCount) AS ApprovedLeaveDays
FROM Employees e
INNER JOIN LeaveRequests l ON l.EmployeeID = e.EmployeeID
WHERE l.ApprovalStatus = N'Approved'
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT SUM(l.DaysCount)
        FROM LeaveRequests l
        WHERE l.EmployeeID = e.EmployeeID
          AND l.ApprovalStatus = N'Approved'
    ) AS ApprovedLeaveDays
FROM Employees e;

-- Solution 3: CTE
WITH ApprovedLeaves AS (
    SELECT 
        EmployeeID,
        SUM(DaysCount) AS ApprovedLeaveDays
    FROM LeaveRequests
    WHERE ApprovalStatus = N'Approved'
    GROUP BY EmployeeID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    ISNULL(al.ApprovedLeaveDays, 0) AS ApprovedLeaveDays
FROM Employees e
LEFT JOIN ApprovedLeaves al ON al.EmployeeID = e.EmployeeID;


-- ------------------------------------------------------------
-- Question 12: Total Overtime Hours per Employee
-- Sum of OvertimeHours recorded in Attendance
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    SUM(a.OvertimeHours) AS TotalOvertime
FROM Employees e
INNER JOIN Attendance a ON a.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT SUM(a.OvertimeHours)
        FROM Attendance a
        WHERE a.EmployeeID = e.EmployeeID
    ) AS TotalOvertime
FROM Employees e;

-- Solution 3: CTE
WITH OvertimeSum AS (
    SELECT 
        EmployeeID,
        SUM(OvertimeHours) AS TotalOvertime
    FROM Attendance
    GROUP BY EmployeeID
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    ISNULL(o.TotalOvertime, 0) AS TotalOvertime
FROM Employees e
LEFT JOIN OvertimeSum o ON o.EmployeeID = e.EmployeeID;


-- ------------------------------------------------------------
-- Question 13: Employees without Attendance Records
-- Show employees who have no record in Attendance table
-- ------------------------------------------------------------

-- Solution 1: Standard Query (LEFT JOIN)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
LEFT JOIN Attendance a ON a.EmployeeID = e.EmployeeID
WHERE a.AttendanceID IS NULL;

-- Solution 2: Subquery (NOT EXISTS)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1 
    FROM Attendance a 
    WHERE a.EmployeeID = e.EmployeeID
);

-- Solution 3: CTE
WITH EmployeesWithAttendance AS (
    SELECT DISTINCT EmployeeID 
    FROM Attendance
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
LEFT JOIN EmployeesWithAttendance x ON x.EmployeeID = e.EmployeeID
WHERE x.EmployeeID IS NULL;


-- ------------------------------------------------------------
-- Question 14: Employees with Rejected Leave Requests
-- Display employees with at least one 'Rejected' leave request
-- ------------------------------------------------------------

-- Solution 1: Standard Query
SELECT DISTINCT
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
INNER JOIN LeaveRequests l ON l.EmployeeID = e.EmployeeID
WHERE l.ApprovalStatus = N'Rejected';

-- Solution 2: Subquery (EXISTS)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
WHERE EXISTS (
    SELECT 1 
    FROM LeaveRequests l 
    WHERE l.EmployeeID = e.EmployeeID 
      AND l.ApprovalStatus = N'Rejected'
);

-- Solution 3: CTE
WITH RejectedLeaves AS (
    SELECT DISTINCT EmployeeID 
    FROM LeaveRequests
    WHERE ApprovalStatus = N'Rejected'
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName
FROM Employees e
INNER JOIN RejectedLeaves r ON r.EmployeeID = e.EmployeeID;


-- ------------------------------------------------------------
-- Question 15: Last Payment for each Employee
-- Display latest PaymentDate and NetSalary for each employee
-- ------------------------------------------------------------

-- Solution 1: Standard Query (Subquery Filter)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    sp.PaymentDate,
    sp.NetSalary
FROM Employees e
INNER JOIN SalaryPayments sp ON sp.EmployeeID = e.EmployeeID
WHERE sp.PaymentDate = (
    SELECT MAX(sp2.PaymentDate)
    FROM SalaryPayments sp2
    WHERE sp2.EmployeeID = e.EmployeeID
);

-- Solution 2: Subquery
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    (
        SELECT MAX(sp2.PaymentDate)
        FROM SalaryPayments sp2
        WHERE sp2.EmployeeID = e.EmployeeID
    ) AS LastPaymentDate,
    (
        SELECT TOP 1 sp3.NetSalary
        FROM SalaryPayments sp3
        WHERE sp3.EmployeeID = e.EmployeeID
        ORDER BY sp3.PaymentDate DESC
    ) AS LastNetSalary
FROM Employees e;

-- Solution 3: CTE (ROW_NUMBER)
WITH LastPayment AS (
    SELECT 
        sp.*,
        ROW_NUMBER() OVER (
            PARTITION BY sp.EmployeeID 
            ORDER BY sp.PaymentDate DESC
        ) AS rn
    FROM SalaryPayments sp
)
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, N' ', e.LastName) AS FullName,
    lp.PaymentDate,
    lp.NetSalary
FROM Employees e
INNER JOIN LastPayment lp ON lp.EmployeeID = e.EmployeeID AND lp.rn = 1;

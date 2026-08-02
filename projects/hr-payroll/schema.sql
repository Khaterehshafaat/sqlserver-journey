
-- Create Database Tables for HR & Payroll System

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    CostCenter NVARCHAR(30) NOT NULL,
    BudgetAmount DECIMAL(18,2) NOT NULL
);

CREATE TABLE Jobs (
    JobID INT PRIMARY KEY,
    JobTitle NVARCHAR(100) NOT NULL,
    GradeLevel INT NOT NULL,
    MinSalary DECIMAL(18,2) NOT NULL,
    MaxSalary DECIMAL(18,2) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    NationalCode CHAR(10) UNIQUE NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NCHAR(1) NULL,
    BirthDate DATE NULL,
    HireDate DATE NOT NULL,
    DepartmentID INT NOT NULL,
    JobID INT NOT NULL,
    ManagerID INT NULL,
    BaseSalary DECIMAL(18,2) NOT NULL,
    EmploymentStatus NVARCHAR(20) NOT NULL,
    City NVARCHAR(50) NULL,
    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    CONSTRAINT FK_Employees_Jobs FOREIGN KEY (JobID) REFERENCES Jobs(JobID),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE PayrollPeriods (
    PeriodID INT PRIMARY KEY,
    FiscalYear INT NOT NULL,
    FiscalMonth INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsClosed BIT NOT NULL
);

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PeriodID INT NOT NULL,
    WorkDate DATE NOT NULL,
    HoursWorked DECIMAL(5,2) NOT NULL,
    OvertimeHours DECIMAL(5,2) NOT NULL,
    LateMinutes INT NOT NULL,
    IsRemote BIT NOT NULL,
    CONSTRAINT FK_Attendance_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Attendance_PayrollPeriods FOREIGN KEY (PeriodID) REFERENCES PayrollPeriods(PeriodID)
);

CREATE TABLE LeaveRequests (
    LeaveID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    LeaveType NVARCHAR(30) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DaysCount INT NOT NULL,
    ApprovalStatus NVARCHAR(20) NOT NULL,
    RequestDate DATE NOT NULL,
    CONSTRAINT FK_LeaveRequests_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE SalaryPayments (
    PaymentID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PeriodID INT NOT NULL,
    GrossSalary DECIMAL(18,2) NOT NULL,
    BonusAmount DECIMAL(18,2) NOT NULL,
    DeductionAmount DECIMAL(18,2) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL,
    InsuranceAmount DECIMAL(18,2) NOT NULL,
    NetSalary DECIMAL(18,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    CONSTRAINT FK_SalaryPayments_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_SalaryPayments_PayrollPeriods FOREIGN KEY (PeriodID) REFERENCES PayrollPeriods(PeriodID)
);

CREATE TABLE Bonuses (
    BonusID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PeriodID INT NOT NULL,
    BonusType NVARCHAR(30) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ApprovedBy INT NULL,
    CONSTRAINT FK_Bonuses_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Bonuses_PayrollPeriods FOREIGN KEY (PeriodID) REFERENCES PayrollPeriods(PeriodID)
);

CREATE TABLE Deductions (
    DeductionID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    PeriodID INT NOT NULL,
    DeductionType NVARCHAR(30) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Reason NVARCHAR(200) NULL,
    CONSTRAINT FK_Deductions_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT FK_Deductions_PayrollPeriods FOREIGN KEY (PeriodID) REFERENCES PayrollPeriods(PeriodID)
);

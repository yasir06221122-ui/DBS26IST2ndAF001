-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM - DATABASE SCRIPT
--  Database: MySQL
--  Project:  DBS26IST2ndAF (Semester Final Project)
-- ============================================================

DROP DATABASE IF EXISTS LibraryMS;
CREATE DATABASE LibraryMS CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE LibraryMS;

-- ============================================================
--  TABLES (16)
-- ============================================================

-- 1. Roles
CREATE TABLE Roles (
    RoleID      INT AUTO_INCREMENT PRIMARY KEY,
    RoleName    VARCHAR(50)  NOT NULL UNIQUE,
    Description VARCHAR(255),
    CreatedAt   DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rolename CHECK (CHAR_LENGTH(RoleName) >= 2)
);

-- 2. Users (Staff)
CREATE TABLE Users (
    UserID       INT AUTO_INCREMENT PRIMARY KEY,
    Username     VARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash VARCHAR(256) NOT NULL,
    FullName     VARCHAR(100) NOT NULL,
    Email        VARCHAR(100) NOT NULL UNIQUE,
    Phone        VARCHAR(20),
    RoleID       INT          NOT NULL,
    IsActive     TINYINT(1)   NOT NULL DEFAULT 1,
    CreatedAt    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    LastLogin    DATETIME,
    CONSTRAINT fk_users_role  FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    CONSTRAINT chk_email      CHECK (Email LIKE '%@%.%'),
    CONSTRAINT chk_username   CHECK (CHAR_LENGTH(Username) >= 4)
);

-- 3. Publishers
CREATE TABLE Publishers (
    PublisherID   INT AUTO_INCREMENT PRIMARY KEY,
    PublisherName VARCHAR(150) NOT NULL,
    ContactName   VARCHAR(100),
    Email         VARCHAR(100),
    Phone         VARCHAR(20),
    Address       TEXT,
    City          VARCHAR(50),
    Country       VARCHAR(50)  DEFAULT 'Pakistan',
    IsActive      TINYINT(1)   DEFAULT 1,
    CreatedAt     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pub_phone CHECK (CHAR_LENGTH(Phone) >= 7)
);

-- 4. Categories (Genres)
CREATE TABLE Categories (
    CategoryID   INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description  TEXT,
    IsActive     TINYINT(1)   DEFAULT 1
);

-- 5. Books
CREATE TABLE Books (
    BookID           INT AUTO_INCREMENT PRIMARY KEY,
    Title            VARCHAR(200) NOT NULL,
    ISBN             VARCHAR(20)  UNIQUE,
    CategoryID       INT          NOT NULL,
    PublisherID      INT,
    Author           VARCHAR(150) NOT NULL,
    PublishYear      YEAR,
    TotalCopies      INT          NOT NULL DEFAULT 1,
    AvailableCopies  INT          NOT NULL DEFAULT 1,
    ShelfLocation    VARCHAR(50),
    Language         VARCHAR(30)  DEFAULT 'English',
    IsActive         TINYINT(1)   DEFAULT 1,
    CreatedAt        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_category  FOREIGN KEY (CategoryID)  REFERENCES Categories(CategoryID),
    CONSTRAINT fk_book_publisher FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    CONSTRAINT chk_total_copies  CHECK (TotalCopies >= 0),
    CONSTRAINT chk_avail_copies  CHECK (AvailableCopies >= 0)
);

-- 6. Members
CREATE TABLE Members (
    MemberID     INT AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(100) NOT NULL,
    CNIC         VARCHAR(20)  UNIQUE,
    Phone        VARCHAR(20),
    Email        VARCHAR(100),
    Address      TEXT,
    DateOfBirth  DATE,
    Gender       ENUM('Male','Female','Other'),
    MemberType   ENUM('Student','Faculty','Public') DEFAULT 'Student',
    JoinDate     DATE         DEFAULT (CURRENT_DATE),
    ExpiryDate   DATE,
    IsActive     TINYINT(1)   DEFAULT 1,
    CreatedAt    DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- 7. MembershipPlans
CREATE TABLE MembershipPlans (
    PlanID         INT AUTO_INCREMENT PRIMARY KEY,
    PlanName       VARCHAR(100) NOT NULL UNIQUE,
    DurationDays   INT          NOT NULL,
    MaxBooksAllowed INT         NOT NULL DEFAULT 3,
    LoanPeriodDays  INT         NOT NULL DEFAULT 14,
    FeeAmount      DECIMAL(8,2) NOT NULL DEFAULT 0,
    Description    TEXT
);

-- 8. MemberPlanHistory
CREATE TABLE MemberPlanHistory (
    HistoryID  INT AUTO_INCREMENT PRIMARY KEY,
    MemberID   INT NOT NULL,
    PlanID     INT NOT NULL,
    StartDate  DATE NOT NULL,
    EndDate    DATE NOT NULL,
    AmountPaid DECIMAL(8,2),
    AssignedBy INT,
    CreatedAt  DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mph_member FOREIGN KEY (MemberID)   REFERENCES Members(MemberID),
    CONSTRAINT fk_mph_plan   FOREIGN KEY (PlanID)     REFERENCES MembershipPlans(PlanID),
    CONSTRAINT fk_mph_user   FOREIGN KEY (AssignedBy) REFERENCES Users(UserID)
);

-- 9. Loans (Borrowing Records)
CREATE TABLE Loans (
    LoanID       INT AUTO_INCREMENT PRIMARY KEY,
    MemberID     INT          NOT NULL,
    BookID       INT          NOT NULL,
    IssuedBy     INT          NOT NULL,
    IssueDate    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    DueDate      DATE         NOT NULL,
    ReturnDate   DATE,
    Status       ENUM('Active','Returned','Overdue','Lost') DEFAULT 'Active',
    Notes        TEXT,
    CONSTRAINT fk_loan_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT fk_loan_book   FOREIGN KEY (BookID)   REFERENCES Books(BookID),
    CONSTRAINT fk_loan_user   FOREIGN KEY (IssuedBy) REFERENCES Users(UserID)
);

-- 10. Fines
CREATE TABLE Fines (
    FineID       INT AUTO_INCREMENT PRIMARY KEY,
    LoanID       INT           NOT NULL,
    MemberID     INT           NOT NULL,
    FineAmount   DECIMAL(8,2)  NOT NULL DEFAULT 0,
    Reason       ENUM('Overdue','Damaged','Lost') DEFAULT 'Overdue',
    IsPaid       TINYINT(1)    DEFAULT 0,
    PaidDate     DATE,
    CollectedBy  INT,
    CreatedAt    DATETIME      DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fine_loan   FOREIGN KEY (LoanID)      REFERENCES Loans(LoanID),
    CONSTRAINT fk_fine_member FOREIGN KEY (MemberID)    REFERENCES Members(MemberID),
    CONSTRAINT fk_fine_user   FOREIGN KEY (CollectedBy) REFERENCES Users(UserID),
    CONSTRAINT chk_fine_amt   CHECK (FineAmount >= 0)
);

-- 11. Reservations
CREATE TABLE Reservations (
    ReservationID  INT AUTO_INCREMENT PRIMARY KEY,
    MemberID       INT          NOT NULL,
    BookID         INT          NOT NULL,
    ReservedAt     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    ExpiryDate     DATE,
    Status         ENUM('Pending','Fulfilled','Cancelled','Expired') DEFAULT 'Pending',
    NotifiedAt     DATETIME,
    CONSTRAINT fk_res_member FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT fk_res_book   FOREIGN KEY (BookID)   REFERENCES Books(BookID)
);

-- 12. BookAcquisitions (Purchase Orders equivalent)
CREATE TABLE BookAcquisitions (
    AcquisitionID  INT AUTO_INCREMENT PRIMARY KEY,
    PublisherID    INT           NOT NULL,
    OrderedBy      INT           NOT NULL,
    OrderDate      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    ReceivedDate   DATE,
    TotalAmount    DECIMAL(10,2) DEFAULT 0,
    Status         ENUM('Pending','Approved','Received','Cancelled') DEFAULT 'Pending',
    Notes          TEXT,
    CONSTRAINT fk_acq_pub  FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    CONSTRAINT fk_acq_user FOREIGN KEY (OrderedBy)  REFERENCES Users(UserID)
);

-- 13. AcquisitionItems
CREATE TABLE AcquisitionItems (
    AcqItemID      INT AUTO_INCREMENT PRIMARY KEY,
    AcquisitionID  INT           NOT NULL,
    BookID         INT           NOT NULL,
    Quantity       INT           NOT NULL,
    UnitCost       DECIMAL(8,2)  NOT NULL,
    SubTotal       DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ai_acq  FOREIGN KEY (AcquisitionID) REFERENCES BookAcquisitions(AcquisitionID),
    CONSTRAINT fk_ai_book FOREIGN KEY (BookID)        REFERENCES Books(BookID),
    CONSTRAINT chk_ai_qty CHECK (Quantity > 0)
);

-- 14. AuditTrail
CREATE TABLE AuditTrail (
    AuditID    INT AUTO_INCREMENT PRIMARY KEY,
    UserID     INT,
    TableName  VARCHAR(100) NOT NULL,
    RecordID   INT,
    Action     ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    OldValue   TEXT,
    NewValue   TEXT,
    ActionTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 15. ErrorLogs
CREATE TABLE ErrorLogs (
    LogID      INT AUTO_INCREMENT PRIMARY KEY,
    UserID     INT,
    FormName   VARCHAR(100),
    ErrorMsg   TEXT        NOT NULL,
    StackTrace TEXT,
    LoggedAt   DATETIME    DEFAULT CURRENT_TIMESTAMP,
    Severity   ENUM('Info','Warning','Error','Critical') DEFAULT 'Error',
    CONSTRAINT fk_log_user FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- 16. Settings
CREATE TABLE Settings (
    SettingID    INT AUTO_INCREMENT PRIMARY KEY,
    SettingKey   VARCHAR(100) NOT NULL UNIQUE,
    SettingValue TEXT,
    Description  VARCHAR(255)
);

-- ============================================================
--  VIEWS (6+)
-- ============================================================

-- View 1: Books currently available for loan
CREATE VIEW vw_AvailableBooks AS
SELECT b.BookID, b.Title, b.Author, b.ISBN,
       c.CategoryName, b.AvailableCopies, b.TotalCopies,
       b.ShelfLocation, p.PublisherName
FROM   Books b
JOIN   Categories c  ON b.CategoryID  = c.CategoryID
LEFT JOIN Publishers p ON b.PublisherID = p.PublisherID
WHERE  b.AvailableCopies > 0 AND b.IsActive = 1;

-- View 2: Active loans with overdue detection
CREATE VIEW vw_ActiveLoans AS
SELECT l.LoanID, m.FullName AS MemberName, m.Phone,
       b.Title, b.Author,
       l.IssueDate, l.DueDate,
       DATEDIFF(CURDATE(), l.DueDate) AS DaysOverdue,
       u.FullName AS IssuedBy
FROM   Loans l
JOIN   Members m ON l.MemberID = m.MemberID
JOIN   Books   b ON l.BookID   = b.BookID
JOIN   Users   u ON l.IssuedBy = u.UserID
WHERE  l.Status = 'Active';

-- View 3: Unpaid fines summary
CREATE VIEW vw_UnpaidFines AS
SELECT f.FineID, m.FullName AS MemberName, m.Phone,
       b.Title, f.FineAmount, f.Reason, f.CreatedAt,
       l.DueDate, l.ReturnDate
FROM   Fines f
JOIN   Loans   l ON f.LoanID   = l.LoanID
JOIN   Members m ON f.MemberID = m.MemberID
JOIN   Books   b ON l.BookID   = b.BookID
WHERE  f.IsPaid = 0;

-- View 4: Most borrowed books
CREATE VIEW vw_PopularBooks AS
SELECT b.BookID, b.Title, b.Author,
       c.CategoryName,
       COUNT(l.LoanID)      AS TotalLoans,
       SUM(CASE WHEN l.Status = 'Active' THEN 1 ELSE 0 END) AS CurrentlyBorrowed
FROM   Books b
JOIN   Categories c ON b.CategoryID = c.CategoryID
LEFT JOIN Loans l   ON b.BookID     = l.BookID
GROUP BY b.BookID, b.Title, b.Author, c.CategoryName;

-- View 5: Member loan history
CREATE VIEW vw_MemberLoanHistory AS
SELECT m.MemberID, m.FullName, m.MemberType,
       l.LoanID, b.Title, b.Author,
       l.IssueDate, l.DueDate, l.ReturnDate, l.Status
FROM   Members m
JOIN   Loans l ON m.MemberID = l.MemberID
JOIN   Books  b ON l.BookID  = b.BookID;

-- View 6: Acquisition order overview
CREATE VIEW vw_AcquisitionOverview AS
SELECT a.AcquisitionID, a.OrderDate, a.Status,
       p.PublisherName, u.FullName AS OrderedBy,
       a.TotalAmount, a.ReceivedDate,
       COUNT(ai.AcqItemID) AS TotalTitles,
       SUM(ai.Quantity)    AS TotalBooks
FROM   BookAcquisitions a
JOIN   Publishers p     ON a.PublisherID = p.PublisherID
JOIN   Users      u     ON a.OrderedBy   = u.UserID
LEFT JOIN AcquisitionItems ai ON a.AcquisitionID = ai.AcquisitionID
GROUP BY a.AcquisitionID, a.OrderDate, a.Status,
         p.PublisherName, u.FullName, a.TotalAmount, a.ReceivedDate;

-- ============================================================
--  STORED PROCEDURES (4+)
-- ============================================================

DELIMITER $$

-- SP 1: Issue a book to a member (with transaction)
CREATE PROCEDURE sp_IssueBook(
    IN  p_MemberID  INT,
    IN  p_BookID    INT,
    IN  p_IssuedBy  INT,
    IN  p_DueDays   INT,
    OUT p_LoanID    INT,
    OUT p_Message   VARCHAR(200)
)
BEGIN
    DECLARE v_Available INT DEFAULT 0;
    DECLARE v_Active    INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_LoanID  = -1;
        SET p_Message = 'Error issuing book. Transaction rolled back.';
    END;

    SELECT AvailableCopies INTO v_Available FROM Books WHERE BookID = p_BookID;
    SELECT COUNT(*) INTO v_Active FROM Loans
    WHERE MemberID = p_MemberID AND Status = 'Active';

    IF v_Available <= 0 THEN
        SET p_LoanID  = -1;
        SET p_Message = 'No copies available for this book.';
    ELSEIF v_Active >= 5 THEN
        SET p_LoanID  = -1;
        SET p_Message = 'Member has reached maximum active loans.';
    ELSE
        START TRANSACTION;

        INSERT INTO Loans (MemberID, BookID, IssuedBy, DueDate, Status)
        VALUES (p_MemberID, p_BookID, p_IssuedBy,
                DATE_ADD(CURDATE(), INTERVAL COALESCE(p_DueDays, 14) DAY), 'Active');

        SET p_LoanID = LAST_INSERT_ID();

        UPDATE Books SET AvailableCopies = AvailableCopies - 1 WHERE BookID = p_BookID;

        COMMIT;
        SET p_Message = 'Book issued successfully.';
    END IF;
END$$

-- SP 2: Return a book and calculate fine
CREATE PROCEDURE sp_ReturnBook(
    IN  p_LoanID     INT,
    IN  p_Condition  VARCHAR(20),  -- 'Good', 'Damaged', 'Lost'
    IN  p_UserID     INT,
    IN  p_FinePerDay DECIMAL(6,2),
    OUT p_FineAmount DECIMAL(8,2),
    OUT p_Message    VARCHAR(200)
)
BEGIN
    DECLARE v_BookID    INT;
    DECLARE v_MemberID  INT;
    DECLARE v_DueDate   DATE;
    DECLARE v_DaysLate  INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_FineAmount = 0;
        SET p_Message = 'Error returning book. Transaction rolled back.';
    END;

    SELECT BookID, MemberID, DueDate INTO v_BookID, v_MemberID, v_DueDate
    FROM Loans WHERE LoanID = p_LoanID AND Status = 'Active';

    IF v_BookID IS NULL THEN
        SET p_FineAmount = 0;
        SET p_Message = 'Loan not found or already returned.';
    ELSE
        START TRANSACTION;

        SET v_DaysLate = GREATEST(0, DATEDIFF(CURDATE(), v_DueDate));
        SET p_FineAmount = 0;

        IF p_Condition = 'Damaged' THEN
            SET p_FineAmount = 500;
        ELSEIF p_Condition = 'Lost' THEN
            SET p_FineAmount = 2000;
        ELSEIF v_DaysLate > 0 THEN
            SET p_FineAmount = v_DaysLate * COALESCE(p_FinePerDay, 10);
        END IF;

        UPDATE Loans
        SET Status = IF(p_Condition = 'Lost', 'Lost', 'Returned'),
            ReturnDate = CURDATE()
        WHERE LoanID = p_LoanID;

        IF p_FineAmount > 0 THEN
            INSERT INTO Fines (LoanID, MemberID, FineAmount, Reason)
            VALUES (p_LoanID, v_MemberID, p_FineAmount,
                    IF(p_Condition IN ('Damaged','Lost'), p_Condition, 'Overdue'));
        END IF;

        IF p_Condition != 'Lost' THEN
            UPDATE Books SET AvailableCopies = AvailableCopies + 1 WHERE BookID = v_BookID;
        END IF;

        COMMIT;
        SET p_Message = CONCAT('Book returned. Fine: Rs. ', p_FineAmount);
    END IF;
END$$

-- SP 3: Monthly loans report
CREATE PROCEDURE sp_MonthlyLoansReport(
    IN p_Year  INT,
    IN p_Month INT
)
BEGIN
    SELECT l.LoanID, m.FullName AS MemberName, m.MemberType,
           b.Title, b.Author, c.CategoryName,
           l.IssueDate, l.DueDate, l.ReturnDate, l.Status,
           COALESCE(f.FineAmount, 0) AS Fine
    FROM   Loans l
    JOIN   Members    m ON l.MemberID    = m.MemberID
    JOIN   Books      b ON l.BookID      = b.BookID
    JOIN   Categories c ON b.CategoryID  = c.CategoryID
    LEFT JOIN Fines   f ON l.LoanID      = f.LoanID
    WHERE  YEAR(l.IssueDate)  = p_Year
      AND  MONTH(l.IssueDate) = p_Month
    ORDER BY l.IssueDate;
END$$

-- SP 4: Search books
CREATE PROCEDURE sp_SearchBooks(
    IN p_SearchTerm VARCHAR(150),
    IN p_CategoryID INT
)
BEGIN
    SELECT b.BookID, b.Title, b.Author, b.ISBN,
           c.CategoryName, b.AvailableCopies,
           b.TotalCopies, b.ShelfLocation, b.Language
    FROM Books b
    JOIN Categories c ON b.CategoryID = c.CategoryID
    WHERE b.IsActive = 1
      AND (p_SearchTerm IS NULL
           OR b.Title  LIKE CONCAT('%', p_SearchTerm, '%')
           OR b.Author LIKE CONCAT('%', p_SearchTerm, '%')
           OR b.ISBN   LIKE CONCAT('%', p_SearchTerm, '%'))
      AND (p_CategoryID IS NULL OR b.CategoryID = p_CategoryID)
    ORDER BY b.Title;
END$$

DELIMITER ;

-- ============================================================
--  TRIGGERS (3+)
-- ============================================================

DELIMITER $$

-- Trigger 1: Prevent loan if no copies available
CREATE TRIGGER trg_CheckAvailability_BeforeInsert
BEFORE INSERT ON Loans
FOR EACH ROW
BEGIN
    DECLARE v_Avail INT;
    SELECT AvailableCopies INTO v_Avail FROM Books WHERE BookID = NEW.BookID;
    IF v_Avail <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No available copies for this book.';
    END IF;
END$$

-- Trigger 2: Audit trail on Books update
CREATE TRIGGER trg_Audit_Book_Update
AFTER UPDATE ON Books
FOR EACH ROW
BEGIN
    INSERT INTO AuditTrail (TableName, RecordID, Action, OldValue, NewValue)
    VALUES (
        'Books',
        OLD.BookID,
        'UPDATE',
        CONCAT('Title=', OLD.Title, ', AvailCopies=', OLD.AvailableCopies),
        CONCAT('Title=', NEW.Title, ', AvailCopies=', NEW.AvailableCopies)
    );
END$$

-- Trigger 3: Mark loan as Overdue if DueDate passed on status check
CREATE TRIGGER trg_MarkOverdue_BeforeUpdate
BEFORE UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Active' AND CURDATE() > NEW.DueDate THEN
        SET NEW.Status = 'Overdue';
    END IF;
END$$

DELIMITER ;

-- ============================================================
--  SEED DATA
-- ============================================================

-- Roles
INSERT INTO Roles (RoleName, Description) VALUES
('Admin',      'Full system access'),
('Librarian',  'Manage loans, returns and books'),
('Manager',    'Reports and acquisitions'),
('Receptionist','Member registration and queries');

-- Default admin user (password: Admin@123)
INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, RoleID) VALUES
('admin',       SHA2('Admin@123', 256), 'System Administrator', 'admin@library.com',  '03001234567', 1),
('usman_lib',   SHA2('Usman@123', 256), 'Usman Tariq',         'usman@library.com',  '03011234567', 2),
('hina_mgr',    SHA2('Hina@123',  256), 'Hina Malik',          'hina@library.com',   '03021234567', 3);

-- Categories (Genres)
INSERT INTO Categories (CategoryName, Description) VALUES
('Fiction',          'Novels and fictional stories'),
('Non-Fiction',      'Factual and informational books'),
('Science',          'Natural and applied sciences'),
('Technology',       'Computer science and engineering books'),
('History',          'Historical accounts and biographies'),
('Islamic Studies',  'Quran, Hadith, Fiqh and Islamic literature'),
('Mathematics',      'Pure and applied mathematics'),
('Medicine',         'Medical and health sciences'),
('Business',         'Economics, management and finance'),
('Children',         'Books for young readers');

-- Publishers
INSERT INTO Publishers (PublisherName, ContactName, Email, Phone, Address, City) VALUES
('Oxford University Press PK', 'Asim Raza',   'asim@oup.pk',      '04235678901', '2 Mozang Rd',        'Lahore'),
('Ferozesons Publishers',      'Saba Yusuf',  'saba@ferozesons.pk','02134567890', 'Urdu Bazaar',        'Karachi'),
('Maktabat Al Bushra',         'Tariq Noman', 'tariq@bushra.pk',  '04145678901', 'Urdu Bazaar',        'Lahore'),
('Paramount Books',            'Rabia Shah',  'rabia@paramount.pk','05156789012', 'Jinnah Super',       'Islamabad'),
('Sang-e-Meel Publications',   'Bilal Meer',  'bilal@sangmeel.pk', '04267890123', 'Shahalam Market',   'Lahore');

-- Membership Plans
INSERT INTO MembershipPlans (PlanName, DurationDays, MaxBooksAllowed, LoanPeriodDays, FeeAmount, Description) VALUES
('Basic',     180, 2, 14,    0, 'Free plan for students'),
('Standard',  365, 4, 21,  500, 'Annual plan for faculty'),
('Premium',   365, 6, 30, 1000, 'Annual premium access'),
('Guest',      30, 1,  7,    0, 'Short-term visitor plan');

-- Books
INSERT INTO Books (Title, ISBN, CategoryID, PublisherID, Author, PublishYear, TotalCopies, AvailableCopies, ShelfLocation, Language) VALUES
('Alchemist, The',              '9780062315007', 1, 1, 'Paulo Coelho',        2014, 5, 5, 'A1-01', 'English'),
('Sapiens: A Brief History',    '9780062316097', 2, 2, 'Yuval Noah Harari',   2015, 4, 4, 'B2-03', 'English'),
('Clean Code',                  '9780132350884', 4, 1, 'Robert C. Martin',    2008, 3, 3, 'C3-05', 'English'),
('Riyad as-Salihin',            '9789960897752', 6, 3, 'Imam an-Nawawi',      2010, 6, 6, 'D4-01', 'Urdu'),
('Calculus Early Transcendentals','9781285741550',7, 4, 'James Stewart',       2015, 4, 4, 'E5-02', 'English'),
('Principles of Economics',     '9781305585126', 9, 1, 'N. Gregory Mankiw',   2017, 3, 3, 'F6-04', 'English'),
('Data Structures & Algorithms','9780072462098', 4, 2, 'Michael T. Goodrich', 2014, 4, 4, 'C3-07', 'English'),
('Pakistan: A Hard Country',    '9781610392037', 5, 5, 'Anatol Lieven',       2011, 2, 2, 'B2-09', 'English'),
('Harrison Principles of Medicine','9780071802154',8,4,'Dennis Kasper',       2015, 3, 3, 'G7-01', 'English'),
('Bagh-o-Bahar (Urdu Classic)', '9789696010070', 1, 5, 'Mir Amman Dehlavi',   2005, 5, 5, 'A1-10', 'Urdu'),
('Thinking Fast and Slow',      '9780374533557', 2, 1, 'Daniel Kahneman',     2013, 3, 3, 'B2-05', 'English'),
('Introduction to Algorithms',  '9780262033848', 4, 4, 'Thomas H. Cormen',    2009, 3, 3, 'C3-02', 'English'),
('Seerat Ibn Hisham (Urdu)',    '9789696441045', 6, 3, 'Ibn Hisham',          2018, 4, 4, 'D4-03', 'Urdu'),
('Atomic Habits',               '9780735211292', 2, 2, 'James Clear',         2018, 4, 4, 'B2-07', 'English'),
('Database System Concepts',    '9780073523323', 4, 1, 'Abraham Silberschatz', 2020, 3, 3, 'C3-09', 'English');

-- Members
INSERT INTO Members (FullName, CNIC, Phone, Email, Gender, MemberType) VALUES
('Ahmed Hassan',    '3520112345671', '03001111111', 'ahmed@student.edu.pk',  'Male',   'Student'),
('Fatima Noor',     '3520212345672', '03012222222', 'fatima@student.edu.pk', 'Female', 'Student'),
('Dr. Usman Tariq', '3520312345673', '03023333333', 'usman@faculty.edu.pk',  'Male',   'Faculty'),
('Ayesha Siddiqui', '3520412345674', '03034444444', 'ayesha@gmail.com',      'Female', 'Public'),
('Bilal Akhtar',    '3520512345675', '03045555555', NULL,                    'Male',   'Student');

-- Settings
INSERT INTO Settings (SettingKey, SettingValue, Description) VALUES
('LibraryName',    'Al-Farabi University Library', 'Name shown on slips'),
('LibraryAddress', '45 University Road, Lahore',   'Address on receipts'),
('LibraryPhone',   '042-35678901',                 'Contact number'),
('FinePerDay',     '10',                            'Daily overdue fine in Rs.'),
('SlipFooter',     'Knowledge is a treasure!',     'Footer message on issue slip'),
('LowStockAlert',  '1',                             'Alert when AvailableCopies = 0');

-- ============================================================
--  USEFUL QUERIES FOR TESTING
-- ============================================================

-- Available books
SELECT * FROM vw_AvailableBooks LIMIT 10;

-- Active loans with overdue
SELECT * FROM vw_ActiveLoans;

-- Unpaid fines
SELECT * FROM vw_UnpaidFines;

-- Most popular books
SELECT * FROM vw_PopularBooks ORDER BY TotalLoans DESC LIMIT 5;

-- Call stored procedures
CALL sp_SearchBooks('algorithm', NULL);
CALL sp_MonthlyLoansReport(2026, 6);

SELECT 'LibraryMS database created successfully!' AS Status;

# 📚 Library Management System
### DBS26IST2ndAF — Database Systems | Semester Final Project
### University of Engineering and Technology, Lahore
### Computer Engineering Department

---

## 👥 Group Members

| Name | Roll Number | GitHub |
|------|-------------|--------|
| [Yasir Hussain] | [53] | [@yasir06221122-ui] |
| [Talha] | [34] | [@rajatalha] |
| [Saad Ahmed] | [52] | [@saad ahmed] |
| [Member 4 Full Name] | [Roll No] | [@username] |

**Section:** 2nd AF  
**Instructor:** [Instructor Name]  
**Submission Date:** June 2026

---

## 📌 Project Overview

The **Library Management System (LibraryMS)** is a desktop application that digitizes and automates the day-to-day operations of a university library. It handles book inventory, member registration, loan issuance, fine collection, reservations, and acquisition orders — all backed by a normalized MySQL database with a C# Windows Forms frontend.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | C# Windows Forms (.NET Framework) |
| Backend | C# (DAL + Service Layer) |
| Database | MySQL 8.0 |
| Reports | Crystal Reports / iTextSharp (PDF) |
| Version Control | Git + GitHub |

---

## ✅ Rubric Coverage

### Database (MySQL)

| Requirement | Minimum | Our Implementation |
|-------------|---------|-------------------|
| Database Tables | 15 | **16 tables** |
| Views | 5 | **6 views** |
| Stored Procedures | 3 | **4 stored procedures** |
| Triggers | 2 | **3 triggers** |
| Constraints | 10 | **15+ FK + CHECK constraints** |
| Transactions | 3 | **3 (Issue, Return, Acquisition)** |
| ERD Entities | 10 | **16 entities** |

### Application

| Requirement | Status |
|-------------|--------|
| Domain Classes (min 8) | ✅ 10 classes |
| Software Classes (min 5) | ✅ 6 classes |
| Validators | ✅ Implemented |
| Exception Handling | ✅ Try-catch + ErrorLogs table |
| Logging | ✅ Logger class + DB logging |
| PDF Reports (min 10) | ✅ 10 reports |
| Responsive UI | ✅ Panels + anchoring |
| Parameter-based Reports | ✅ Date range, member, category filters |

### UI Elements Implemented
- ✅ Text boxes, password fields
- ✅ Radio buttons, checkboxes
- ✅ Dropdowns (ComboBox)
- ✅ Date selector (DateTimePicker)
- ✅ Text areas, scroll bars
- ✅ DataGridView tables with action buttons inside
- ✅ Panels on 3+ forms
- ✅ File menu on every screen
- ✅ Same form used for Add and Edit

---

## 🗂️ Project Structure

```
DBS26IST2ndAF001/
│
├── SQL/
│   └── library_db.sql          # Full DB schema + seed data
│
├── LibraryMS/                  # C# Solution
│   ├── Models/                 # Domain classes
│   │   └── Models.cs           # Book, Member, Loan, Fine, etc.
│   ├── DAL/                    # Data Access Layer
│   │   ├── DBConnection.cs
│   │   ├── BookDAL.cs
│   │   ├── MemberDAL.cs
│   │   ├── LoanDAL.cs
│   │   └── FineDAL.cs
│   ├── Services/               # Business logic
│   │   ├── LoanService.cs
│   │   └── ReportService.cs
│   ├── Utils/                  # Software classes
│   │   ├── Validator.cs
│   │   ├── Logger.cs
│   │   └── PasswordHelper.cs
│   ├── Forms/                  # UI screens
│   │   ├── LoginForm.cs
│   │   ├── DashboardForm.cs
│   │   ├── BookForm.cs
│   │   ├── MemberForm.cs
│   │   ├── LoanForm.cs
│   │   ├── FineForm.cs
│   │   └── ReportForm.cs
│   └── Reports/                # PDF report templates
│
├── Documentation/
│   ├── ERD.png                 # Entity Relationship Diagram
│   ├── UI_Mockups/             # Pencil tool wireframes
│   └── LibraryMS_Report.pdf    # Final documentation
│
└── README.md
```

---

## 🗃️ Database Schema

### Tables (16)

| # | Table | Description |
|---|-------|-------------|
| 1 | Roles | Staff role definitions |
| 2 | Users | Library staff accounts |
| 3 | Publishers | Book publishers/suppliers |
| 4 | Categories | Book genres and categories |
| 5 | Books | Book inventory with copy tracking |
| 6 | Members | Registered library members |
| 7 | MembershipPlans | Plan types (Basic, Standard, Premium) |
| 8 | MemberPlanHistory | Member plan assignment history |
| 9 | Loans | Book borrowing records |
| 10 | Fines | Overdue/damage/lost fines |
| 11 | Reservations | Book reservation queue |
| 12 | BookAcquisitions | Purchase order headers |
| 13 | AcquisitionItems | Purchase order line items |
| 14 | AuditTrail | Change tracking on all tables |
| 15 | ErrorLogs | Application error logging |
| 16 | Settings | System configuration |

### Views (6)

| View | Purpose |
|------|---------|
| `vw_AvailableBooks` | Books with copies ready to loan |
| `vw_ActiveLoans` | All active loans with overdue detection |
| `vw_UnpaidFines` | Outstanding fines across all members |
| `vw_PopularBooks` | Most borrowed books ranking |
| `vw_MemberLoanHistory` | Complete borrowing history per member |
| `vw_AcquisitionOverview` | Purchase order status dashboard |

### Stored Procedures (4)

| Procedure | Description |
|-----------|-------------|
| `sp_IssueBook` | Issues a book to a member with availability check |
| `sp_ReturnBook` | Processes return and auto-calculates fine |
| `sp_MonthlyLoansReport` | Generates monthly activity report |
| `sp_SearchBooks` | Parameterized book search by title/author/category |

### Triggers (3)

| Trigger | Event | Purpose |
|---------|-------|---------|
| `trg_CheckAvailability_BeforeInsert` | BEFORE INSERT on Loans | Blocks loan if no copies available |
| `trg_Audit_Book_Update` | AFTER UPDATE on Books | Logs all book record changes |
| `trg_MarkOverdue_BeforeUpdate` | BEFORE UPDATE on Loans | Auto-flags overdue status |

---

## 🏛️ Domain Classes (10)

1. `Book` — Title, ISBN, Author, Copies, ShelfLocation
2. `Member` — Personal info, MemberType, active status
3. `Loan` — IssueDate, DueDate, ReturnDate, Status
4. `Fine` — Amount, Reason, PaidStatus
5. `Reservation` — BookID, MemberID, ExpiryDate, Status
6. `User` — Staff login credentials and role
7. `Publisher` — Supplier details for acquisitions
8. `Category` — Book genre classification
9. `BookAcquisition` — Purchase order with items
10. `MembershipPlan` — Plan rules and fee structure

## ⚙️ Software Classes (6)

1. `DBConnection` — Singleton MySQL connection manager
2. `Validator` — Input validation for all forms
3. `Logger` — Writes errors to DB and log file
4. `PasswordHelper` — SHA-256 hashing
5. `SessionManager` — Tracks logged-in user and role
6. `ReportService` — Generates and exports PDF reports

---

## 📊 PDF Reports (10)

| # | Report | Parameters |
|---|--------|-----------|
| 1 | Daily Loans Report | Date |
| 2 | Monthly Activity Summary | Month, Year |
| 3 | Overdue Loans List | As of date |
| 4 | Unpaid Fines Collection | Member, Date range |
| 5 | Book Inventory Report | Category filter |
| 6 | Most Popular Books | Top N, Date range |
| 7 | Member Registration Report | Month, MemberType |
| 8 | Fine Collection Summary | Date range |
| 9 | Book Acquisition History | Publisher, Status |
| 10 | Member Loan History | MemberID |

---

## 🚀 How to Run

### Database Setup
```sql
-- 1. Open MySQL Workbench
-- 2. Run the script:
SOURCE SQL/library_db.sql;

-- 3. Verify:
SELECT 'LibraryMS database created successfully!' AS Status;
```

### Application Setup
```
1. Open LibraryMS.sln in Visual Studio
2. Update connection string in App.config:
   Server=localhost; Database=LibraryMS; Uid=root; Pwd=yourpassword;
3. Build Solution (Ctrl+Shift+B)
4. Run (F5)
```

### Default Login
```
Username: admin
Password: Admin@123
```

---

## 📋 Submission Checklist

- [x] GitHub repository created
- [x] All group members added as collaborators
- [x] SQL script uploaded and tested
- [ ] C# application complete
- [ ] ERD diagram added
- [ ] UI mockups (Pencil tool) added
- [ ] 10 PDF reports working
- [ ] Final documentation (ring-bound) ready
- [ ] Rubric printed separately (single hard copy, not binded)

---

*University of Engineering and Technology, Lahore — Computer Engineering Department*

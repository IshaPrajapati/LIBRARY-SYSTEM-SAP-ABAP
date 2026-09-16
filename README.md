# 📚 SAP ABAP Library Management System (`ZA16_LIBRARY_MANAGEMENT`)

An enterprise-grade **SAP NetWeaver ABAP Module Pool (Dynpro)** application engineered for institutional and academic library automation. The system manages student authentication, catalog search, book issue/return tracking, profile maintenance, and multi-table data joins, paired with a pixel-perfect **SAP GUI Web Simulator** for local testing without requiring an enterprise SAP server.

![SAP NetWeaver](https://img.shields.io/badge/SAP%20NetWeaver-7.5%2B-blue.svg?style=flat-square&logo=sap)
![Language](https://img.shields.io/badge/Language-ABAP%20%7C%20HTML5%20%7C%20JS-blueviolet?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Module%20Pool%20%2F%20Dynpro-teal?style=flat-square)
![Author](https://img.shields.io/badge/Author-Isha%20Prajapati-orange?style=flat-square&logo=github)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

---

## 📖 Project Overview & Objectives

The **SAP ABAP Library Management System** is designed to streamline day-to-day administrative operations of a high-volume library. Built on standard SAP Dialog Programming (Dynpro) paradigms, the system provides automated book issue and return workflows, inventory discovery, dynamic SQL joins, and self-service student account management.

### Key Objectives:
1. **Automated Inventory Control:** Prevent duplicate borrowing of the same title by a single student while dynamically maintaining book availability status.
2. **Standardized Dialog Flow:** Follow SAP GUI 7.xx Signature Theme user interaction standards, complete with function codes (OK Codes), PBO/PAI lifecycle handling, and Table Controls.
3. **Relational Data Integrity:** Implement 4 custom ABAP Dictionary (SE11) tables with strict foreign key relationships, automated sequence generators, and client-dependent (`MANDT`) tenancy.
4. **Dual Execution Runtime:** Run natively inside SAP NetWeaver AS ABAP (SE38/SE80) or execute instantly in any web browser via the included standalone Web Runner.

---

## 🧩 Core Modules & Functionality

The application is structured into **8 core Dynpro dialog screens** orchestrated by modularized ABAP include programs:

### 1. Authentication & Session Management (`Screen 1000`)
- Validates user credentials against custom DDIC table `ZA16_L_LOGIN` via `SELECT SINGLE`.
- Verifies system response code `SY-SUBRC`. Upon success (`SY-SUBRC = 0`), sets the session context and branches to the main dashboard (`CALL SCREEN 1001`).
- Displays descriptive SAP status/information dialogs (`MESSAGE 'ENTER THE CORRECT VALUE' TYPE 'I'`) upon invalid login attempts.

### 2. Main Navigation Dashboard / Control Center (`Screen 1001`)
- Acts as the central transaction dispatcher for all library operations.
- Dynamically queries student name from `ZA16_L_INFO` based on active student ID during Process Before Output (`PBO`).
- Dispatches navigation to sub-screens via function codes: `SEARCH` (1004), `GET` (1005), `RETURN` (1006), `SHOW` (1007), `UPDATE` (1008), and `LOGOUT` (1000).

### 3. Two-Step Student Onboarding & Registration (`Screens 1002 & 1003`)
- **Step 1 (`Screen 1002`):** Validates new user credentials, checks against existing users, verifies matching password confirmation, auto-increments student ID (`SELECT MAX( stu_id )`), and creates login records.
- **Step 2 (`Screen 1003`):** Collects comprehensive student demographics (Full Name, Gender radio buttons, Degree, Branch, Roll Number, Residential Address, and Registration Timestamp) and inserts into `ZA16_L_INFO`.

### 4. Real-Time Catalog Discovery with Table Control `LIB1` (`Screen 1004`)
- Implements dynamic catalog search across **44+ curated books** categorized into:
  - 💻 **Computer Science & Software Engineering** (*Clean Code*, *Pragmatic Programmer*, *Design Patterns*, *CLRS Algorithms*, *DDIA*)
  - 🏢 **SAP & Enterprise Architecture** (*SAP ABAP Complete Reference*, *ABAP Objects*, *SAP Fiori*, *SAP S/4HANA*, *HANA 2.0*, *CDS Views*)
  - 🚀 **Sci-Fi, Fantasy & Timeless Classics** (*Dune*, *Foundation*, *1984*, *Brave New World*, *The Hobbit*, *Neuromancer*)
  - 🔬 **Science, Mathematics & Physics** (*A Brief History of Time*, *The Selfish Gene*, *Cosmos*, *The Elegant Universe*)
  - 🧠 **Business, Psychology & Mindset** (*Atomic Habits*, *Thinking, Fast and Slow*, *Deep Work*, *The Psychology of Money*)
- Features instant debounced live search, category filter pills, stock status indicators (`AVAILABLE` vs `ISSUED`), and direct 1-click book borrowing.

### 5. Book Issuance Engine (`Screen 1005`)
- Fetches book metadata from `ZA16_L_BOOK_INFO` by Book ID.
- Runs business rule validation: verifies whether the book is already active under the current student loan list.
- Calculates transaction date and issues book by generating a new `GET_ID` in transaction table `ZA16_L_GETBOOK`.

### 6. Loan Return & Settlement Engine (`Screen 1006`)
- Retrieves active loan record using `GET_ID`.
- Displays book title, author, issuance date, and calculated return date.
- Executes return by removing/settling the loan record in `ZA16_L_GETBOOK` with confirmation messaging.

### 7. Active Borrowings Inner Join with Table Control `EDWR` (`Screen 1007`)
- Executes an **Open SQL Inner Join** linking student demographics and loan records:
  ```abap
  SELECT za16_l_info~stu_id, za16_l_info~user_id, za16_l_info~name,
         za16_l_info~roll, za16_l_info~field, za16_l_info~date_and_time,
         za16_l_getbook~get_id, za16_l_getbook~book_id,
         za16_l_getbook~author, za16_l_getbook~car_date
    INTO CORRESPONDING FIELDS OF TABLE it_join
    FROM za16_l_info INNER JOIN za16_l_getbook
    ON za16_l_info~stu_id = za16_l_getbook~stu_id
    WHERE za16_l_info~stu_id = stu_id.
  ```
- Renders the resulting dataset in an interactive SAP Table Control with 1-click return actions.

### 8. Profile Maintenance & Master Data Sync (`Screen 1008`)
- Allows students to update their contact details, degree, branch, and residential address in table `ZA16_L_INFO`.
- Pre-fills current values during PBO and executes `UPDATE za16_l_info FROM wa_update` during PAI.

---

## 🏛️ System Architecture & Dynpro Lifecycle

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        SAP GUI / Live Web Simulator Frontend                           │
│                      (Screens 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008)    │
└───────────────────────────────────────────┬────────────────────────────────────────────┘
                                            │
                     ┌──────────────────────┴──────────────────────┐
                     │                                             │
                     ▼                                             ▼
       ┌───────────────────────────┐                 ┌───────────────────────────┐
       │  PBO (Process Before O/P) │                 │  PAI (Process After I/P)  │
       │  • STATUS_1000 - 1008     │                 │  • USER_COMMAND_1000-1008 │
       │  • Data pre-fill & checks │                 │  • Function code handling │
       │  • TableControl init/move │                 │  • Validation & commits   │
       └─────────────┬─────────────┘                 └─────────────┬─────────────┘
                     │                                             │
                     └──────────────────────┬──────────────────────┘
                                            │
                                            ▼
         ┌─────────────────────────────────────────────────────────────────────┐
         │              Report ZA16_LIBRARY_MANAGEMENT & Includes              │
         │  • ZA16_LOGIN_PAGE.ABAP         • ZA16_HOME_PAGE.ABAP               │
         │  • ZA16_REGISTRATION_PAGE.ABAP  • ZA16_SEARCH_BOOK.ABAP             │
         │  • ZA16_UPDATE_PROFILE.ABAP     • Table Controls (LIB1, EDWR)       │
         └──────────────────────────────────┬──────────────────────────────────┘
                                            │
                                            ▼
         ┌─────────────────────────────────────────────────────────────────────┐
         │                   ABAP Dictionary (SE11) Tables                     │
         │  • ZA16_L_LOGIN    (User Credentials & Student IDs)                 │
         │  • ZA16_L_INFO     (Student Profiles, Degrees & Branch Details)     │
         │  • ZA16_L_BOOK_INFO(Catalog of Books, Authors, & Pricing)           │
         │  • ZA16_L_GETBOOK  (Issued Books, Loan Dates & Return Tracking)     │
         └─────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ ABAP Dictionary (SE11) Data Model

### 1. `ZA16_L_LOGIN` (Authentication & Credentials)
| Field | Key | Data Element | Type | Length | Description |
| :--- | :---: | :--- | :---: | :---: | :--- |
| `MANDT` | **Key** | `MANDT` | CLNT | 3 | Client Identifier |
| `STU_ID` | **Key** | `ZA16_STU_ID` | INT2 | 5 | Student Unique ID |
| `USER_ID`| **Key** | `ZA16_USER_ID`| CHAR | 13 | Login Username / Mobile |
| `PASSWORD`| | `ZA16_PASSWORD`| CHAR | 13 | Account Password |

### 2. `ZA16_L_INFO` (Student Master Demographics)
| Field | Key | Data Element | Type | Length | Description |
| :--- | :---: | :--- | :---: | :---: | :--- |
| `MANDT` | **Key** | `MANDT` | CLNT | 3 | Client Identifier |
| `STU_ID` | **Key** | `ZA16_STU_ID` | INT2 | 5 | Student ID Reference |
| `USER_ID`| **Key** | `ZA16_USER_ID`| CHAR | 13 | Username Reference |
| `ROLL` | **Key** | `ZA16_ROLLNO` | INT1 | 3 | Institutional Roll Number |
| `NAME` | | `ZA16_NAME` | CHAR | 30 | Student Full Name |
| `GENDER` | | `ZA16_GENDER` | CHAR | 10 | Gender (Male/Female/Others)|
| `DEGREE` | | `ZA16_DEGREE` | CHAR | 50 | Academic Degree (e.g. B.Tech)|
| `FIELD` | | `ZA16_FIELD` | CHAR | 50 | Branch / Specialization |
| `ADDRESS`| | `ZA16_ADDRESS`| CHAR | 255| Residential Address |
| `DATE_AND_TIME`| | `ZA16_DT` | CHAR | 100| Registration Date & Time |

### 3. `ZA16_L_BOOK_INFO` (Book Master Catalog)
| Field | Key | Data Element | Type | Length | Description |
| :--- | :---: | :--- | :---: | :---: | :--- |
| `MANDT` | **Key** | `MANDT` | CLNT | 3 | Client Identifier |
| `BOOK_ID`| **Key** | `ZA16_BOOK_ID`| INT2 | 5 | Book Unique Identifier |
| `BOOK_NAME`| | `ZA16_BOOK_NAME`| CHAR | 50 | Title of Book |
| `AUTHOR` | | `ZA16_AUTHOR` | CHAR | 20 | Author Name |
| `PRICES` | | `ZA16_PRICES` | CHAR | 10 | Book Price / Value |

### 4. `ZA16_L_GETBOOK` (Active Book Issuance & Loans)
| Field | Key | Data Element | Type | Length | Description |
| :--- | :---: | :--- | :---: | :---: | :--- |
| `MANDT` | **Key** | `MANDT` | CLNT | 3 | Client Identifier |
| `GET_ID` | **Key** | `ZA16_GET_ID` | INT2 | 5 | Issue / Loan Transaction ID |
| `STU_ID` | **Key** | `ZA16_STU_ID` | INT2 | 5 | Borrowing Student ID |
| `BOOK_ID`| **Key** | `ZA16_BOOK_ID`| INT2 | 5 | Borrowed Book ID |
| `BOOK_NAME`| | `ZA16_BOOK_NAME`| CHAR | 50 | Book Title |
| `AUTHOR` | | `ZA16_AUTHOR` | CHAR | 20 | Author Name |
| `ADDITION`| | `ZA16_ADDITION`| CHAR | 20 | Edition / Remarks |
| `CAR_DATE`| | `ZA16_DATE` | CHAR | 20 | Issue Date (DD/MM/YYYY) |

---

## 📂 Repository File Structure

```
├── ZA16_LIBRARY_MANAGEMENT.ABAP   # Main Report & Dynpro Module Pool Orchestrator
├── INCLUDE PROGRAMS/              # Modularized Business Logic Includes
│   ├── ZA16_LOGIN_PAGE.ABAP       # Screen 1000 PBO/PAI Modules
│   ├── ZA16_HOME_PAGE.ABAP        # Screen 1001 Navigation Dispatcher
│   ├── ZA16_REGISTRATION_PAGE.ABAP# Screens 1002 & 1003 Student Registration Modules
│   ├── ZA16_SEARCH_BOOK.ABAP      # Screen 1004 Catalog Search & TableControl Logic
│   └── ZA16_UPDATE_PROFILE.ABAP   # Screen 1008 Profile Maintenance Logic
├── SCREEN/                        # Dynpro Screen Flow Logic & Layouts
│   ├── 1000 - LOGIN PAGE.ABAP     # PBO/PAI flow for Screen 1000
│   ├── 1001 - HOME PAGE.ABAP      # PBO/PAI flow for Screen 1001
│   ├── 1002 - REGISTRATION PAGE 1.ABAP
│   ├── 1003 - REGISTRATION PAGE 2.ABAP
│   ├── 1004 - SEARCH BOOK.ABAP    # Table Control 'LIB1' PBO loop
│   ├── 1005 - GET BOOK.ABAP       # Book issue module
│   ├── 1006 - RETURN BOOK.ABAP    # Return transaction module
│   ├── 1007 SHOW BOOK.ABAP        # Table Control 'EDWR' Inner Join loop
│   └── 1008 UPDATE PROFILE.ABAP   # Profile updater module
├── TABLE/                         # Original SAP SE11 Table Definitions
├── screenshots/                   # Application Screen Previews
├── index.html                     # Full-fidelity SAP GUI Web Simulator & Live Runner
├── server.py                      # Local Python HTTP server with auto-browser launcher
├── run.bat                        # Windows 1-click execution launcher
└── push.bat                       # Windows 1-click GitHub push script
```

---

## ⚡ How to Run the Interactive Web Simulator

The included standalone simulator runs directly on your local machine without needing an enterprise SAP server:

### Option 1: Python HTTP Server (Recommended)
```bash
python server.py
```
*The server starts on `http://localhost:8085` and automatically opens your default web browser.*

### Option 2: Windows 1-Click Batch Launcher
Double-click `run.bat` in Windows Explorer.

### Option 3: Direct File Execution
Open `index.html` directly in Google Chrome, Microsoft Edge, or Mozilla Firefox.

#### Default Demo Credentials:
- **User ID:** `SIBI` | **Password:** `password123`
- *Or click **CREATE NEW ACCOUNT** to test self-service student onboarding!*

---

## 🛠️ Deploying to an SAP NetWeaver System (ECC / S4HANA)

1. **SE11 (ABAP Dictionary):** Create tables `ZA16_L_LOGIN`, `ZA16_L_INFO`, `ZA16_L_BOOK_INFO`, and `ZA16_L_GETBOOK` with domain/data elements as specified in the schema table above.
2. **SE38 / SE80 (ABAP Workbench):** Create program `ZA16_LIBRARY_MANAGEMENT` as an executable/module pool program and upload the 5 files from `INCLUDE PROGRAMS/`.
3. **SE51 (Screen Painter):** Create Dynpro screens **1000 through 1008**, paste the flow logic from `SCREEN/`, and define the corresponding screen elements (input/output fields, pushbuttons, Table Controls `LIB1` and `EDWR`).
4. **SE93 (Transaction Maintenance):** Create a custom transaction code (e.g. `ZLIB`) bound to program `ZA16_LIBRARY_MANAGEMENT` with initial screen `1000`.

---

## 📸 Application Screenshots

### 1. Interactive Book Search & Catalog (`Screen 1004`)
*Dynamic real-time search across 44+ famous books with category filter pills, stock availability indicators, and 1-click borrowing.*

![Screen 1004 - Search Books Details](screenshots/screen_1004_search_books.png)

---

### 2. Main Navigation Dashboard / Home Page (`Screen 1001`)
*Personalized student dashboard showing active user greeting (`WELCOME Isha Prajapati`), direct module dispatching, and transaction controls.*

![Screen 1001 - Home Page](screenshots/screen_1001_home_page.png)

---

## 👤 Author & Maintainer

- **Developer:** Isha Prajapati
- **Email:** ishaprajapati207@gmail.com
- **GitHub:** [@IshaPrajapati](https://github.com/IshaPrajapati)

---

## 📄 License

This project is open source and distributed under the [MIT License](LICENSE).
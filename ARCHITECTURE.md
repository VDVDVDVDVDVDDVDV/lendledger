# LendLedger - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        LendLedger App                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Auth Screen  │  │  Dashboard   │  │ Transaction  │      │
│  │              │  │   Screen     │  │    Feed      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Add Loan     │  │   Detail     │  │   Widgets    │      │
│  │   Screen     │  │   Screen     │  │  (Cards)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Provider   │  │   Interest   │  │    Auth      │      │
│  │    State     │  │  Calculator  │  │   Service    │      │
│  │  Management  │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Database   │  │    Models    │  │    Audit     │      │
│  │   Service    │  │ (Loan, Pay)  │  │     Logs     │      │
│  │   (SQLite)   │  │              │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Platform Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Biometric   │  │  Local       │  │   Cloud      │      │
│  │    Auth      │  │  Storage     │  │   Backup     │      │
│  │ (Face/Touch) │  │  (SQLite)    │  │ (Firebase)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Adding a New Loan

```
User Input (Add Loan Screen)
         │
         ▼
Form Validation
         │
         ▼
Create Loan Model
         │
         ▼
Database Service
         │
         ├─► Insert into loans table
         │
         └─► Create audit log
         │
         ▼
Update UI (Provider)
         │
         ▼
Show Success Message
```

### Calculating Interest

```
Loan Model
         │
         ▼
Interest Calculator Service
         │
         ├─► Get time elapsed
         │
         ├─► Apply frequency (Daily/Monthly/etc)
         │
         └─► Calculate: I = P × r × t
         │
         ▼
Return Interest Amount
         │
         ▼
Display in UI
```

### Recording Payment

```
User Input (Payment Amount)
         │
         ▼
Create Payment Model
         │
         ▼
Database Service
         │
         ├─► Insert into payments table
         │
         └─► Create audit log
         │
         ▼
Recalculate Remaining Balance
         │
         ▼
Update UI
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                         main.dart                            │
│                    (App Entry Point)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  AuthenticationWrapper                       │
│              (Checks authentication state)                   │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
    Not Authenticated            Authenticated
             │                            │
             ▼                            ▼
    ┌────────────────┐          ┌────────────────┐
    │  Auth Screen   │          │   Dashboard    │
    │  (Biometric)   │          │     Screen     │
    └────────────────┘          └────────┬───────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
           ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
           │  Add Loan      │  │ Transaction    │  │   Detail       │
           │   Screen       │  │    Feed        │  │   Screen       │
           └────────────────┘  └────────────────┘  └────────────────┘
```

## Database Schema Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                         loans                                │
│  ┌────────────────────────────────────────────────────┐     │
│  │ id (PK)                                            │     │
│  │ borrower_name                                      │     │
│  │ fund_source                                        │     │
│  │ transaction_mode                                   │     │
│  │ principal_amount                                   │     │
│  │ interest_rate                                      │     │
│  │ frequency                                          │     │
│  │ loan_start_date                                    │     │
│  │ cost_of_capital                                    │     │
│  │ created_at                                         │     │
│  │ updated_at                                         │     │
│  └────────────────────────────────────────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ 1:N
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       payments                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │ id (PK)                                            │     │
│  │ loan_id (FK) ──────────────────────────────────┐  │     │
│  │ amount_paid                                     │  │     │
│  │ payment_date                                    │  │     │
│  │ created_at                                      │  │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      audit_logs                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │ id (PK)                                            │     │
│  │ action_type (CREATE/UPDATE/DELETE)                │     │
│  │ record_type (LOAN/PAYMENT)                        │     │
│  │ record_id                                          │     │
│  │ data_snapshot (JSON)                              │     │
│  │ timestamp                                          │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Provider Pattern                        │
└─────────────────────────────────────────────────────────────┘

User Action
     │
     ▼
Widget calls Provider method
     │
     ▼
Provider updates state
     │
     ▼
notifyListeners()
     │
     ▼
All listening widgets rebuild
     │
     ▼
UI updates automatically
```

## Security Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Architecture                     │
└─────────────────────────────────────────────────────────────┘

Layer 1: Biometric Authentication
         │
         ├─► FaceID / TouchID / Fingerprint
         │
         └─► Required on app launch
         
Layer 2: Data Encryption (Ready to implement)
         │
         ├─► AES-256 encryption
         │
         └─► Encrypted database
         
Layer 3: Audit Logging
         │
         ├─► Immutable deletion logs
         │
         └─► Track all data changes
         
Layer 4: Input Validation
         │
         ├─► Form validation
         │
         └─► SQL injection prevention
```

## Color Coding System

```
┌─────────────────────────────────────────────────────────────┐
│                    Visual Design System                      │
└─────────────────────────────────────────────────────────────┘

Transaction Mode:
┌──────────────┐          ┌──────────────┐
│   CASH       │          │    BANK      │
│   (Blue)     │          │   (Green)    │
│  #1976D2     │          │   #388E3C    │
└──────────────┘          └──────────────┘

Fund Source:
┌──────────────┐          ┌──────────────┐
│ Self-Funded  │          │   Borrowed   │
│   (Blue)     │          │   (Orange)   │
│  #2196F3     │          │   #FF9800    │
└──────────────┘          └──────────────┘

Status:
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│   Overdue    │          │   Success    │          │   Warning    │
│    (Red)     │          │   (Green)    │          │   (Orange)   │
│  #D32F2F     │          │   #4CAF50    │          │   #FF9800    │
└──────────────┘          └──────────────┘          └──────────────┘
```

## File Organization

```
lendledger/
│
├── lib/
│   ├── main.dart                      # Entry point
│   │
│   ├── models/                        # Data models
│   │   ├── loan.dart                  # Loan entity
│   │   ├── payment.dart               # Payment entity
│   │   └── audit_log.dart             # Audit entity
│   │
│   ├── services/                      # Business logic
│   │   ├── database_service.dart      # SQLite operations
│   │   ├── auth_service.dart          # Authentication
│   │   └── interest_calculator.dart   # Calculations
│   │
│   ├── screens/                       # UI screens
│   │   ├── auth_screen.dart           # Login
│   │   ├── dashboard_screen.dart      # Home
│   │   ├── add_transaction_screen.dart # Add loan
│   │   ├── transaction_feed_screen.dart # List
│   │   └── transaction_detail_screen.dart # Details
│   │
│   ├── widgets/                       # Reusable UI
│   │   └── transaction_card.dart      # Loan card
│   │
│   └── utils/                         # Utilities
│       └── constants.dart             # Constants
│
├── android/                           # Android config
├── ios/                               # iOS config
├── pubspec.yaml                       # Dependencies
├── README.md                          # Documentation
├── SETUP.md                           # Setup guide
├── QUICKSTART.md                      # Quick start
└── PROJECT_SUMMARY.md                 # Summary
```

## Deployment Pipeline

```
Development
     │
     ├─► Code changes
     │
     ├─► Local testing
     │
     ▼
Testing
     │
     ├─► Unit tests
     │
     ├─► Widget tests
     │
     ▼
Build
     │
     ├─► flutter build apk (Android)
     │
     ├─► flutter build ios (iOS)
     │
     ▼
Distribution
     │
     ├─► Google Play Store
     │
     └─► Apple App Store
```

## Performance Optimization

```
┌─────────────────────────────────────────────────────────────┐
│                  Performance Strategy                        │
└─────────────────────────────────────────────────────────────┘

Database:
├─► Indexed queries
├─► Batch operations
└─► Connection pooling

UI:
├─► ListView.builder (lazy loading)
├─► const constructors
└─► Efficient rebuilds with Provider

Memory:
├─► Dispose controllers
├─► Clear caches
└─► Optimize images

Build:
├─► Code splitting
├─► Tree shaking
└─► Minification
```

---

**This architecture provides:**
- ✅ Separation of concerns
- ✅ Scalability
- ✅ Maintainability
- ✅ Testability
- ✅ Security
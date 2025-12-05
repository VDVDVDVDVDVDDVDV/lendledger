# LendLedger

A professional money lending tracker app built with Flutter for managing loans, tracking interest accruals, and monitoring payment schedules.

## Features

### Core Functionality
- 🔐 **Biometric Authentication** - FaceID/Fingerprint login
- 💰 **Loan Tracking** - Track principal, interest, and payment schedules
- 📊 **Capital Source Tracking** - Distinguish between Self-Funded vs Borrowed capital
- 💳 **Transfer Mode** - Track Cash vs Bank transactions with visual color coding
- 📈 **Interest Calculation** - Automatic simple interest calculation
- 🔔 **Payment Reminders** - Notifications for due payments
- 🔒 **Local Encryption** - AES-256 encryption for all data
- ☁️ **Cloud Backup** - Optional encrypted cloud backup

### Visual Design
- **Blue Cards** - Cash transactions
- **Green Cards** - Bank/Digital transactions
- **Red Highlights** - Overdue payments

## Project Structure

```
lendledger/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── loan.dart
│   │   ├── payment.dart
│   │   └── borrower.dart
│   ├── services/                 # Business logic
│   │   ├── database_service.dart
│   │   ├── auth_service.dart
│   │   ├── interest_calculator.dart
│   │   └── notification_service.dart
│   ├── screens/                  # UI screens
│   │   ├── dashboard_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── transaction_feed_screen.dart
│   │   └── transaction_detail_screen.dart
│   ├── widgets/                  # Reusable components
│   │   ├── transaction_card.dart
│   │   ├── capital_split_chart.dart
│   │   └── due_today_list.dart
│   └── utils/                    # Utilities
│       ├── constants.dart
│       └── encryption_helper.dart
├── pubspec.yaml                  # Dependencies
└── README.md
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/VDVDVDVDVDVDDVDV/lendledger.git
cd lendledger
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Database Schema

### Loans Table
- `id` (Primary Key)
- `borrower_name`
- `fund_source` (Self-Funded / Borrowed)
- `transaction_mode` (Cash / Bank)
- `principal_amount`
- `interest_rate`
- `frequency` (Daily / Monthly / Quarterly)
- `loan_start_date`
- `cost_of_capital` (optional)
- `created_at`
- `updated_at`

### Payments Table
- `id` (Primary Key)
- `loan_id` (Foreign Key)
- `amount_paid`
- `payment_date`
- `created_at`

### Audit Logs Table
- `id` (Primary Key)
- `action_type` (CREATE / UPDATE / DELETE)
- `record_type`
- `record_id`
- `data_snapshot`
- `timestamp`

## Interest Calculation

The app uses simple interest formula:

```
I = P × r × t
```

Where:
- `I` = Interest Accrued
- `P` = Principal Amount
- `r` = Rate per period (decimal)
- `t` = Time periods elapsed

## Security Features

1. **Biometric Authentication** - Required on app launch
2. **AES-256 Encryption** - All local data encrypted
3. **Audit Logs** - Immutable deletion logs
4. **Cloud Backup** - Optional encrypted backup

## Notification System

- **T-3 Days**: Reminder notification
- **T-0 Days**: Due today notification
- **T+1 Days**: Overdue notification

Configurable notification time (default: 9:00 AM)

## Dependencies

Key Flutter packages used:
- `sqflite` - Local database
- `local_auth` - Biometric authentication
- `encrypt` - AES encryption
- `flutter_local_notifications` - Push notifications
- `fl_chart` - Charts and graphs
- `firebase_core` - Cloud backup (optional)
- `provider` - State management

## Development Roadmap

### Phase 1: MVP ✅
- [x] Project setup
- [ ] Biometric authentication
- [ ] Add/View/Delete transactions
- [ ] Basic interest calculation
- [ ] Transaction feed with color coding

### Phase 2: Advanced Features
- [ ] Dashboard with analytics
- [ ] Notification system
- [ ] Cloud backup
- [ ] Audit logs

### Phase 3: Polish
- [ ] Advanced filtering
- [ ] Payment history timeline
- [ ] Cost of capital tracking
- [ ] Reporting features

## Contributing

This is a personal project. If you'd like to contribute, please fork the repository and submit a pull request.

## License

MIT License - See LICENSE file for details

## Contact

For questions or support, please open an issue on GitHub.

---

**Built with Flutter 💙**
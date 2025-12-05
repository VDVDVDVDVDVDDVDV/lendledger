# LendLedger - Quick Start Guide

Get LendLedger up and running in 5 minutes!

## 🚀 Quick Setup (3 Steps)

### Step 1: Install Flutter
```bash
# Check if Flutter is installed
flutter --version

# If not installed, download from:
# https://flutter.dev/docs/get-started/install
```

### Step 2: Clone & Install
```bash
git clone https://github.com/VDVDVDVDVDVDDVDV/lendledger.git
cd lendledger
flutter pub get
```

### Step 3: Run
```bash
flutter run
```

That's it! 🎉

## 📱 First Time Using the App

### 1. Authentication
- On first launch, you'll see the authentication screen
- Tap "Authenticate" to use biometric login
- If biometrics aren't available, the app will allow access

### 2. Add Your First Loan
1. Tap the **"Add Loan"** button (floating action button)
2. Fill in the details:
   - **Borrower Name**: Who you're lending to
   - **Fund Source**: Self-Funded or Borrowed
   - **Transaction Mode**: Cash (Blue) or Bank (Green)
   - **Principal Amount**: The loan amount
   - **Interest Rate**: Rate per period (%)
   - **Frequency**: Daily, Monthly, Quarterly, or Yearly
   - **Start Date**: When the loan began
3. Tap **"Save"**

### 3. View Dashboard
The dashboard shows:
- **Total Outstanding**: All active principal
- **Interest Accrued**: Total interest earned
- **Capital Distribution**: Self-funded vs Borrowed
- **Due Today**: Payments due today

### 4. Manage Loans
- **View All**: Tap "View All Loans" on dashboard
- **Filter**: Use the filter icon (top-right) to filter by:
  - All Transactions
  - Cash Only (Blue cards)
  - Bank Only (Green cards)
  - Overdue Only
- **Details**: Tap any loan card to see full details

### 5. Record Payments
1. Open a loan's detail page
2. Tap **"Mark Paid"** button
3. Enter the amount paid
4. Tap "Record"

## 🎨 Understanding the Color System

### Transaction Cards
- **Blue Border** = Cash transactions
- **Green Border** = Bank/Digital transactions

### Status Indicators
- **Red Badge** = Overdue payment
- **Blue Badge** = Due date
- **Green Text** = Interest earned

### Fund Source Tags
- **Blue Tag** = Self-Funded capital
- **Orange Tag** = Borrowed capital

## 💡 Pro Tips

### 1. Quick Actions
- **Pull to Refresh**: Swipe down on any screen to refresh data
- **Long Press**: (Future feature) Long press cards for quick actions

### 2. Interest Calculation
The app automatically calculates interest using:
```
Interest = Principal × Rate × Time
```
- Time is calculated based on your selected frequency
- Interest updates in real-time

### 3. Payment Tracking
- Record partial payments as they come in
- The app tracks total paid vs total due
- View complete payment history in detail view

### 4. Data Safety
- All data is encrypted locally (AES-256)
- Biometric authentication protects access
- Audit logs track all deletions
- (Optional) Enable cloud backup for extra safety

## 🔧 Common Tasks

### Change Biometric Settings
```dart
// In lib/services/auth_service.dart
// Set to false to disable biometrics
_biometricEnabled = false;
```

### View Audit Logs
```dart
// In your code
final logs = await DatabaseService.instance.getAuditLogs();
```

### Export Data (Coming Soon)
Future feature to export data as CSV/PDF

### Clear All Data
```bash
# Uninstall and reinstall the app
flutter clean
flutter run
```

## 📊 Sample Workflow

### Example: Adding a Monthly Loan

1. **Scenario**: You lend ₹10,000 to John at 2% monthly interest
2. **Steps**:
   - Borrower Name: `John Doe`
   - Fund Source: `Self-Funded`
   - Transaction Mode: `Bank`
   - Principal: `10000`
   - Interest Rate: `2`
   - Frequency: `Monthly`
   - Start Date: `Today`
3. **Result**:
   - Loan appears on dashboard
   - Interest starts accruing automatically
   - Next payment due in 1 month

### Example: Recording a Payment

1. John pays ₹500 after 15 days
2. Open John's loan detail
3. Tap "Mark Paid"
4. Enter: `500`
5. Payment recorded with timestamp

## 🐛 Troubleshooting

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Biometrics not working?
- Test on a physical device (emulators may not support it)
- Check device has biometric hardware enabled
- Grant permissions in device settings

### Data not showing?
- Pull to refresh
- Check if loans were actually saved
- Restart the app

## 📚 Learn More

- **Full Documentation**: See [README.md](README.md)
- **Setup Guide**: See [SETUP.md](SETUP.md)
- **Report Issues**: [GitHub Issues](https://github.com/VDVDVDVDVDVDDVDV/lendledger/issues)

## 🎯 Next Steps

1. ✅ Add your first loan
2. ✅ Explore the dashboard
3. ✅ Record a payment
4. ✅ Try filtering transactions
5. ✅ Check out the detail view

## 💬 Need Help?

- Check [SETUP.md](SETUP.md) for detailed setup
- Read [README.md](README.md) for features
- Open an issue on GitHub

---

**Happy Lending! 💰**
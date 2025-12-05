import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  
  // Transaction Mode Colors
  static const Color cashBlue = Color(0xFF1976D2);
  static const Color bankGreen = Color(0xFF388E3C);
  
  // Status Colors
  static const Color overdueRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
}

class AppStrings {
  // App Name
  static const String appName = 'LendLedger';
  
  // Fund Source
  static const String selfFunded = 'Self-Funded';
  static const String borrowed = 'Borrowed';
  
  // Transaction Mode
  static const String cash = 'Cash';
  static const String bank = 'Bank';
  
  // Frequency
  static const String daily = 'Daily';
  static const String monthly = 'Monthly';
  static const String quarterly = 'Quarterly';
  static const String yearly = 'Yearly';
  
  // Screen Titles
  static const String dashboard = 'Dashboard';
  static const String addTransaction = 'Add Transaction';
  static const String transactionFeed = 'Transactions';
  static const String transactionDetail = 'Transaction Details';
  
  // Labels
  static const String totalOutstanding = 'Total Outstanding';
  static const String interestAccrued = 'Interest Accrued';
  static const String dueToday = 'Due Today';
  static const String overdue = 'Overdue';
  
  // Buttons
  static const String markPaid = 'Mark Paid';
  static const String addLoan = 'Add Loan';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  
  // Messages
  static const String deleteConfirmation = 'Are you sure? This will permanently remove this financial record.';
  static const String authenticationRequired = 'Authentication Required';
  static const String authenticationFailed = 'Authentication Failed';
}

class AppSizes {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Card Heights
  static const double cardHeight = 140.0;
  static const double dueTodayCardHeight = 100.0;
}

class DatabaseConstants {
  // Database
  static const String databaseName = 'lendledger.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String loansTable = 'loans';
  static const String paymentsTable = 'payments';
  static const String auditLogsTable = 'audit_logs';
  
  // Loans Table Columns
  static const String columnId = 'id';
  static const String columnBorrowerName = 'borrower_name';
  static const String columnFundSource = 'fund_source';
  static const String columnTransactionMode = 'transaction_mode';
  static const String columnPrincipalAmount = 'principal_amount';
  static const String columnInterestRate = 'interest_rate';
  static const String columnFrequency = 'frequency';
  static const String columnLoanStartDate = 'loan_start_date';
  static const String columnCostOfCapital = 'cost_of_capital';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  
  // Payments Table Columns
  static const String columnLoanId = 'loan_id';
  static const String columnAmountPaid = 'amount_paid';
  static const String columnPaymentDate = 'payment_date';
  
  // Audit Logs Table Columns
  static const String columnActionType = 'action_type';
  static const String columnRecordType = 'record_type';
  static const String columnRecordId = 'record_id';
  static const String columnDataSnapshot = 'data_snapshot';
  static const String columnTimestamp = 'timestamp';
}

class NotificationConstants {
  static const String channelId = 'lendledger_notifications';
  static const String channelName = 'LendLedger Notifications';
  static const String channelDescription = 'Payment reminders and due date notifications';
  
  // Notification IDs
  static const int reminderNotificationId = 1000;
  static const int dueTodayNotificationId = 2000;
  static const int overdueNotificationId = 3000;
}
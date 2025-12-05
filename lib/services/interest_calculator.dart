import 'package:lendledger/models/loan.dart';

class InterestCalculator {
  /// Calculate simple interest
  /// Formula: I = P × r × t
  /// 
  /// Where:
  /// - I = Interest Accrued
  /// - P = Principal Amount
  /// - r = Rate per period (as decimal)
  /// - t = Time periods elapsed
  static double calculateSimpleInterest({
    required double principal,
    required double ratePercentage,
    required double timePeriods,
  }) {
    final rate = ratePercentage / 100; // Convert percentage to decimal
    return principal * rate * timePeriods;
  }

  /// Calculate interest accrued for a loan from start date to now
  static double calculateAccruedInterest(Loan loan) {
    final now = DateTime.now();
    final daysSinceStart = now.difference(loan.loanStartDate).inDays;
    
    double timePeriods;
    
    switch (loan.frequency) {
      case 'Daily':
        timePeriods = daysSinceStart.toDouble();
        break;
      case 'Monthly':
        timePeriods = daysSinceStart / 30.0;
        break;
      case 'Quarterly':
        timePeriods = daysSinceStart / 90.0;
        break;
      case 'Yearly':
        timePeriods = daysSinceStart / 365.0;
        break;
      default:
        timePeriods = 0.0;
    }
    
    return calculateSimpleInterest(
      principal: loan.principalAmount,
      ratePercentage: loan.interestRate,
      timePeriods: timePeriods,
    );
  }

  /// Calculate interest for a specific time period
  static double calculateInterestForPeriod({
    required double principal,
    required double ratePercentage,
    required DateTime startDate,
    required DateTime endDate,
    required String frequency,
  }) {
    final days = endDate.difference(startDate).inDays;
    
    double timePeriods;
    
    switch (frequency) {
      case 'Daily':
        timePeriods = days.toDouble();
        break;
      case 'Monthly':
        timePeriods = days / 30.0;
        break;
      case 'Quarterly':
        timePeriods = days / 90.0;
        break;
      case 'Yearly':
        timePeriods = days / 365.0;
        break;
      default:
        timePeriods = 0.0;
    }
    
    return calculateSimpleInterest(
      principal: principal,
      ratePercentage: ratePercentage,
      timePeriods: timePeriods,
    );
  }

  /// Calculate total amount due (principal + interest)
  static double calculateTotalDue(Loan loan) {
    final interest = calculateAccruedInterest(loan);
    return loan.principalAmount + interest;
  }

  /// Calculate net profit for borrowed capital loans
  /// (Interest earned - Cost of capital)
  static double calculateNetProfit(Loan loan) {
    if (loan.fundSource != 'Borrowed' || loan.costOfCapital == null) {
      return calculateAccruedInterest(loan);
    }
    
    final interestEarned = calculateAccruedInterest(loan);
    final costOfCapital = calculateInterestForPeriod(
      principal: loan.principalAmount,
      ratePercentage: loan.costOfCapital!,
      startDate: loan.loanStartDate,
      endDate: DateTime.now(),
      frequency: loan.frequency,
    );
    
    return interestEarned - costOfCapital;
  }

  /// Calculate expected interest for next payment period
  static double calculateNextPaymentInterest(Loan loan) {
    double timePeriods;
    
    switch (loan.frequency) {
      case 'Daily':
        timePeriods = 1.0;
        break;
      case 'Monthly':
        timePeriods = 1.0;
        break;
      case 'Quarterly':
        timePeriods = 1.0;
        break;
      case 'Yearly':
        timePeriods = 1.0;
        break;
      default:
        timePeriods = 0.0;
    }
    
    return calculateSimpleInterest(
      principal: loan.principalAmount,
      ratePercentage: loan.interestRate,
      timePeriods: timePeriods,
    );
  }

  /// Calculate effective annual rate (APR)
  static double calculateAPR({
    required double ratePercentage,
    required String frequency,
  }) {
    double periodsPerYear;
    
    switch (frequency) {
      case 'Daily':
        periodsPerYear = 365.0;
        break;
      case 'Monthly':
        periodsPerYear = 12.0;
        break;
      case 'Quarterly':
        periodsPerYear = 4.0;
        break;
      case 'Yearly':
        periodsPerYear = 1.0;
        break;
      default:
        periodsPerYear = 1.0;
    }
    
    return ratePercentage * periodsPerYear;
  }

  /// Format currency for display
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format percentage for display
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(2)}%';
  }
}
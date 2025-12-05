class Loan {
  final String id;
  final String borrowerName;
  final String fundSource; // 'Self-Funded' or 'Borrowed'
  final String transactionMode; // 'Cash' or 'Bank'
  final double principalAmount;
  final double interestRate;
  final String frequency; // 'Daily', 'Monthly', 'Quarterly', 'Yearly'
  final DateTime loanStartDate;
  final double? costOfCapital; // Optional - only for borrowed funds
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.borrowerName,
    required this.fundSource,
    required this.transactionMode,
    required this.principalAmount,
    required this.interestRate,
    required this.frequency,
    required this.loanStartDate,
    this.costOfCapital,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Loan to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'borrower_name': borrowerName,
      'fund_source': fundSource,
      'transaction_mode': transactionMode,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'frequency': frequency,
      'loan_start_date': loanStartDate.toIso8601String(),
      'cost_of_capital': costOfCapital,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create Loan from Map (database retrieval)
  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      borrowerName: map['borrower_name'] as String,
      fundSource: map['fund_source'] as String,
      transactionMode: map['transaction_mode'] as String,
      principalAmount: map['principal_amount'] as double,
      interestRate: map['interest_rate'] as double,
      frequency: map['frequency'] as String,
      loanStartDate: DateTime.parse(map['loan_start_date'] as String),
      costOfCapital: map['cost_of_capital'] as double?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Copy with method for updates
  Loan copyWith({
    String? id,
    String? borrowerName,
    String? fundSource,
    String? transactionMode,
    double? principalAmount,
    double? interestRate,
    String? frequency,
    DateTime? loanStartDate,
    double? costOfCapital,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      borrowerName: borrowerName ?? this.borrowerName,
      fundSource: fundSource ?? this.fundSource,
      transactionMode: transactionMode ?? this.transactionMode,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      frequency: frequency ?? this.frequency,
      loanStartDate: loanStartDate ?? this.loanStartDate,
      costOfCapital: costOfCapital ?? this.costOfCapital,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if loan is overdue (simplified - needs payment tracking)
  bool get isOverdue {
    // This is a simplified check - in reality, you'd check against payment schedule
    final daysSinceStart = DateTime.now().difference(loanStartDate).inDays;
    
    switch (frequency) {
      case 'Daily':
        return daysSinceStart > 1;
      case 'Monthly':
        return daysSinceStart > 30;
      case 'Quarterly':
        return daysSinceStart > 90;
      case 'Yearly':
        return daysSinceStart > 365;
      default:
        return false;
    }
  }

  // Get next payment due date
  DateTime get nextPaymentDue {
    final now = DateTime.now();
    DateTime nextDue = loanStartDate;
    
    while (nextDue.isBefore(now)) {
      switch (frequency) {
        case 'Daily':
          nextDue = nextDue.add(const Duration(days: 1));
          break;
        case 'Monthly':
          nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
          break;
        case 'Quarterly':
          nextDue = DateTime(nextDue.year, nextDue.month + 3, nextDue.day);
          break;
        case 'Yearly':
          nextDue = DateTime(nextDue.year + 1, nextDue.month, nextDue.day);
          break;
      }
    }
    
    return nextDue;
  }

  @override
  String toString() {
    return 'Loan{id: $id, borrowerName: $borrowerName, principalAmount: $principalAmount, interestRate: $interestRate}';
  }
}
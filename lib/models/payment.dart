class Payment {
  final String id;
  final String loanId;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.loanId,
    required this.amountPaid,
    required this.paymentDate,
    required this.createdAt,
  });

  // Convert Payment to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loan_id': loanId,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create Payment from Map (database retrieval)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      loanId: map['loan_id'] as String,
      amountPaid: map['amount_paid'] as double,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method for updates
  Payment copyWith({
    String? id,
    String? loanId,
    double? amountPaid,
    DateTime? paymentDate,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Payment{id: $id, loanId: $loanId, amountPaid: $amountPaid, paymentDate: $paymentDate}';
  }
}
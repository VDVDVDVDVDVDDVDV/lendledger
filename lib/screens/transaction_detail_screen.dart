import 'package:flutter/material.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/models/payment.dart';
import 'package:lendledger/services/database_service.dart';
import 'package:lendledger/services/interest_calculator.dart';
import 'package:lendledger/utils/constants.dart';
import 'package:uuid/uuid.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Loan loan;

  const TransactionDetailScreen({
    super.key,
    required this.loan,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payments =
          await DatabaseService.instance.getPaymentsByLoan(widget.loan.id);
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markPaid() async {
    final amountController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount Paid',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (result == true && amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(amountController.text);
        final payment = Payment(
          id: const Uuid().v4(),
          loanId: widget.loan.id,
          amountPaid: amount,
          paymentDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await DatabaseService.instance.createPayment(payment);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment recorded successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          _loadPayments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error recording payment: $e'),
              backgroundColor: AppColors.overdueRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteLoan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.overdueRed,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteLoan(widget.loan.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan deleted successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting loan: $e'),
              backgroundColor: AppColors.overdueRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final interest = InterestCalculator.calculateAccruedInterest(widget.loan);
    final totalDue = widget.loan.principalAmount + interest;
    final totalPaid = _payments.fold(0.0, (sum, p) => sum + p.amountPaid);
    final remaining = totalDue - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteLoan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Borrower Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primaryBlue,
                                child: Text(
                                  widget.loan.borrowerName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.paddingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.loan.borrowerName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.loan.fundSource} • ${widget.loan.transactionMode}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingMedium),

                  // Financial Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          _buildSummaryRow(
                            'Principal Amount',
                            InterestCalculator.formatCurrency(
                              widget.loan.principalAmount,
                            ),
                          ),
                          _buildSummaryRow(
                            'Interest Rate',
                            '${widget.loan.interestRate}% per ${widget.loan.frequency}',
                          ),
                          _buildSummaryRow(
                            'Interest Accrued',
                            InterestCalculator.formatCurrency(interest),
                            valueColor: AppColors.successGreen,
                          ),
                          _buildSummaryRow(
                            'Total Due',
                            InterestCalculator.formatCurrency(totalDue),
                            isBold: true,
                          ),
                          _buildSummaryRow(
                            'Total Paid',
                            InterestCalculator.formatCurrency(totalPaid),
                            valueColor: AppColors.primaryBlue,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Remaining',
                            InterestCalculator.formatCurrency(remaining),
                            isBold: true,
                            valueColor: remaining > 0 
                                ? AppColors.overdueRed 
                                : AppColors.successGreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingMedium),

                  // Payment History
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          
                          if (_payments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppSizes.paddingLarge),
                              child: Center(
                                child: Text(
                                  'No payments recorded yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _payments.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final payment = _payments[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.successGreen,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    InterestCalculator.formatCurrency(
                                      payment.amountPaid,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _markPaid,
        icon: const Icon(Icons.payment),
        label: const Text(AppStrings.markPaid),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
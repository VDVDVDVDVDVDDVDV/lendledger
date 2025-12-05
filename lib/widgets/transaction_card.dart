import 'package:flutter/material.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/services/interest_calculator.dart';
import 'package:lendledger/utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final interest = InterestCalculator.calculateAccruedInterest(loan);
    final totalDue = loan.principalAmount + interest;
    final isOverdue = loan.isOverdue;
    final nextDue = loan.nextPaymentDue;
    
    // Color based on transaction mode
    final cardColor = loan.transactionMode == AppStrings.cash
        ? AppColors.cashBlue
        : AppColors.bankGreen;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: cardColor,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Borrower Name
                  Expanded(
                    child: Text(
                      loan.borrowerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Due Date Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue 
                          ? AppColors.overdueRed 
                          : AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverdue 
                          ? 'OVERDUE' 
                          : '${nextDue.day}/${nextDue.month}/${nextDue.year}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOverdue 
                            ? Colors.white 
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Body - Financial Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          InterestCalculator.formatCurrency(
                            loan.principalAmount,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interest Accrued',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          InterestCalculator.formatCurrency(interest),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingSmall),
              
              // Tags Row
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  // Fund Source Tag
                  _buildTag(
                    label: loan.fundSource,
                    icon: loan.fundSource == AppStrings.selfFunded
                        ? Icons.account_balance_wallet
                        : Icons.credit_card,
                    color: loan.fundSource == AppStrings.selfFunded
                        ? AppColors.primaryBlue
                        : AppColors.warningOrange,
                  ),
                  
                  // Transaction Mode Tag
                  _buildTag(
                    label: loan.transactionMode,
                    icon: loan.transactionMode == AppStrings.cash
                        ? Icons.money
                        : Icons.account_balance,
                    color: cardColor,
                  ),
                  
                  // Frequency Tag
                  _buildTag(
                    label: loan.frequency,
                    icon: Icons.calendar_today,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingSmall),
              
              // Divider
              Divider(color: Colors.grey.shade300),
              
              // Footer - Total Due
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Due',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    InterestCalculator.formatCurrency(totalDue),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
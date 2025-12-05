import 'package:flutter/material.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/services/database_service.dart';
import 'package:lendledger/services/interest_calculator.dart';
import 'package:lendledger/utils/constants.dart';
import 'package:lendledger/widgets/transaction_card.dart';
import 'package:lendledger/screens/transaction_detail_screen.dart';

class TransactionFeedScreen extends StatefulWidget {
  const TransactionFeedScreen({super.key});

  @override
  State<TransactionFeedScreen> createState() => _TransactionFeedScreenState();
}

class _TransactionFeedScreenState extends State<TransactionFeedScreen> {
  List<Loan> _loans = [];
  List<Loan> _filteredLoans = [];
  bool _isLoading = true;
  String _filterMode = 'All'; // All, Cash, Bank, Overdue

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loans = await DatabaseService.instance.getAllLoans();
      setState(() {
        _loans = loans;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading loans: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    switch (_filterMode) {
      case 'Cash':
        _filteredLoans = _loans
            .where((loan) => loan.transactionMode == AppStrings.cash)
            .toList();
        break;
      case 'Bank':
        _filteredLoans = _loans
            .where((loan) => loan.transactionMode == AppStrings.bank)
            .toList();
        break;
      case 'Overdue':
        _filteredLoans = _loans.where((loan) => loan.isOverdue).toList();
        break;
      default:
        _filteredLoans = List.from(_loans);
    }

    // Sort by nearest due date
    _filteredLoans.sort((a, b) => a.nextPaymentDue.compareTo(b.nextPaymentDue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionFeed),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterMode = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Transactions'),
              ),
              const PopupMenuItem(
                value: 'Cash',
                child: Text('Cash Only'),
              ),
              const PopupMenuItem(
                value: 'Bank',
                child: Text('Bank Only'),
              ),
              const PopupMenuItem(
                value: 'Overdue',
                child: Text('Overdue Only'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredLoans.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLoans,
                  child: Column(
                    children: [
                      // Filter Indicator
                      if (_filterMode != 'All')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingSmall),
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt,
                                size: 16,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Filtered: $_filterMode',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filterMode = 'All';
                                    _applyFilter();
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Transaction List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          itemCount: _filteredLoans.length,
                          itemBuilder: (context, index) {
                            final loan = _filteredLoans[index];
                            return TransactionCard(
                              loan: loan,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TransactionDetailScreen(loan: loan),
                                  ),
                                );
                                _loadLoans();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filterMode == 'All' ? Icons.inbox : Icons.filter_alt_off,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            _filterMode == 'All'
                ? 'No loans yet'
                : 'No $_filterMode transactions',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            _filterMode == 'All'
                ? 'Add your first loan to get started'
                : 'Try a different filter',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
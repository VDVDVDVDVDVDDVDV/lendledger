import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/services/database_service.dart';
import 'package:lendledger/utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _costOfCapitalController = TextEditingController();
  
  String _fundSource = AppStrings.selfFunded;
  String _transactionMode = AppStrings.cash;
  String _frequency = AppStrings.monthly;
  DateTime _loanStartDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _principalController.dispose();
    _interestRateController.dispose();
    _costOfCapitalController.dispose();
    super.dispose();
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loan = Loan(
        id: const Uuid().v4(),
        borrowerName: _borrowerNameController.text.trim(),
        fundSource: _fundSource,
        transactionMode: _transactionMode,
        principalAmount: double.parse(_principalController.text),
        interestRate: double.parse(_interestRateController.text),
        frequency: _frequency,
        loanStartDate: _loanStartDate,
        costOfCapital: _fundSource == AppStrings.borrowed && 
                       _costOfCapitalController.text.isNotEmpty
            ? double.parse(_costOfCapitalController.text)
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DatabaseService.instance.createLoan(loan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan added successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding loan: $e'),
            backgroundColor: AppColors.overdueRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addTransaction),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // Borrower Name
            TextFormField(
              controller: _borrowerNameController,
              decoration: const InputDecoration(
                labelText: 'Borrower Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter borrower name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Fund Source Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fund Source',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: AppStrings.selfFunded,
                          label: Text(AppStrings.selfFunded),
                          icon: Icon(Icons.account_balance_wallet),
                        ),
                        ButtonSegment(
                          value: AppStrings.borrowed,
                          label: Text(AppStrings.borrowed),
                          icon: Icon(Icons.credit_card),
                        ),
                      ],
                      selected: {_fundSource},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _fundSource = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Transaction Mode Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: AppStrings.cash,
                          label: Text(AppStrings.cash),
                          icon: Icon(Icons.money),
                        ),
                        ButtonSegment(
                          value: AppStrings.bank,
                          label: Text(AppStrings.bank),
                          icon: Icon(Icons.account_balance),
                        ),
                      ],
                      selected: {_transactionMode},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _transactionMode = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Principal Amount
            TextFormField(
              controller: _principalController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter principal amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Interest Rate
            TextFormField(
              controller: _interestRateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
                helperText: 'Rate per period',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter interest rate';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) < 0) {
                  return 'Rate cannot be negative';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Frequency Dropdown
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Payment Frequency',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppStrings.daily,
                  child: Text(AppStrings.daily),
                ),
                DropdownMenuItem(
                  value: AppStrings.monthly,
                  child: Text(AppStrings.monthly),
                ),
                DropdownMenuItem(
                  value: AppStrings.quarterly,
                  child: Text(AppStrings.quarterly),
                ),
                DropdownMenuItem(
                  value: AppStrings.yearly,
                  child: Text(AppStrings.yearly),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequency = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Loan Start Date
            ListTile(
              title: const Text('Loan Start Date'),
              subtitle: Text(
                '${_loanStartDate.day}/${_loanStartDate.month}/${_loanStartDate.year}',
              ),
              leading: const Icon(Icons.event),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _loanStartDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _loanStartDate = date;
                  });
                }
              },
            ),
            
            // Cost of Capital (only for borrowed funds)
            if (_fundSource == AppStrings.borrowed) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              TextFormField(
                controller: _costOfCapitalController,
                decoration: const InputDecoration(
                  labelText: 'Cost of Capital (%) - Optional',
                  prefixIcon: Icon(Icons.trending_down),
                  border: OutlineInputBorder(),
                  helperText: 'Interest rate you pay on borrowed funds',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) < 0) {
                      return 'Rate cannot be negative';
                    }
                  }
                  return null;
                },
              ),
            ],
            
            const SizedBox(height: AppSizes.paddingLarge),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveLoan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      AppStrings.save,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
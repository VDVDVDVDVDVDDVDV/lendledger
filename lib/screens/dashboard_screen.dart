import 'package:flutter/material.dart';
import 'package:lendledger/services/database_service.dart';
import 'package:lendledger/services/interest_calculator.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/utils/constants.dart';
import 'package:lendledger/screens/transaction_feed_screen.dart';
import 'package:lendledger/screens/add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalOutstanding = 0.0;
  double _totalInterest = 0.0;
  Map<String, double> _capitalSplit = {'selfFunded': 0.0, 'borrowed': 0.0};
  List<Loan> _dueToday = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseService.instance;
      
      // Get total outstanding
      final outstanding = await db.getTotalOutstandingPrincipal();
      
      // Get all loans and calculate total interest
      final loans = await db.getAllLoans();
      double totalInterest = 0.0;
      for (var loan in loans) {
        totalInterest += InterestCalculator.calculateAccruedInterest(loan);
      }
      
      // Get capital split
      final capitalSplit = await db.getCapitalSplit();
      
      // Get loans due today
      final now = DateTime.now();
      final dueToday = loans.where((loan) {
        final nextDue = loan.nextPaymentDue;
        return nextDue.year == now.year &&
               nextDue.month == now.month &&
               nextDue.day == now.day;
      }).toList();

      setState(() {
        _totalOutstanding = outstanding;
        _totalInterest = totalInterest;
        _capitalSplit = capitalSplit;
        _dueToday = dueToday;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Overview Cards
                    _buildFinancialOverview(),
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Capital Split Chart
                    _buildCapitalSplit(),
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Due Today Section
                    _buildDueTodaySection(),
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Quick Actions
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          _loadDashboardData();
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addLoan),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: AppStrings.totalOutstanding,
            value: InterestCalculator.formatCurrency(_totalOutstanding),
            icon: Icons.account_balance_wallet,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: _buildStatCard(
            title: AppStrings.interestAccrued,
            value: InterestCalculator.formatCurrency(_totalInterest),
            icon: Icons.trending_up,
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppSizes.iconMedium),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalSplit() {
    final total = _capitalSplit['selfFunded']! + _capitalSplit['borrowed']!;
    final selfFundedPercent = total > 0 
        ? (_capitalSplit['selfFunded']! / total * 100) 
        : 0.0;
    final borrowedPercent = total > 0 
        ? (_capitalSplit['borrowed']! / total * 100) 
        : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capital Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            
            // Self-Funded
            _buildCapitalRow(
              label: AppStrings.selfFunded,
              amount: _capitalSplit['selfFunded']!,
              percentage: selfFundedPercent,
              color: AppColors.primaryBlue,
            ),
            
            const SizedBox(height: AppSizes.paddingSmall),
            
            // Borrowed
            _buildCapitalRow(
              label: AppStrings.borrowed,
              amount: _capitalSplit['borrowed']!,
              percentage: borrowedPercent,
              color: AppColors.warningOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalRow({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '${InterestCalculator.formatCurrency(amount)} (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildDueTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.dueToday,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_dueToday.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.overdueRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_dueToday.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        
        if (_dueToday.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    const Text(
                      'No payments due today',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: AppSizes.dueTodayCardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dueToday.length,
              itemBuilder: (context, index) {
                final loan = _dueToday[index];
                return _buildDueTodayCard(loan);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDueTodayCard(Loan loan) {
    final interest = InterestCalculator.calculateAccruedInterest(loan);
    
    return Card(
      margin: const EdgeInsets.only(right: AppSizes.paddingMedium),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loan.borrowerName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Principal: ${InterestCalculator.formatCurrency(loan.principalAmount)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Interest: ${InterestCalculator.formatCurrency(interest)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'View All Loans',
                icon: Icons.list,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionFeedScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildActionButton(
                label: 'Add Loan',
                icon: Icons.add_circle,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                  _loadDashboardData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              Icon(icon, size: AppSizes.iconLarge, color: AppColors.primaryBlue),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
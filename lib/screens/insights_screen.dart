import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plaid_service.dart';
import '../services/budget_ai_service.dart';
import '../models/budget_insight.dart';
import '../models/transaction.dart';
import '../widgets/loading_animation.dart';
import '../widgets/budget_charts.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  List<BudgetInsight>? _allCategoryInsights;
  List<Transaction>? _transactions;
  Map<String, double> _financialMetrics = {};
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _loadInsights();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    try {
      final plaidService = Provider.of<PlaidService>(context, listen: false);
      final aiService = Provider.of<BudgetAIService>(context, listen: false);

      final transactions = await plaidService.getTransactions();
      // Get insights for ALL categories
      final allInsights =
          aiService.analyzeSpendingForAllCategories(transactions);
      final allInsightsWithCustomBudgets =
          aiService.updateInsightsWithCustomBudgets(allInsights);
      final financialMetrics =
          aiService.calculateFinancialMetrics(transactions);

      setState(() {
        _transactions = transactions;
        _allCategoryInsights = allInsightsWithCustomBudgets;
        _financialMetrics = financialMetrics;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showCategoryTransactions(String category) {
    if (_transactions == null) return;

    final categoryTransactions = _transactions!
        .where((t) => t.category == category && t.amount > 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (categoryTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No transactions found for $category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalSpent =
        categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${categoryTransactions.length} transactions • \$${totalSpent.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: categoryTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = categoryTransactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_bag,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, y').format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableBudgetCard(
      BudgetAIService aiService, List<BudgetInsight> insights) {
    final availableBudget = aiService.calculateAvailableBudget(insights);
    final income = _financialMetrics['income'] ?? 0;
    final expenses = _financialMetrics['expenses'] ?? 0;
    final savings = _financialMetrics['savings'] ?? 0;

    final isNegative = availableBudget < 0;
    final color = isNegative ? Colors.red : Colors.green;
    final icon = isNegative ? Icons.trending_down : Icons.trending_up;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegative
              ? [Colors.red.shade50, Colors.red.shade100]
              : [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNegative ? Colors.red.shade300 : Colors.green.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Budget Remaining',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNegative
                          ? '-\$${availableBudget.abs().toStringAsFixed(2)}'
                          : '\$${availableBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: color.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinancialMetric('Income', income, Colors.blue),
              Container(
                width: 1,
                height: 40,
                color: color.withOpacity(0.3),
              ),
              _buildFinancialMetric('Expenses', expenses, Colors.orange),
              Container(
                width: 1,
                height: 40,
                color: color.withOpacity(0.3),
              ),
              _buildFinancialMetric('Net Savings', savings,
                  savings >= 0 ? Colors.green : Colors.red),
            ],
          ),
          if (isNegative) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'re over budget! Consider reviewing your spending categories.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value < 0
              ? '-\$${value.abs().toStringAsFixed(0)}'
              : '\$${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetAIService>(
      builder: (context, budgetAIService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Budget Insights'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pushNamed(context, '/'),
              tooltip: 'Back to Home',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadInsights();
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: LoadingAnimation(
                    message: 'Analyzing your spending...',
                    size: 60,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                            Tab(icon: Icon(Icons.pie_chart), text: 'Charts'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildOverviewTab(_allCategoryInsights),
                              _buildChartsTab(_allCategoryInsights),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/budget'),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Manage Budgets'),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(List<BudgetInsight>? allCategoryInsights) {
    final aiService = Provider.of<BudgetAIService>(context, listen: false);

    if (allCategoryInsights == null || allCategoryInsights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Budget Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Link an account to start tracking your spending',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard(
                      'Budget Alerts',
                      '${allCategoryInsights.where((i) => i.percentageUsed >= 80).length}',
                      allCategoryInsights
                                  .where((i) => i.percentageUsed >= 80)
                                  .length >
                              3
                          ? Colors.red
                          : Colors.blue,
                      Icons.notifications,
                    ),
                    _buildMetricCard(
                      'Categories',
                      '${allCategoryInsights.length}',
                      Colors.purple,
                      Icons.category,
                    ),
                    _buildMetricCard(
                      'Total Budget',
                      '\$${allCategoryInsights.fold(0.0, (sum, i) => sum + i.recommendedBudget).toStringAsFixed(0)}',
                      Colors.green,
                      Icons.account_balance_wallet,
                    ),
                  ],
                ),
                if (allCategoryInsights.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                          'Total Spent',
                          '\$${allCategoryInsights.fold(0.0, (sum, insight) => sum + insight.currentSpending).toStringAsFixed(2)}',
                          Colors.red,
                        ),
                        _buildQuickStat(
                          'Total Budget',
                          '\$${allCategoryInsights.fold(0.0, (sum, insight) => sum + insight.recommendedBudget).toStringAsFixed(2)}',
                          Colors.blue,
                        ),
                        _buildQuickStat(
                          'Remaining',
                          '\$${allCategoryInsights.fold(0.0, (sum, insight) => sum + insight.remainingBudget).toStringAsFixed(2)}',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Available Budget Card
          if (allCategoryInsights.isNotEmpty)
            _buildAvailableBudgetCard(aiService, allCategoryInsights),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChartsTab(List<BudgetInsight>? allCategoryInsights) {
    if (allCategoryInsights == null || allCategoryInsights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No chart data available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SpendingPieChart(
                    insights: allCategoryInsights,
                    onCategoryTap: _showCategoryTransactions,
                  ),
                  const SizedBox(height: 16),
                  ChartLegend(
                    insights: allCategoryInsights,
                    onCategoryTap: _showCategoryTransactions,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Budget Usage by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetUsageBarChart(
                insights: allCategoryInsights,
                onCategoryTap: _showCategoryTransactions,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

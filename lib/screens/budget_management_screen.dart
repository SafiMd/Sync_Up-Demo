import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plaid_service.dart';
import '../services/budget_ai_service.dart';
import '../models/budget_insight.dart';
import '../widgets/loading_animation.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen>
    with TickerProviderStateMixin {
  List<BudgetInsight>? _allCategoryInsights;
  bool _isLoading = true;
  final Map<String, TextEditingController> _budgetControllers = {};
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
    for (final controller in _budgetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInsights() async {
    try {
      final plaidService = Provider.of<PlaidService>(context, listen: false);
      final aiService = Provider.of<BudgetAIService>(context, listen: false);

      final transactions = await plaidService.getTransactions();

      // Get all categories from all insights (including those within budget)
      final allInsights =
          aiService.analyzeSpendingForAllCategories(transactions);
      final insightsWithCustomBudgets =
          aiService.updateInsightsWithCustomBudgets(allInsights);

      setState(() {
        _allCategoryInsights = insightsWithCustomBudgets;
        _isLoading = false;
      });
      _fadeController.forward();

      // Initialize controllers with current budget values (custom or default)
      for (final insight in insightsWithCustomBudgets) {
        final customBudget = aiService.getCustomBudget(insight.category);
        final budgetValue = customBudget ?? insight.recommendedBudget;
        _budgetControllers[insight.category] = TextEditingController(
          text: budgetValue.toStringAsFixed(2),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateBudgetValue(String category, BudgetAIService budgetAIService) {
    final controller = _budgetControllers[category];
    if (controller != null) {
      final budgetValue = double.tryParse(controller.text);
      if (budgetValue != null && budgetValue > 0) {
        budgetAIService.setCustomBudget(category, budgetValue);

        // Update the insights with new budget values
        setState(() {
          _allCategoryInsights = budgetAIService
              .updateInsightsWithCustomBudgets(_allCategoryInsights!);
        });
      }
    }
  }

  void _saveBudgets(BudgetAIService budgetAIService) {
    // Save all current budget values
    for (final entry in _budgetControllers.entries) {
      final budgetValue = double.tryParse(entry.value.text);
      if (budgetValue != null && budgetValue > 0) {
        budgetAIService.setCustomBudget(entry.key, budgetValue);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget settings saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefaults(BudgetAIService budgetAIService) {
    budgetAIService.clearCustomBudgets();

    // Reload insights to get default values
    _loadInsights();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default budget values'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getBudgetStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.good:
        return Colors.green;
      case BudgetStatus.moderate:
        return Colors.blue;
      case BudgetStatus.warning:
        return Colors.orange;
      case BudgetStatus.overBudget:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<BudgetAIService>(
      builder: (context, budgetAIService, child) {
        // Get updated insights with custom budgets
        final currentInsights = _allCategoryInsights != null
            ? budgetAIService
                .updateInsightsWithCustomBudgets(_allCategoryInsights!)
            : _allCategoryInsights;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/'),
                              tooltip: 'Back to Home',
                            ),
                            Text(
                              'Budget Management',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.refresh_rounded),
                                onPressed: () =>
                                    _resetToDefaults(budgetAIService),
                                tooltip: 'Reset to Defaults',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.save_rounded),
                                onPressed: () => _saveBudgets(budgetAIService),
                                tooltip: 'Save Changes',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: LoadingAnimation(
                              message: 'Loading budget data...',
                              size: 60,
                            ),
                          )
                        : currentInsights == null || currentInsights.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 60,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No budget data available',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Link an account to see budget insights',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    // Info Banner
                                    Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary
                                                .withOpacity(0.1),
                                            theme.colorScheme.primary
                                                .withOpacity(0.05),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.info_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Adjust your budget limits below. Changes update in real-time and are saved when you tap the save button.',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Budget List
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        itemCount: currentInsights.length,
                                        itemBuilder: (context, index) {
                                          final insight =
                                              currentInsights[index];
                                          final controller = _budgetControllers[
                                              insight.category]!;

                                          return AnimatedContainer(
                                            duration: Duration(
                                                milliseconds:
                                                    200 + (index * 100)),
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Card(
                                              elevation: 3,
                                              shadowColor:
                                                  _getBudgetStatusColor(
                                                          insight.status)
                                                      .withOpacity(0.2),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _getBudgetStatusColor(
                                                                    insight
                                                                        .status),
                                                                _getBudgetStatusColor(
                                                                        insight
                                                                            .status)
                                                                    .withOpacity(
                                                                        0.8),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: _getBudgetStatusColor(
                                                                        insight
                                                                            .status)
                                                                    .withOpacity(
                                                                        0.3),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                        0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .category_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                insight
                                                                    .category,
                                                                style: theme
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                '${insight.transactionCount} transactions',
                                                                style: theme
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _getBudgetStatusColor(
                                                                    insight
                                                                        .status)
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            border: Border.all(
                                                              color: _getBudgetStatusColor(
                                                                      insight
                                                                          .status)
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            '${insight.percentageUsed.toStringAsFixed(0)}%',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: _getBudgetStatusColor(
                                                                  insight
                                                                      .status),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Current Spending',
                                                                style: theme
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                          0.6),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                '\$${insight.currentSpending.toStringAsFixed(2)}',
                                                                style: theme
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'Monthly Budget',
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodySmall
                                                                        ?.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onSurface
                                                                          .withOpacity(
                                                                              0.6),
                                                                    ),
                                                                  ),
                                                                  if (budgetAIService
                                                                          .getCustomBudget(
                                                                              insight.category) !=
                                                                      null) ...[
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
                                                                    Icon(
                                                                      Icons
                                                                          .edit_rounded,
                                                                      size: 12,
                                                                      color: theme
                                                                          .colorScheme
                                                                          .primary,
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              TextField(
                                                                controller:
                                                                    controller,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                onSubmitted:
                                                                    (value) {
                                                                  _updateBudgetValue(
                                                                      insight
                                                                          .category,
                                                                      budgetAIService);
                                                                },
                                                                onTapOutside:
                                                                    (event) {
                                                                  _updateBudgetValue(
                                                                      insight
                                                                          .category,
                                                                      budgetAIService);
                                                                },
                                                                decoration:
                                                                    const InputDecoration(
                                                                  prefixText:
                                                                      '\$',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 8,
                                                                  ),
                                                                ),
                                                                style: theme
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    LinearProgressIndicator(
                                                      value:
                                                          (insight.percentageUsed /
                                                                  100)
                                                              .clamp(0.0, 1.0),
                                                      backgroundColor:
                                                          Colors.grey.shade200,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        _getBudgetStatusColor(
                                                            insight.status),
                                                      ),
                                                      minHeight: 6,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getBudgetStatusColor(
                                                                    insight
                                                                        .status)
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        insight.advice,
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                          fontSize: 11,
                                                          color:
                                                              _getBudgetStatusColor(
                                                                  insight
                                                                      .status),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

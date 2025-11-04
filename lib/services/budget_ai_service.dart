import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/budget_insight.dart';

class BudgetAIService extends ChangeNotifier {
  // Simple rule-based budgeting logic
  // In production, this would connect to an AI service

  // Store custom budget values
  final Map<String, double> _customBudgets = {};

  List<BudgetInsight> analyzeSpending(List<Transaction> transactions) {
    final insights = <BudgetInsight>[];
    final categoryData = <String, Map<String, dynamic>>{};

    // Group spending by category (excluding transfers and income)
    for (final txn in transactions) {
      if (txn.amount > 0 && txn.category != 'Transfer') {
        if (!categoryData.containsKey(txn.category)) {
          categoryData[txn.category] = {
            'total': 0.0,
            'count': 0,
            'transactions': <Transaction>[],
          };
        }
        categoryData[txn.category]!['total'] += txn.amount;
        categoryData[txn.category]!['count'] += 1;
        categoryData[txn.category]!['transactions'].add(txn);
      }
    }

    // Generate insights based on spending patterns
    categoryData.forEach((category, data) {
      final insight = _generateInsight(
          category,
          data['total'] as double,
          data['count'] as int,
          data['transactions'] as List<Transaction>,
          transactions);
      if (insight != null) insights.add(insight);
    });

    // Sort by priority
    insights.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return insights;
  }

  // Analyze spending for ALL categories, even those within budget
  List<BudgetInsight> analyzeSpendingForAllCategories(
      List<Transaction> transactions) {
    final insights = <BudgetInsight>[];
    final categoryData = <String, Map<String, dynamic>>{};

    // Group spending by category (excluding transfers and income)
    for (final txn in transactions) {
      if (txn.amount > 0 && txn.category != 'Transfer') {
        if (!categoryData.containsKey(txn.category)) {
          categoryData[txn.category] = {
            'total': 0.0,
            'count': 0,
            'transactions': <Transaction>[],
          };
        }
        categoryData[txn.category]!['total'] += txn.amount;
        categoryData[txn.category]!['count'] += 1;
        categoryData[txn.category]!['transactions'].add(txn);
      }
    }

    // Generate insights for ALL categories (don't filter out good ones)
    categoryData.forEach((category, data) {
      final insight = _generateInsightForAllCategories(
          category,
          data['total'] as double,
          data['count'] as int,
          data['transactions'] as List<Transaction>,
          transactions);
      insights.add(insight);
    });

    // Sort by category name for consistent display
    insights.sort((a, b) => a.category.compareTo(b.category));

    return insights;
  }

  BudgetInsight? _generateInsight(
      String category,
      double spending,
      int transactionCount,
      List<Transaction> categoryTransactions,
      List<Transaction> allTransactions) {
    // Calculate monthly income from transfers
    double monthlyIncome = 0;
    for (final txn in allTransactions) {
      if (txn.category == 'Transfer' && txn.amount < 0) {
        monthlyIncome += txn.amount.abs();
      }
    }

    // If no income found, use default
    if (monthlyIncome == 0) monthlyIncome = 5000;

    // Enhanced budgeting rules (percentage of income)
    final budgetRules = {
      'Food and Drink': 0.15, // 15% of income
      'Shops': 0.10, // 10% of income
      'Recreation': 0.05, // 5% of income
      'Travel': 0.10, // 10% of income
      'Service': 0.15, // 15% of income
      'Transportation': 0.12, // 12% of income
      'Healthcare': 0.08, // 8% of income
      'Entertainment': 0.05, // 5% of income
      'Education': 0.10, // 10% of income
      'Utilities': 0.08, // 8% of income
      'Insurance': 0.10, // 10% of income
      'Personal Care': 0.05, // 5% of income
    };

    final budgetPercent = budgetRules[category] ?? 0.08;
    final recommendedBudget = monthlyIncome * budgetPercent;
    final percentageUsed =
        (spending / recommendedBudget * 100).clamp(0, double.infinity);
    final remainingBudget =
        recommendedBudget - spending; // Allow negative values
    final averageTransaction =
        transactionCount > 0 ? spending / transactionCount : 0.0;

    InsightPriority priority;
    String advice;

    if (spending > recommendedBudget * 1.5) {
      priority = InsightPriority.high;
      advice =
          'Spending is ${percentageUsed.toStringAsFixed(0)}% of budget. Consider reducing expenses in this category.';
    } else if (spending > recommendedBudget * 1.2) {
      priority = InsightPriority.medium;
      advice =
          'Spending is ${percentageUsed.toStringAsFixed(0)}% of budget. Monitor closely.';
    } else if (spending > recommendedBudget) {
      priority = InsightPriority.low;
      advice =
          'Slightly over budget at ${percentageUsed.toStringAsFixed(0)}%. Small adjustments recommended.';
    } else if (percentageUsed >= 80) {
      priority = InsightPriority.low;
      advice =
          'Approaching budget limit at ${percentageUsed.toStringAsFixed(0)}%. Consider monitoring spending.';
    } else {
      return null; // Within budget and not approaching limit, no insight needed
    }

    return BudgetInsight(
      category: category,
      currentSpending: spending,
      recommendedBudget: recommendedBudget,
      advice: advice,
      priority: priority,
      percentageUsed: percentageUsed.toDouble(),
      remainingBudget: remainingBudget.toDouble(),
      transactionCount: transactionCount,
      averageTransaction: averageTransaction,
      lastUpdated: DateTime.now(),
    );
  }

  // Generate insight for all categories (even those within budget)
  BudgetInsight _generateInsightForAllCategories(
      String category,
      double spending,
      int transactionCount,
      List<Transaction> categoryTransactions,
      List<Transaction> allTransactions) {
    // Calculate monthly income from transfers
    double monthlyIncome = 0;
    for (final txn in allTransactions) {
      if (txn.category == 'Transfer' && txn.amount < 0) {
        monthlyIncome += txn.amount.abs();
      }
    }

    // If no income found, use default
    if (monthlyIncome == 0) monthlyIncome = 5000;

    // Enhanced budgeting rules (percentage of income)
    final budgetRules = {
      'Food and Drink': 0.15, // 15% of income
      'Shops': 0.10, // 10% of income
      'Recreation': 0.05, // 5% of income
      'Travel': 0.10, // 10% of income
      'Service': 0.15, // 15% of income
      'Transportation': 0.12, // 12% of income
      'Healthcare': 0.08, // 8% of income
      'Entertainment': 0.05, // 5% of income
      'Education': 0.10, // 10% of income
      'Utilities': 0.08, // 8% of income
      'Insurance': 0.10, // 10% of income
      'Personal Care': 0.05, // 5% of income
    };

    final budgetPercent = budgetRules[category] ?? 0.08;
    final recommendedBudget = monthlyIncome * budgetPercent;
    final percentageUsed =
        (spending / recommendedBudget * 100).clamp(0, double.infinity);
    final remainingBudget =
        recommendedBudget - spending; // Allow negative values
    final averageTransaction =
        transactionCount > 0 ? spending / transactionCount : 0.0;

    InsightPriority priority;
    String advice;

    if (spending > recommendedBudget * 1.5) {
      priority = InsightPriority.high;
      advice =
          'Spending is ${percentageUsed.toStringAsFixed(0)}% of budget. Consider reducing expenses in this category.';
    } else if (spending > recommendedBudget * 1.2) {
      priority = InsightPriority.medium;
      advice =
          'Spending is ${percentageUsed.toStringAsFixed(0)}% of budget. Monitor closely.';
    } else if (spending > recommendedBudget) {
      priority = InsightPriority.low;
      advice =
          'Slightly over budget at ${percentageUsed.toStringAsFixed(0)}%. Small adjustments recommended.';
    } else if (percentageUsed >= 80) {
      priority = InsightPriority.low;
      advice =
          'Approaching budget limit at ${percentageUsed.toStringAsFixed(0)}%. Consider monitoring spending.';
    } else {
      // Within budget - still return an insight with positive feedback
      priority = InsightPriority.low;
      advice =
          'Well within budget at ${percentageUsed.toStringAsFixed(0)}%. Great job managing this category!';
    }

    return BudgetInsight(
      category: category,
      currentSpending: spending,
      recommendedBudget: recommendedBudget,
      advice: advice,
      priority: priority,
      percentageUsed: percentageUsed.toDouble(),
      remainingBudget: remainingBudget.toDouble(),
      transactionCount: transactionCount,
      averageTransaction: averageTransaction,
      lastUpdated: DateTime.now(),
    );
  }

  // Calculate comprehensive financial metrics
  Map<String, double> calculateFinancialMetrics(
      List<Transaction> transactions) {
    double income = 0;
    double expenses = 0;

    for (final txn in transactions) {
      if (txn.category == 'Transfer' && txn.amount < 0) {
        // Negative amounts are income (money coming in)
        income += txn.amount.abs();
      } else if (txn.amount > 0 && txn.category != 'Transfer') {
        // Positive amounts are expenses (money going out)
        expenses += txn.amount;
      }
    }

    final savings = income - expenses;
    final savingsRate =
        income > 0 ? (savings / income * 100).clamp(-100, 100) : 0.0;

    return {
      'income': income.toDouble(),
      'expenses': expenses.toDouble(),
      'savings': savings.toDouble(),
      'savingsRate': savingsRate.toDouble(),
    };
  }

  double calculateSavingsRate(List<Transaction> transactions) {
    final metrics = calculateFinancialMetrics(transactions);
    return metrics['savingsRate']!;
  }

  // Calculate available budget remaining across all categories
  double calculateAvailableBudget(List<BudgetInsight> insights) {
    double totalBudget = 0;
    double totalSpent = 0;

    for (final insight in insights) {
      totalBudget += insight.recommendedBudget;
      totalSpent += insight.currentSpending;
    }

    return totalBudget - totalSpent;
  }

  // Get spending breakdown by category for charts
  Map<String, double> getSpendingBreakdown(List<Transaction> transactions) {
    final categoryData = <String, double>{};

    for (final txn in transactions) {
      if (txn.amount > 0 && txn.category != 'Transfer') {
        categoryData[txn.category] =
            (categoryData[txn.category] ?? 0) + txn.amount;
      }
    }

    return categoryData;
  }

  // Set custom budget for a category
  void setCustomBudget(String category, double budget) {
    _customBudgets[category] = budget;
    notifyListeners(); // Notify all listeners that budgets have changed
  }

  // Get custom budget for a category, or null if not set
  double? getCustomBudget(String category) {
    return _customBudgets[category];
  }

  // Get all custom budgets
  Map<String, double> getAllCustomBudgets() {
    return Map.from(_customBudgets);
  }

  // Clear all custom budgets
  void clearCustomBudgets() {
    _customBudgets.clear();
    notifyListeners(); // Notify all listeners that budgets have been cleared
  }

  // Update insights with custom budget values
  List<BudgetInsight> updateInsightsWithCustomBudgets(
      List<BudgetInsight> insights) {
    return insights.map((insight) {
      final customBudget = _customBudgets[insight.category];
      if (customBudget != null) {
        final newPercentageUsed = (insight.currentSpending / customBudget * 100)
            .clamp(0, double.infinity);
        final newRemainingBudget =
            customBudget - insight.currentSpending; // Allow negative values

        // Determine new priority and advice based on custom budget
        InsightPriority newPriority;
        String newAdvice;

        if (insight.currentSpending > customBudget * 1.5) {
          newPriority = InsightPriority.high;
          newAdvice =
              'Spending is ${newPercentageUsed.toStringAsFixed(0)}% of budget. Consider reducing expenses in this category.';
        } else if (insight.currentSpending > customBudget * 1.2) {
          newPriority = InsightPriority.medium;
          newAdvice =
              'Spending is ${newPercentageUsed.toStringAsFixed(0)}% of budget. Monitor closely.';
        } else if (insight.currentSpending > customBudget) {
          newPriority = InsightPriority.low;
          newAdvice =
              'Slightly over budget at ${newPercentageUsed.toStringAsFixed(0)}%. Small adjustments recommended.';
        } else if (newPercentageUsed >= 80) {
          newPriority = InsightPriority.low;
          newAdvice =
              'Approaching budget limit at ${newPercentageUsed.toStringAsFixed(0)}%. Consider monitoring spending.';
        } else {
          newPriority = InsightPriority.low;
          newAdvice =
              'Within budget at ${newPercentageUsed.toStringAsFixed(0)}%. Good job!';
        }

        return BudgetInsight(
          category: insight.category,
          currentSpending: insight.currentSpending,
          recommendedBudget: customBudget,
          advice: newAdvice,
          priority: newPriority,
          percentageUsed: newPercentageUsed.toDouble(),
          remainingBudget: newRemainingBudget.toDouble(),
          transactionCount: insight.transactionCount,
          averageTransaction: insight.averageTransaction,
          lastUpdated: DateTime.now(),
        );
      }
      return insight;
    }).toList();
  }
}

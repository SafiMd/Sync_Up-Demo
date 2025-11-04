class BudgetInsight {
  final String category;
  final double currentSpending;
  final double recommendedBudget;
  final String advice;
  final InsightPriority priority;
  final double percentageUsed;
  final double remainingBudget;
  final int transactionCount;
  final double averageTransaction;
  final DateTime lastUpdated;

  BudgetInsight({
    required this.category,
    required this.currentSpending,
    required this.recommendedBudget,
    required this.advice,
    required this.priority,
    required this.percentageUsed,
    required this.remainingBudget,
    required this.transactionCount,
    required this.averageTransaction,
    required this.lastUpdated,
  });

  // Helper getter for budget status
  BudgetStatus get status {
    if (percentageUsed >= 100) return BudgetStatus.overBudget;
    if (percentageUsed >= 80) return BudgetStatus.warning;
    if (percentageUsed >= 50) return BudgetStatus.moderate;
    return BudgetStatus.good;
  }

  // Helper getter for trend
  String get trend {
    if (percentageUsed >= 100) return 'Over Budget';
    if (percentageUsed >= 80) return 'High Usage';
    if (percentageUsed >= 50) return 'Moderate Usage';
    return 'Good';
  }
}

enum BudgetStatus { good, moderate, warning, overBudget }

enum InsightPriority { low, medium, high }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/budget_insight.dart';
import 'dart:math' as math;

class SpendingPieChart extends StatelessWidget {
  final List<BudgetInsight> insights;
  final Function(String)? onCategoryTap;

  const SpendingPieChart({
    super.key,
    required this.insights,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const Center(
        child: Text('No spending data available'),
      );
    }

    final totalSpending =
        insights.fold(0.0, (sum, i) => sum + i.currentSpending);

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _buildSections(totalSpending),
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (event is FlTapUpEvent &&
                  pieTouchResponse?.touchedSection != null) {
                final touchedIndex =
                    pieTouchResponse!.touchedSection!.touchedSectionIndex;
                if (touchedIndex >= 0 && touchedIndex < insights.length) {
                  onCategoryTap?.call(insights[touchedIndex].category);
                }
              }
            },
            enabled: true,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double totalSpending) {
    final normalColors = [
      Colors.blue,
      Colors.green.shade600,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.lightBlue,
      Colors.lime.shade700,
      Colors.deepPurple,
      Colors.blueGrey,
    ];

    return insights.asMap().entries.map((entry) {
      final index = entry.key;
      final insight = entry.value;
      final percentage = (insight.currentSpending / totalSpending * 100);

      // Use red/orange colors for over-budget categories
      Color color;
      double radius;
      if (insight.percentageUsed >= 100) {
        color = Colors.red.shade700;
        radius = 55; // Make over-budget sections slightly larger
      } else if (insight.percentageUsed >= 80) {
        color = Colors.orange.shade600;
        radius = 52;
      } else {
        color = normalColors[index % normalColors.length];
        radius = 50;
      }

      return PieChartSectionData(
        color: color,
        value: insight.currentSpending,
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: insight.percentageUsed >= 100
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 12,
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }
}

class BudgetUsageBarChart extends StatelessWidget {
  final List<BudgetInsight> insights;
  final Function(String)? onCategoryTap;

  const BudgetUsageBarChart({
    super.key,
    required this.insights,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const Center(
        child: Text('No budget data available'),
      );
    }

    // Sort by percentage used descending to show over-budget items first
    final sortedInsights = List<BudgetInsight>.from(insights)
      ..sort((a, b) => b.percentageUsed.compareTo(a.percentageUsed));
    // Show all categories (up to 12 for reasonable display)
    final topInsights = sortedInsights.take(12).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: topInsights.isEmpty
                ? 100
                : math.max(
                    100,
                    topInsights.map((i) => i.percentageUsed).reduce(math.max),
                  ),
            barTouchData: BarTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                if (event is FlTapUpEvent && barTouchResponse?.spot != null) {
                  final touchedIndex =
                      barTouchResponse!.spot!.touchedBarGroupIndex;
                  if (touchedIndex >= 0 && touchedIndex < topInsights.length) {
                    onCategoryTap?.call(topInsights[touchedIndex].category);
                  }
                }
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final insight = topInsights[group.x.toInt()];
                  return BarTooltipItem(
                    '${insight.category}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${insight.percentageUsed.toStringAsFixed(0)}% used\n',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text:
                            '\$${insight.currentSpending.toStringAsFixed(0)} / \$${insight.recommendedBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const TextSpan(
                        text: '\nTap to view transactions',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= topInsights.length) {
                      return const SizedBox();
                    }
                    final category = topInsights[value.toInt()].category;
                    final shortName = category.length > 8
                        ? '${category.substring(0, 7)}...'
                        : category;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        shortName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: _buildBarGroups(topInsights),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<BudgetInsight> topInsights) {
    return topInsights.asMap().entries.map((entry) {
      final index = entry.key;
      final insight = entry.value;

      Color barColor;
      Color borderColor;
      double borderWidth;

      if (insight.percentageUsed >= 100) {
        barColor = Colors.red.shade700;
        borderColor = Colors.red.shade900;
        borderWidth = 3; // Thick border for over-budget
      } else if (insight.percentageUsed >= 80) {
        barColor = Colors.orange.shade600;
        borderColor = Colors.orange.shade800;
        borderWidth = 2;
      } else if (insight.percentageUsed >= 50) {
        barColor = Colors.blue;
        borderColor = Colors.blue.shade700;
        borderWidth = 0;
      } else {
        barColor = Colors.green.shade600;
        borderColor = Colors.green.shade800;
        borderWidth = 0;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: insight.percentageUsed,
            color: barColor,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: borderWidth > 0
                ? BorderSide(color: borderColor, width: borderWidth)
                : BorderSide.none,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.grey.shade200,
            ),
          ),
        ],
        showingTooltipIndicators: insight.percentageUsed >= 100 ? [0] : [],
      );
    }).toList();
  }
}

class ChartLegend extends StatelessWidget {
  final List<BudgetInsight> insights;
  final Function(String)? onCategoryTap;

  const ChartLegend({
    super.key,
    required this.insights,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalColors = [
      Colors.blue,
      Colors.green.shade600,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.lightBlue,
      Colors.lime.shade700,
      Colors.deepPurple,
      Colors.blueGrey,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: insights.asMap().entries.map((entry) {
        final index = entry.key;
        final insight = entry.value;

        // Match the pie chart color logic
        Color color;
        if (insight.percentageUsed >= 100) {
          color = Colors.red.shade700;
        } else if (insight.percentageUsed >= 80) {
          color = Colors.orange.shade600;
        } else {
          color = normalColors[index % normalColors.length];
        }

        final totalSpending =
            insights.fold(0.0, (sum, i) => sum + i.currentSpending);
        final percentage = (insight.currentSpending / totalSpending * 100);
        final isOverBudget = insight.percentageUsed >= 100;

        return InkWell(
          onTap: () => onCategoryTap?.call(insight.category),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: isOverBudget
                ? BoxDecoration(
                    border: Border.all(color: Colors.red.shade700, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    border: isOverBudget
                        ? Border.all(color: Colors.red.shade900, width: 1)
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${insight.category} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isOverBudget ? FontWeight.bold : FontWeight.normal,
                    color: isOverBudget ? Colors.red.shade900 : Colors.black87,
                  ),
                ),
                if (isOverBudget) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.warning_rounded,
                    size: 12,
                    color: Colors.red.shade700,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SavingsRateGauge extends StatelessWidget {
  final double savingsRate;

  const SavingsRateGauge({super.key, required this.savingsRate});

  @override
  Widget build(BuildContext context) {
    Color gaugeColor;
    String status;

    if (savingsRate >= 20) {
      gaugeColor = Colors.green;
      status = 'Excellent';
    } else if (savingsRate >= 10) {
      gaugeColor = Colors.blue;
      status = 'Good';
    } else if (savingsRate >= 0) {
      gaugeColor = Colors.orange;
      status = 'Fair';
    } else {
      gaugeColor = Colors.red;
      status = 'Deficit';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gaugeColor.withOpacity(0.1), gaugeColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gaugeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Savings Rate',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: (savingsRate.abs() / 100).clamp(0.0, 1.0),
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${savingsRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: gaugeColor,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gaugeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            savingsRate >= 0
                ? 'You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income'
                : 'You\'re spending ${savingsRate.abs().toStringAsFixed(1)}% more than your income',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

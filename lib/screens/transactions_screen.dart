import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plaid_service.dart';
import '../services/encryption_service.dart';
import '../models/transaction.dart';
import '../widgets/loading_animation.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  List<Transaction>? _transactions;
  bool _isLoading = true;
  String _filter = 'All';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _loadTransactions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final plaidService = Provider.of<PlaidService>(context, listen: false);
      final transactions = await plaidService.getTransactions();

      // Demo: Encrypt and decrypt transaction data
      try {
        final encryptionService = Provider.of<EncryptionService>(
          context,
          listen: false,
        );
        for (final txn in transactions.take(1)) {
          // Only demo with first transaction
          final encrypted = encryptionService.encryptJson(txn.toJson());
          encryptionService.decryptJson(encrypted);
          // In production, you'd store the encrypted data
        }
      } catch (e) {
        // Ignore encryption demo errors
      }

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Transaction> get filteredTransactions {
    if (_transactions == null || _filter == 'All') {
      return _transactions ?? [];
    }
    return _transactions!.where((txn) => txn.category == _filter).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food and drink':
        return Icons.restaurant;
      case 'shops':
        return Icons.shopping_bag;
      case 'recreation':
        return Icons.sports_basketball;
      case 'travel':
        return Icons.flight;
      case 'service':
        return Icons.build;
      case 'transportation':
        return Icons.directions_car;
      case 'healthcare':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'utilities':
        return Icons.power;
      case 'insurance':
        return Icons.shield;
      case 'personal care':
        return Icons.spa;
      case 'transfer':
        return Icons.swap_horiz;
      case 'other':
        return Icons.category;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories =
        _transactions?.map((t) => t.category).toSet().toList() ?? [];
    categories.insert(0, 'All');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          onPressed: () => Navigator.pushNamed(context, '/'),
                          tooltip: 'Back to Home',
                        ),
                        Text(
                          'Transactions',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _loadTransactions();
                        },
                        tooltip: 'Refresh',
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              if (_transactions != null && _transactions!.isNotEmpty)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _filter == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _filter = category);
                          },
                          selectedColor:
                              theme.colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Transactions List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: LoadingAnimation(
                          message: 'Loading transactions...',
                          size: 60,
                        ),
                      )
                    : _transactions == null || _transactions!.isEmpty
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
                                    Icons.receipt_long_rounded,
                                    size: 60,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No transactions found',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Connect your bank account to see transactions',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final txn = filteredTransactions[index];
                                final isIncome = txn.amount < 0;
                                return AnimatedContainer(
                                  duration: Duration(
                                      milliseconds: 200 + (index * 50)),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isIncome
                                                ? [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600
                                                  ]
                                                : [
                                                    Colors.red.shade400,
                                                    Colors.red.shade600
                                                  ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isIncome
                                                      ? Colors.green
                                                      : Colors.red)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(txn.category),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        txn.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category_rounded,
                                                size: 14,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                txn.category,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                size: 14,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${txn.date.month}/${txn.date.day}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              if (txn.pending) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    'Pending',
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme
                                                          .colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${isIncome ? "+" : ""}\$${txn.amount.abs().toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isIncome
                                                  ? Colors.green.shade600
                                                  : Colors.red.shade600,
                                            ),
                                          ),
                                          if (isIncome)
                                            Text(
                                              'Income',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: Colors.green.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          else
                                            Text(
                                              'Expense',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: Colors.red.shade600,
                                                fontWeight: FontWeight.w500,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

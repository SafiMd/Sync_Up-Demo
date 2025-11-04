import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plaid_service.dart';
import '../widgets/animated_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PlaidService>(
      builder: (context, plaidService, child) {
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
                        Text(
                          'SyncUp',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (plaidService.isConnected)
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded),
                              onPressed: () async {
                                await plaidService.disconnectAccount();
                              },
                              tooltip: 'Disconnect Account',
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Hero Icon
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: plaidService.isConnected
                                          ? [
                                              Colors.green.shade400,
                                              Colors.green.shade600
                                            ]
                                          : [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.secondary
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (plaidService.isConnected
                                                ? Colors.green
                                                : theme.colorScheme.primary)
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Title
                                Text(
                                  plaidService.isConnected
                                      ? 'Account Connected'
                                      : 'Simple Budget Management',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                if (plaidService.isConnected) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.security_rounded,
                                          color: Colors.green.shade600,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AES-256 Encrypted',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 48),

                                // Action Buttons
                                if (!plaidService.isConnected) ...[
                                  GradientButton(
                                    text: 'Connect Bank Account',
                                    icon: Icons.link_rounded,
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/link'),
                                    width: double.infinity,
                                  ),
                                ] else ...[
                                  AnimatedButton(
                                    text: 'View Transactions',
                                    icon: Icons.receipt_long_rounded,
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/transactions'),
                                    width: double.infinity,
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedButton(
                                    text: 'Budget Insights',
                                    icon: Icons.insights_rounded,
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/insights'),
                                    width: double.infinity,
                                  ),
                                  const SizedBox(height: 16),
                                  GradientButton(
                                    text: 'Manage Budgets',
                                    icon: Icons.settings_rounded,
                                    colors: [
                                      theme.colorScheme.secondary,
                                      theme.colorScheme.primary
                                    ],
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/budget'),
                                    width: double.infinity,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
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

// lib/services/plaid_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class PlaidService extends ChangeNotifier {
  bool _isConnected = false;
  final Random _random;
  final DateTime Function() _nowProvider;
  final void Function(String message)? _debugLogger;

  List<Account>? _accountsCache;
  List<Transaction>? _transactionsCache;

  PlaidService({
    Random? random,
    DateTime Function()? nowProvider,
    void Function(String message)? debugLogger,
  })  : _random = random ?? Random(),
        _nowProvider = nowProvider ?? DateTime.now,
        _debugLogger = debugLogger;

  bool get isConnected => _isConnected;

  Future<void> connectAccount(
      {Duration simulatedDelay = const Duration(seconds: 2)}) async {
    await Future.delayed(simulatedDelay);
    _isConnected = true;
    notifyListeners();
  }

  Future<void> disconnectAccount() async {
    _isConnected = false;
    _accountsCache = null;
    _transactionsCache = null;
    notifyListeners();
  }

  Future<List<Account>> getAccounts(
      {bool forceRefresh = false,
      Duration simulatedDelay = const Duration(milliseconds: 300)}) async {
    if (!forceRefresh && _accountsCache != null) {
      return _accountsCache!;
    }

    await Future.delayed(simulatedDelay);

    final accounts = [
      Account(
        id: 'acc_001',
        name: 'Checking Account',
        type: 'depository',
        subtype: 'checking',
        currentBalance: 2453.67,
        availableBalance: 2453.67,
      ),
      Account(
        id: 'acc_002',
        name: 'Savings Account',
        type: 'depository',
        subtype: 'savings',
        currentBalance: 8924.12,
        availableBalance: 8924.12,
      ),
      Account(
        id: 'acc_003',
        name: 'Credit Card',
        type: 'credit',
        subtype: 'credit card',
        currentBalance: -1276.43,
        availableBalance: 3723.57,
      ),
    ];

    _accountsCache = accounts;
    return accounts;
  }

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    int? limit,
    int offset = 0,
    bool forceRefresh = false,
    Duration simulatedDelay = const Duration(milliseconds: 400),
  }) async {
    await Future.delayed(simulatedDelay);

    // For demo purposes, always return mock transactions
    // In production, you'd check if connected first
    List<Transaction> base;
    if (!forceRefresh && _transactionsCache != null) {
      base = _transactionsCache!;
    } else {
      base = _generateMockTransactions();
      _transactionsCache = base;
    }

    // Apply filters
    final DateTime? normalizedStart = startDate;
    final DateTime? normalizedEnd = endDate;

    Iterable<Transaction> filtered = base;
    if (accountId != null && accountId.isNotEmpty) {
      filtered = filtered.where((t) => t.accountId == accountId);
    }
    if (normalizedStart != null) {
      filtered =
          filtered.where((t) => !t.date.isBefore(_startOfDay(normalizedStart)));
    }
    if (normalizedEnd != null) {
      filtered =
          filtered.where((t) => !t.date.isAfter(_endOfDay(normalizedEnd)));
    }

    // Ensure sort by date desc
    final List<Transaction> sorted = filtered.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Pagination
    final int start = offset.clamp(0, sorted.length);
    final int end =
        limit == null ? sorted.length : (start + limit).clamp(0, sorted.length);
    final slice = sorted.sublist(start, end);

    _debugLogger?.call(
        'PlaidService returned ${slice.length} transactions (offset=$offset, limit=$limit)');

    return slice;
  }

  // Convenience helper to fetch for one account
  Future<List<Transaction>> getTransactionsForAccount(
    String accountId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int offset = 0,
    bool forceRefresh = false,
    Duration simulatedDelay = const Duration(milliseconds: 400),
  }) {
    return getTransactions(
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
      limit: limit,
      offset: offset,
      forceRefresh: forceRefresh,
      simulatedDelay: simulatedDelay,
    );
  }

  // Internals
  List<Transaction> _generateMockTransactions() {
    final List<Transaction> transactions = [];
    final now = _nowProvider();

    transactions.addAll([
      Transaction(
        id: 'txn_000',
        accountId: 'acc_001',
        amount: 100.00,
        name: 'test transaction',
        category: 'Other',
        date: now.subtract(const Duration(hours: 2)),
        pending: false,
      ),
      Transaction(
        id: 'txn_001',
        accountId: 'acc_001',
        amount: -2500.00,
        name: 'Direct Deposit - Employer',
        category: 'Transfer',
        date: now.subtract(const Duration(days: 1)),
        pending: false,
      ),
      Transaction(
        id: 'txn_002',
        accountId: 'acc_001',
        amount: 45.99,
        name: 'Whole Foods',
        category: 'Food and Drink',
        date: now.subtract(const Duration(days: 1)),
        pending: false,
      ),
      Transaction(
        id: 'txn_003',
        accountId: 'acc_001',
        amount: 12.50,
        name: 'Netflix',
        category: 'Recreation',
        date: now.subtract(const Duration(days: 2)),
        pending: false,
      ),
      Transaction(
        id: 'txn_004',
        accountId: 'acc_003',
        amount: 156.78,
        name: 'Amazon',
        category: 'Shops',
        date: now.subtract(const Duration(days: 2)),
        pending: false,
      ),
      Transaction(
        id: 'txn_005',
        accountId: 'acc_001',
        amount: 35.00,
        name: 'Shell Gas Station',
        category: 'Travel',
        date: now.subtract(const Duration(days: 3)),
        pending: false,
      ),
      Transaction(
        id: 'txn_006',
        accountId: 'acc_001',
        amount: 8.45,
        name: 'Starbucks',
        category: 'Food and Drink',
        date: now.subtract(const Duration(days: 3)),
        pending: false,
      ),
      Transaction(
        id: 'txn_007',
        accountId: 'acc_001',
        amount: 89.99,
        name: 'Verizon Wireless',
        category: 'Service',
        date: now.subtract(const Duration(days: 4)),
        pending: false,
      ),
      Transaction(
        id: 'txn_008',
        accountId: 'acc_001',
        amount: 23.50,
        name: 'Chipotle',
        category: 'Food and Drink',
        date: now.subtract(const Duration(days: 5)),
        pending: false,
      ),
      Transaction(
        id: 'txn_009',
        accountId: 'acc_001',
        amount: 18.00,
        name: 'Uber',
        category: 'Travel',
        date: now.subtract(const Duration(days: 5)),
        pending: false,
      ),
      Transaction(
        id: 'txn_010',
        accountId: 'acc_002',
        amount: -500.00,
        name: 'Transfer to Savings',
        category: 'Transfer',
        date: now.subtract(const Duration(days: 6)),
        pending: false,
      ),
    ]);

    final categories = {
      'Food and Drink': [
        'Starbucks',
        'Chipotle',
        'Whole Foods',
        'McDonald\'s',
        'Trader Joe\'s',
        'Subway',
        'Pizza Hut',
        'Panera Bread',
        'Dunkin Donuts',
        'Five Guys'
      ],
      'Shops': [
        'Amazon',
        'Target',
        'Walmart',
        'Best Buy',
        'Home Depot',
        'CVS',
        'Walgreens',
        'Macy\'s',
        'IKEA',
        'Costco'
      ],
      'Recreation': [
        'Spotify',
        'AMC Theaters',
        'LA Fitness',
        'Steam Games',
        'PlayStation Store',
        'Hulu',
        'Apple Music',
        'Dave & Busters'
      ],
      'Travel': [
        'Uber',
        'Lyft',
        'Shell',
        'Chevron',
        'Exxon',
        'BP',
        'Parking Meter',
        'Delta Airlines',
        'Airbnb'
      ],
      'Service': [
        'AT&T',
        'Verizon',
        'T-Mobile',
        'Comcast',
        'Chase Fee',
        'Barber Shop',
        'Car Wash'
      ],
      'Transportation': [
        'Metro Transit',
        'Gas Station',
        'Auto Repair',
        'Car Insurance Payment',
        'Parking Garage',
        'Toll Road',
        'Car Registration',
        'Oil Change'
      ],
      'Healthcare': [
        'CVS Pharmacy',
        'Walgreens Pharmacy',
        'Dr. Smith Office',
        'Dental Clinic',
        'Vision Center',
        'Lab Tests',
        'Urgent Care',
        'Hospital Bill'
      ],
      'Entertainment': [
        'Netflix',
        'Disney+',
        'HBO Max',
        'Concert Tickets',
        'Movie Theater',
        'Bowling Alley',
        'Mini Golf',
        'Escape Room'
      ],
      'Education': [
        'Udemy Course',
        'Coursera',
        'LinkedIn Learning',
        'College Bookstore',
        'Khan Academy',
        'Library Fine',
        'Textbook Rental'
      ],
      'Utilities': [
        'ConEd Electric',
        'Water Bill',
        'Gas Bill',
        'Internet Service',
        'Trash Collection',
        'Sewage Bill'
      ],
      'Insurance': [
        'State Farm',
        'Geico',
        'Allstate',
        'Health Insurance',
        'Life Insurance',
        'Renters Insurance'
      ],
      'Personal Care': [
        'Hair Salon',
        'Spa Treatment',
        'Gym Membership',
        'Massage Therapy',
        'Nail Salon',
        'Beauty Supply'
      ],
      'Transfer': [
        'Zelle from Mom',
        'Venmo',
        'ATM Withdrawal',
        'Wire Transfer',
        'Cash App',
        'PayPal Transfer'
      ],
    };

    for (int i = 11; i <= 40; i++) {
      final daysAgo = _random.nextInt(25) + 5;
      final categoryList = categories.keys.toList();
      final category = categoryList[_random.nextInt(categoryList.length)];
      final merchants = categories[category]!;
      final merchant = merchants[_random.nextInt(merchants.length)];

      double amount;
      if (category == 'Transfer') {
        if (_random.nextDouble() > 0.7) {
          amount = -(_random.nextDouble() * 300 + 100);
        } else {
          amount = _random.nextDouble() * 200 + 20;
        }
      } else if (category == 'Food and Drink') {
        amount = _random.nextDouble() * 40 + 8;
      } else if (category == 'Shops') {
        amount = _random.nextDouble() * 150 + 25;
      } else if (category == 'Recreation') {
        amount = _random.nextDouble() * 60 + 10;
      } else if (category == 'Travel') {
        amount = _random.nextDouble() * 300 + 50;
      } else if (category == 'Transportation') {
        amount = _random.nextDouble() * 80 + 20;
      } else if (category == 'Healthcare') {
        amount = _random.nextDouble() * 200 + 30;
      } else if (category == 'Entertainment') {
        amount = _random.nextDouble() * 50 + 10;
      } else if (category == 'Education') {
        amount = _random.nextDouble() * 100 + 20;
      } else if (category == 'Utilities') {
        amount = _random.nextDouble() * 150 + 50;
      } else if (category == 'Insurance') {
        amount = _random.nextDouble() * 200 + 80;
      } else if (category == 'Personal Care') {
        amount = _random.nextDouble() * 80 + 25;
      } else {
        amount = _random.nextDouble() * 120 + 30;
      }

      transactions.add(Transaction(
        id: 'txn_${i.toString().padLeft(3, '0')}',
        accountId: i % 3 == 0 ? 'acc_003' : 'acc_001',
        amount: amount,
        name: merchant,
        category: category,
        date: now.subtract(Duration(days: daysAgo)),
        pending: false,
      ));
    }

    transactions.add(Transaction(
      id: 'txn_041',
      accountId: 'acc_001',
      amount: -2500.00,
      name: 'Direct Deposit - Employer',
      category: 'Transfer',
      date: now.subtract(const Duration(days: 15)),
      pending: false,
    ));

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
}

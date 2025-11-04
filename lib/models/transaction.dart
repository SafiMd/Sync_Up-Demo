class Transaction {
  final String id;
  final String accountId;
  final double amount;
  final String name;
  final String category;
  final DateTime date;
  final bool pending;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.name,
    required this.category,
    required this.date,
    this.pending = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['transaction_id'],
      accountId: json['account_id'],
      amount: json['amount'].toDouble(),
      name: json['name'],
      category: json['category']?.join(', ') ?? 'Other',
      date: DateTime.parse(json['date']),
      pending: json['pending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_id': id,
    'account_id': accountId,
    'amount': amount,
    'name': name,
    'category': category,
    'date': date.toIso8601String(),
    'pending': pending,
  };
}

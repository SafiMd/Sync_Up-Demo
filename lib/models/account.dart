class Account {
  final String id;
  final String name;
  final String type;
  final String subtype;
  final double currentBalance;
  final double availableBalance;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.subtype,
    required this.currentBalance,
    required this.availableBalance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['account_id'],
      name: json['name'],
      type: json['type'],
      subtype: json['subtype'],
      currentBalance: json['balances']['current']?.toDouble() ?? 0.0,
      availableBalance: json['balances']['available']?.toDouble() ?? 0.0,
    );
  }
}

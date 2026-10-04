class Spent {
  final String id;
  final double dollarAmount;
  final String accountId;
  final String description;
  final DateTime date;

  const Spent({
    this.id = '',
    required this.dollarAmount,
    required this.accountId,
    required this.description,
    required this.date,
  });

  factory Spent.fromJson(Map<String, dynamic> json) {
    return Spent(
      id: json['id'].toString(),
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      accountId: json['account_ID'].toString(),
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'dollar_amount': dollarAmount,
      'account_ID': accountId,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
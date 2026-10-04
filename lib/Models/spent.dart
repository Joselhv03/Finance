class Spent {
  final double dollarAmount;
  final String accountId;
  final String description;
  final DateTime date;

  const Spent({
    required this.dollarAmount,
    required this.accountId,
    required this.description,
    required this.date,
  });

  factory Spent.fromJson(Map<String, dynamic> json) {
    return Spent(
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      accountId: json['account_id'].toString(),
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
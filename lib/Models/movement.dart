class Movement {
  final double dollarAmount;
  final String accountId;
  final DateTime date;

  const Movement({
    required this.dollarAmount,
    required this.accountId,
    required this.date,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      accountId: json['account_id'].toString(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
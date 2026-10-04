class Movement {
  final String id;
  final double dollarAmount;
  final String accountId;
  final DateTime date;

  const Movement({
    this.id = '',
    required this.dollarAmount,
    required this.accountId,
    required this.date,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id'].toString(),
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      accountId: json['account_ID'].toString(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'dollar_amount': dollarAmount,
      'account_ID': accountId,
      'date': date.toIso8601String(),
    };
  }
}
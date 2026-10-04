class IncomeDollars {
  final String concept;
  final double amount;
  final DateTime date;

  const IncomeDollars({
    required this.concept,
    required this.amount,
    required this.date,
  });

  factory IncomeDollars.fromJson(Map<String, dynamic> json) {
    return IncomeDollars(
      concept: json['concept'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'concept': concept,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
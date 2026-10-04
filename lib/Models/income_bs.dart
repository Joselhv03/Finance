class IncomeBs {
  final String id;
  final String concept;
  final double amount;
  final DateTime date;

  const IncomeBs({
    this.id = '',
    required this.concept,
    required this.amount,
    required this.date,
  });

  factory IncomeBs.fromJson(Map<String, dynamic> json) {
    return IncomeBs(
      id: json['id'].toString(),
      concept: json['concept'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  // No incluye month_ID: eso lo agrega el Service, que es quien
  // sabe cómo conseguir o crear el mes correspondiente.
  Map<String, dynamic> toInsertJson() {
    return {
      'concept': concept,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
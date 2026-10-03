class IncomeBs {
  final String concept;
  final double amount;
  final DateTime date;

  const IncomeBs({
    required this.concept,
    required this.amount,
    required this.date,
  });

  // No incluye month_id: eso lo agrega el Service, que es quien
  // sabe cómo conseguir o crear el mes correspondiente.
  Map<String, dynamic> toInsertJson() {
    return {
      'concept': concept,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
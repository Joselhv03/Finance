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
      accountId: json['account_ID'].toString(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  // No incluye month_ID a propósito: eso lo agrega el Service, igual
  // que con Income_bs/Buy. account_ID sí va aquí porque es un dato
  // que el usuario elige, no algo derivado de la fecha.
  Map<String, dynamic> toInsertJson() {
    return {
      'dollar_amount': dollarAmount,
      'account_ID': accountId,
      'date': date.toIso8601String(),
    };
  }
}
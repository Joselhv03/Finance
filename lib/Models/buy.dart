class Buy {
  final double dollarAmount;
  final double rate;
  final double bsAmount;
  final String? seller;
  final DateTime date;

  const Buy({
    required this.dollarAmount,
    required this.rate,
    required this.bsAmount,
    required this.date,
    this.seller,
  });

  factory Buy.fromJson(Map<String, dynamic> json) {
    return Buy(
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      bsAmount: (json['bs_amount'] as num).toDouble(),
      seller: json['seller'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
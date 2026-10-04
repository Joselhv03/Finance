class Buy {
  final String id;
  final double dollarAmount;
  final double rate;
  final double bsAmount;
  final String? seller;
  final DateTime date;

  const Buy({
    this.id = '',
    required this.dollarAmount,
    required this.rate,
    required this.bsAmount,
    required this.date,
    this.seller,
  });

  factory Buy.fromJson(Map<String, dynamic> json) {
    return Buy(
      id: json['id'].toString(),
      dollarAmount: (json['dollar_amount'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      bsAmount: (json['bs_amount'] as num).toDouble(),
      seller: json['seller'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'dollar_amount': dollarAmount,
      'rate': rate,
      'bs_amount': bsAmount,
      'seller': seller,
      'date': date.toIso8601String(),
    };
  }
}
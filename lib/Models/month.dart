class Month {
  final String id;
  final String name;
  final double incomeTotal;
  final double expense;
  final double totalSaving;

  const Month({
    required this.id,
    required this.name,
    required this.incomeTotal,
    required this.expense,
    required this.totalSaving,
  });

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      id: json['id'].toString(),
      name: json['name'] as String,
      incomeTotal: (json['income_total'] as num?)?.toDouble() ?? 0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0,
      totalSaving: (json['total_saving'] as num?)?.toDouble() ?? 0,
    );
  }
}
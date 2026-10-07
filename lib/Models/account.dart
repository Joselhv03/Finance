import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final double total;
  final double? targetAmount;
  final Color color;

  const Account({
    required this.id,
    required this.name,
    required this.total,
    required this.color,
    this.targetAmount,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'].toString(),
      name: json['name'] as String,
      total: (json['total'] as num).toDouble(),
      targetAmount: json['target_amount'] != null
          ? (json['target_amount'] as num).toDouble()
          : null,
      color: _colorFromHex(json['color'] as String?),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'total': total,
      'target_amount': targetAmount,
      'color': _colorToHex(color),
    };
  }

  static Color _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF7C8CFF); // azul por defecto
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  static String _colorToHex(Color color) {
    String channel(int value) => value.toRadixString(16).padLeft(2, '0');
    return '#${channel(color.red)}${channel(color.green)}${channel(color.blue)}'.toUpperCase();
  }
}
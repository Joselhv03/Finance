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

  // Traduce una fila cruda de Supabase (un Map<String, dynamic>) a
  // este modelo. Esta es la frontera entre lo que entiende la base
  // de datos y lo que entiende el resto de la app.
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

  // Lo que se manda de vuelta a Supabase al crear/actualizar. No
  // incluye 'id' ni 'user_id' a propósito — esos los pone el Service,
  // no el Model.
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
    // toRadixString(16) puede devolver menos de 2 dígitos para
    // valores bajos (ej. 5 en vez de 05), por eso el padLeft.
    String channel(int value) => value.toRadixString(16).padLeft(2, '0');
    return '#${channel(color.red)}${channel(color.green)}${channel(color.blue)}'.toUpperCase();
  }
}
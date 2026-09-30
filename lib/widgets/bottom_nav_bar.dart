import 'package:flutter/material.dart';
import '../app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Un ícono por pestaña. Usamos la versión "outlined" para el
  // estado normal y la versión rellena para el estado seleccionado,
  // un patrón común en apps de Material Design para reforzar
  // visualmente cuál pestaña está activa sin necesidad de texto.
  static const _icons = [
    (outlined: Icons.home_outlined, filled: Icons.home),
    (outlined: Icons.account_balance_wallet_outlined, filled: Icons.account_balance_wallet),
    (outlined: Icons.calendar_month_outlined, filled: Icons.calendar_month),
    (outlined: Icons.person_outline, filled: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = index == selectedIndex;
            final icon = _icons[index];
            return IconButton(
              onPressed: () => onItemSelected(index),
              icon: Icon(
                isSelected ? icon.filled : icon.outlined,
                color: isSelected ? AppColors.usd : AppColors.textDim,
                size: 24,
              ),
            );
          }),
        ),
      ),
    );
  }
}
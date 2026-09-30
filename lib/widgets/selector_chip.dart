import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class SelectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const SelectorChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor = AppColors.usd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : AppColors.line,
          ),
          color: selected ? accentColor.withOpacity(0.12) : Colors.transparent,
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            color: selected ? accentColor : AppColors.textDim,
          ),
        ),
      ),
    );
  }
}
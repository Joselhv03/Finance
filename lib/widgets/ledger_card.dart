import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

// Reutiliza esta tarjeta para "Ingresos del mes", "Guardado este mes",
// y cualquier otra métrica grande con una sola línea de color arriba
// (en vez del típico card con sombra).
class LedgerCard extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color accentColor;

  const LedgerCard({
    super.key,
    required this.label,
    required this.amount,
    required this.currency,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: accentColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.textDim),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amount,
                style: GoogleFonts.newsreader(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              Text(
                currency,
                style: GoogleFonts.ibmPlexMono(fontSize: 13, color: AppColors.textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class MovementRow extends StatelessWidget {
  final String description;
  final String dateLabel;
  final String amount;
  final Color amountColor;
  // Opcional: si se pasa, aparece un ícono de borrar al final de la
  // fila. Si no se pasa (como en ResumenScreen), la fila se ve
  // exactamente igual que antes.
  final VoidCallback? onDelete;

  const MovementRow({
    super.key,
    required this.description,
    required this.dateLabel,
    required this.amount,
    required this.amountColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.ibmPlexSans(fontSize: 14, color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  dateLabel,
                  style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.newsreader(fontSize: 17, color: amountColor),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 16, color: AppColors.textDim),
              padding: const EdgeInsets.only(left: 6),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class MovementRow extends StatelessWidget {
  final String description;
  final String dateLabel;
  final String amount;
  final Color amountColor;

  const MovementRow({
    super.key,
    required this.description,
    required this.dateLabel,
    required this.amount,
    required this.amountColor,
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
          Column(
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
          Text(
            amount,
            style: GoogleFonts.newsreader(fontSize: 17, color: amountColor),
          ),
        ],
      ),
    );
  }
}
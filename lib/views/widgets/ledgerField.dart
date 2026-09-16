import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appColors.dart';

// ─────────────────────────────────────────────────────────
// Este widget antes vivía dentro de login.dart como "_LedgerField"
// (con guión bajo = privado a ese archivo). Al quitarle el guión
// bajo y moverlo a widgets/, cualquier pantalla puede importarlo
// y reutilizarlo. Esta es la carpeta "widgets/" de la que hablamos
// en la estructura MVC.
// ─────────────────────────────────────────────────────────
class LedgerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const LedgerField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            color: AppColors.textDim,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            color: AppColors.text,
          ),
          cursorColor: AppColors.usd,
          decoration: InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.line),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.line),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.usd, width: 1.4),
            ),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}
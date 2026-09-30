import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

// Placeholder: aquí va el selector de mes y, al elegir uno, el
// listado completo de sus movimientos (ingresos, compras, ahorros,
// egresos) — lo construimos en detalle más adelante.
class MonthsScreen extends StatelessWidget {
  const MonthsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Text(
            'Meses — próximamente',
            style: GoogleFonts.ibmPlexSans(fontSize: 14, color: AppColors.textDim),
          ),
        ),
      ),
    );
  }
}
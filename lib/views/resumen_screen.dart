import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../widgets/ledger_card.dart';
import '../widgets/movement_row.dart';
import 'new_movement_screen.dart';

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthNav(),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LedgerCard(
                        label: 'Ingresos del mes',
                        amount: '27.432,55',
                        currency: 'Bs',
                        accentColor: AppColors.bs,
                      ),
                      const SizedBox(height: 4),
                      const LedgerCard(
                        label: 'Guardado este mes',
                        amount: '130,00',
                        currency: 'USD',
                        accentColor: AppColors.usd,
                      ),
                      const SizedBox(height: 18),
                      _buildAlert(),
                      const SizedBox(height: 26),
                      Text(
                        'ÚLTIMOS MOVIMIENTOS',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          color: AppColors.textDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const MovementRow(
                        description: 'Compra de dólares',
                        dateLabel: '28 sep · tasa 930',
                        amount: '+10,00 \$',
                        amountColor: AppColors.usd,
                      ),
                      const MovementRow(
                        description: 'Compra de dólares',
                        dateLabel: '15 sep · tasa 925',
                        amount: '+20,00 \$',
                        amountColor: AppColors.usd,
                      ),
                      const MovementRow(
                        description: 'Quincena',
                        dateLabel: '15 sep',
                        amount: '+13.716,00 Bs',
                        amountColor: AppColors.bs,
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'resumen_fab',
        backgroundColor: AppColors.usd,
        foregroundColor: AppColors.ink,
        elevation: 0,
        onPressed: () {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewMovementScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, color: AppColors.textDim),
          Text(
            'Septiembre 2026',
            style: GoogleFonts.newsreader(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textDim),
        ],
      ),
    );
  }

  Widget _buildAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2420),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF522E28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Por distribuir',
            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.text),
          ),
          Text(
            '130,00 \$',
            style: GoogleFonts.newsreader(fontSize: 16, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
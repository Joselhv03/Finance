import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../Controllers/resumen_controller.dart';
import '../widgets/ledger_card.dart';
import '../widgets/movement_row.dart';
import 'new_movement_screen.dart';

const _monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];
const _shortMonthNames = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResumenController()..loadCurrentMonth(),
      child: const _ResumenView(),
    );
  }
}

class _ResumenView extends StatelessWidget {
  const _ResumenView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResumenController>();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  '${_monthNames[now.month - 1]} ${now.year}',
                  style: GoogleFonts.newsreader(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              Expanded(child: _buildBody(controller)),
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

  Widget _buildBody(ResumenController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.usd));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LedgerCard(
            label: 'Ingresos del mes',
            amount: controller.incomeTotal.toStringAsFixed(2),
            currency: 'Bs',
            accentColor: AppColors.bs,
          ),
          const SizedBox(height: 4),
          LedgerCard(
            label: 'Guardado este mes',
            amount: controller.totalSaving.toStringAsFixed(2),
            currency: 'USD',
            accentColor: AppColors.usd,
          ),
          const SizedBox(height: 18),
          _buildAlert(controller.pendingToDistribute),
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
          if (controller.recentMovements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aún no hay movimientos este mes',
                style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
              ),
            )
          else
            for (final item in controller.recentMovements)
              MovementRow(
                description: item.description,
                dateLabel: '${item.date.day} ${_shortMonthNames[item.date.month - 1]}',
                amount: item.amountText,
                amountColor: item.color,
              ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildAlert(double pending) {
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
            '${pending.toStringAsFixed(2)} \$',
            style: GoogleFonts.newsreader(fontSize: 16, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../widgets/ledger_card.dart';
import '../widgets/movement_row.dart';

// Nombres de mes en español. Evita agregar el paquete 'intl' solo
// para esto — si más adelante formateas fechas en más pantallas,
// vale la pena migrar a intl entonces.
const _monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

class MonthsScreen extends StatefulWidget {
  const MonthsScreen({super.key});

  @override
  State<MonthsScreen> createState() => _MonthsScreenState();
}

class _MonthsScreenState extends State<MonthsScreen> {
  late DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo solo para el mes actual, para que veas cómo
    // se ve con contenido. Cualquier otro mes muestra el estado
    // vacío — útil ya que en la vida real muchos meses sí van a
    // estar vacíos (ej. si no has usado la app desde antes).
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthNav(),
              Expanded(
                child: isCurrentMonth
                    ? _buildMonthContent()
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: const Icon(Icons.chevron_left, color: AppColors.textDim),
          ),
          Text(
            '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
            style: GoogleFonts.newsreader(
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: const Icon(Icons.chevron_right, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No hay movimientos registrados este mes',
        style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
      ),
    );
  }

  Widget _buildMonthContent() {
    return SingleChildScrollView(
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
          const SizedBox(height: 4),
          const LedgerCard(
            label: 'Egresos del mes',
            amount: '15,00',
            currency: 'USD',
            accentColor: AppColors.danger,
          ),
          const SizedBox(height: 10),

          _buildSectionLabel('Ingresos'),
          const MovementRow(
            description: 'Quincena',
            dateLabel: '15 sep',
            amount: '13.716,00 Bs',
            amountColor: AppColors.bs,
          ),
          const MovementRow(
            description: 'Quincena',
            dateLabel: '30 sep',
            amount: '13.716,55 Bs',
            amountColor: AppColors.bs,
          ),

          _buildSectionLabel('Compras de dólares'),
          const MovementRow(
            description: 'Compra · tasa 925',
            dateLabel: '15 sep',
            amount: '20,00 \$',
            amountColor: AppColors.usd,
          ),
          const MovementRow(
            description: 'Compra · tasa 930',
            dateLabel: '28 sep',
            amount: '20,00 \$',
            amountColor: AppColors.usd,
          ),

          _buildSectionLabel('Ahorros distribuidos'),
          const MovementRow(
            description: 'General',
            dateLabel: '28 sep',
            amount: '20,00 \$',
            amountColor: AppColors.usd,
          ),
          const MovementRow(
            description: 'Viaje',
            dateLabel: '28 sep',
            amount: '20,00 \$',
            amountColor: AppColors.usd,
          ),

          _buildSectionLabel('Egresos'),
          const MovementRow(
            description: 'Reparación de laptop · Emergencia',
            dateLabel: '20 sep',
            amount: '15,00 \$',
            amountColor: AppColors.danger,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          fontSize: 11,
          color: AppColors.textDim,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
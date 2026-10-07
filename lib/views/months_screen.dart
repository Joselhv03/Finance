import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../Controllers/months_controller.dart';
import '../widgets/ledger_card.dart';
import '../widgets/movement_row.dart';

const _monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const _shortMonthNames = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String _formatDay(DateTime date) => '${date.day} ${_shortMonthNames[date.month - 1]}';

class MonthsScreen extends StatelessWidget {
  const MonthsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ChangeNotifierProvider(
      create: (_) => MonthsController()..loadMonth(now.year, now.month),
      child: const _MonthsView(),
    );
  }
}

class _MonthsView extends StatefulWidget {
  const _MonthsView();

  @override
  State<_MonthsView> createState() => _MonthsViewState();
}

class _MonthsViewState extends State<_MonthsView> {
  late DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _goToPreviousMonth() {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
    _reload();
  }

  void _goToNextMonth() {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
    _reload();
  }

  void _reload() {
    context.read<MonthsController>().loadMonth(_selectedMonth.year, _selectedMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MonthsController>();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthNav(),
              Expanded(child: _buildBody(controller)),
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

  Widget _buildBody(MonthsController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.usd));
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          'No se pudo cargar este mes',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
        ),
      );
    }

    if (controller.month == null) {
      return Center(
        child: Text(
          'No hay movimientos registrados este mes',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
        ),
      );
    }

    final month = controller.month!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LedgerCard(
            label: 'Ingresos del mes',
            amount: month.incomeTotal.toStringAsFixed(2),
            currency: 'Bs',
            accentColor: AppColors.bs,
          ),
          const SizedBox(height: 4),
          LedgerCard(
            label: 'Guardado este mes',
            amount: month.totalSaving.toStringAsFixed(2),
            currency: 'USD',
            accentColor: AppColors.usd,
          ),
          const SizedBox(height: 4),
          LedgerCard(
            label: 'Egresos del mes',
            amount: month.expense.toStringAsFixed(2),
            currency: 'Bs',
            accentColor: AppColors.danger,
          ),
          const SizedBox(height: 10),

          if (controller.incomesBs.isNotEmpty) ...[
            _buildSectionLabel('Ingresos en bolívares'),
            for (final income in controller.incomesBs)
              MovementRow(
                description: income.concept,
                dateLabel: _formatDay(income.date),
                amount: '${income.amount.toStringAsFixed(2)} Bs',
                amountColor: AppColors.bs,
                onDelete: () => _confirmAndDelete(
                  context,
                  controller,
                  income.concept,
                  () => controller.deleteIncomeBs(income.id),
                ),
              ),
          ],

          if (controller.incomesDollars.isNotEmpty) ...[
            _buildSectionLabel('Ingresos en dólares'),
            for (final income in controller.incomesDollars)
              MovementRow(
                description: income.concept,
                dateLabel: _formatDay(income.date),
                amount: '${income.amount.toStringAsFixed(2)} \$',
                amountColor: AppColors.usd,
                onDelete: () => _confirmAndDelete(
                  context,
                  controller,
                  income.concept,
                  () => controller.deleteIncomeDollars(income.id),
                ),
              ),
          ],

          if (controller.buys.isNotEmpty) ...[
            _buildSectionLabel('Compras de dólares'),
            for (final buy in controller.buys)
              MovementRow(
                description: 'Compra · tasa ${buy.rate.toStringAsFixed(0)}',
                dateLabel: _formatDay(buy.date),
                amount: '${buy.dollarAmount.toStringAsFixed(2)} \$',
                amountColor: AppColors.usd,
                onDelete: () => _confirmAndDelete(
                  context,
                  controller,
                  'esta compra',
                  () => controller.deleteBuy(buy.id),
                ),
              ),
          ],

          if (controller.movements.isNotEmpty) ...[
            _buildSectionLabel('Ahorros distribuidos'),
            for (final movement in controller.movements)
              MovementRow(
                description: controller.accountNames[movement.accountId] ?? 'Cuenta',
                dateLabel: _formatDay(movement.date),
                amount: '${movement.dollarAmount.toStringAsFixed(2)} \$',
                amountColor: AppColors.usd,
                onDelete: () => _confirmAndDelete(
                  context,
                  controller,
                  'este ahorro',
                  () => controller.deleteMovement(movement.id),
                ),
              ),
          ],

          if (controller.spents.isNotEmpty) ...[
            _buildSectionLabel('Egresos'),
            for (final spent in controller.spents)
              MovementRow(
                description:
                    '${spent.description} · ${controller.accountNames[spent.accountId] ?? 'Cuenta'}',
                dateLabel: _formatDay(spent.date),
                amount: '${spent.dollarAmount.toStringAsFixed(2)} \$',
                amountColor: AppColors.danger,
                onDelete: () => _confirmAndDelete(
                  context,
                  controller,
                  spent.description,
                  () => controller.deleteSpent(spent.id),
                ),
              ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    MonthsController controller,
    String description,
    Future<bool> Function() deleteAction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Eliminar movimiento',
          style: GoogleFonts.newsreader(fontSize: 18, color: AppColors.text),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "$description"? Esta acción no se puede deshacer.',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancelar', style: GoogleFonts.ibmPlexSans(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.ibmPlexSans(color: AppColors.danger, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await deleteAction();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'No se pudo eliminar, intenta de nuevo',
            style: GoogleFonts.ibmPlexSans(),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim, letterSpacing: 0.5),
      ),
    );
  }
}
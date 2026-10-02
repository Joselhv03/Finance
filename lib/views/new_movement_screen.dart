import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../widgets/ledger_field.dart';
import '../widgets/selector_chip.dart';

enum MovementType { income, buy, saving, spent }

enum IncomeCurrency { bs, usd }

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key});

  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  MovementType _type = MovementType.income;
  IncomeCurrency _ingresoCurrency = IncomeCurrency.bs;

  // Un solo set de controllers que se reutiliza según el formulario
  // visible; evita tener uno distinto por cada tipo de movimiento.
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _sellerController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  final _accounts = const ['General', 'Viaje', 'Casa', 'Emergencia'];
  String? _selectedAccount;

  bool _loading = false;

  @override
  void dispose() {
    _conceptController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _sellerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double? get _calculatedBs {
    final dollars = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final rate = double.tryParse(_rateController.text.replaceAll(',', '.'));
    if (dollars == null || rate == null) return null;
    return dollars * rate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSubmit() {
    // Aquí, cuando conectemos el backend, cada tipo de movimiento va
    // a llamar a un método distinto del controller (ej.
    // movimientosController.registrarIngresoBs(...), etc.), usando
    // los valores de estos mismos controllers.
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: Text(
          'Nuevo movimiento',
          style: GoogleFonts.newsreader(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              if (_type == MovementType.income) ...[
                const SizedBox(height: 14),
                _buildIngresoCurrencySelector(),
              ],
              const SizedBox(height: 28),
              ..._buildFieldsForType(),
              const SizedBox(height: 32),
              _buildDateField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final options = <MovementType, String>{
      MovementType.income: 'Ingreso',
      MovementType.buy: 'Compra \$',
      MovementType.saving: 'Ahorro',
      MovementType.spent: 'Egreso',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        return SelectorChip(
          label: entry.value,
          selected: _type == entry.key,
          onTap: () => setState(() => _type = entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildIngresoCurrencySelector() {
    return Row(
      children: [
        SelectorChip(
          label: 'Bolívares',
          selected: _ingresoCurrency == IncomeCurrency.bs,
          accentColor: AppColors.bs,
          onTap: () => setState(() => _ingresoCurrency = IncomeCurrency.bs),
        ),
        const SizedBox(width: 8),
        SelectorChip(
          label: 'Dólares',
          selected: _ingresoCurrency == IncomeCurrency.usd,
          accentColor: AppColors.usd,
          onTap: () => setState(() => _ingresoCurrency = IncomeCurrency.usd),
        ),
      ],
    );
  }

  List<Widget> _buildFieldsForType() {
    switch (_type) {
      case MovementType.income:
        if (_ingresoCurrency == IncomeCurrency.bs) {
          return [
            LedgerField(label: 'Concepto', controller: _conceptController),
            const SizedBox(height: 22),
            LedgerField(
              label: 'Monto en bolívares',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ];
        } else {
          return [
            LedgerField(label: 'Concepto', controller: _conceptController),
            const SizedBox(height: 22),
            LedgerField(
              label: 'Monto en dólares',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ];
        }

      case MovementType.buy:
        return [
          LedgerField(
            label: 'Monto en dólares',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 22),
          LedgerField(
            label: 'Tasa de cambio',
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 22),
          LedgerField(
            label: 'Vendedor (opcional)',
            controller: _sellerController,
          ),
          if (_calculatedBs != null) ...[
            const SizedBox(height: 14),
            Text(
              'Total: ${_calculatedBs!.toStringAsFixed(2)} Bs',
              style: GoogleFonts.ibmPlexMono(fontSize: 13, color: AppColors.bs),
            ),
          ],
        ];

      case MovementType.saving:
        return [
          LedgerField(
            label: 'Monto en dólares',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 22),
          _buildAccountLabel(),
          const SizedBox(height: 8),
          _buildAccountChips(),
        ];

      case MovementType.spent:
        return [
          _buildAccountLabel(),
          const SizedBox(height: 8),
          _buildAccountChips(),
          const SizedBox(height: 22),
          LedgerField(
            label: 'Monto en dólares',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 22),
          LedgerField(
            label: 'Motivo',
            controller: _descriptionController,
          ),
        ];
    }
  }

  Widget _buildAccountLabel() {
    return Text(
      'Cuenta',
      style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
    );
  }

  Widget _buildAccountChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _accounts.map((account) {
        return SelectorChip(
          label: account,
          selected: _selectedAccount == account,
          onTap: () => setState(() => _selectedAccount = account),
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha',
            style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: GoogleFonts.ibmPlexSans(fontSize: 15, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.usd,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
              )
            : Text(
                'Guardar movimiento',
                style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import 'ledger_field.dart';

const List<Color> accountColorPalette = [
  AppColors.usd, // azul-violeta (color por defecto)
  AppColors.bs, // ámbar
  Color(0xFF4CD3A5), // menta
  Color(0xFFF06292), // rosa
  Color(0xFFB388FF), // lavanda
  Color(0xFF4FC3F7), // celeste
];

class NewAccountData {
  final String name;
  final double initialAmount;
  final double? targetAmount;
  final Color color;

  NewAccountData({
    required this.name,
    required this.initialAmount,
    required this.color,
    this.targetAmount,
  });
}

Future<NewAccountData?> showCreateAccountSheet(BuildContext context) {
  return showModalBottomSheet<NewAccountData>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _CreateAccountSheetContent(),
  );
}

class _CreateAccountSheetContent extends StatefulWidget {
  const _CreateAccountSheetContent();

  @override
  State<_CreateAccountSheetContent> createState() =>
      _CreateAccountSheetContentState();
}

class _CreateAccountSheetContentState
    extends State<_CreateAccountSheetContent> {
  final _nameController = TextEditingController();
  final _initialAmountController = TextEditingController(text: '0');
  final _targetAmountController = TextEditingController();

  Color _selectedColor = accountColorPalette.first;

  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _handleCreate() {

    setState(() => _errorText = null);

    final name = _nameController.text.trim();
    final initialAmount =
        double.tryParse(_initialAmountController.text.replaceAll(',', '.'));
    final targetText = _targetAmountController.text.trim();
    final targetAmount =
        targetText.isEmpty ? null : double.tryParse(targetText.replaceAll(',', '.'));

    if (name.isEmpty) {
      setState(() => _errorText = 'Ponle un nombre a la cuenta');
      return;
    }
    if (initialAmount == null || initialAmount < 0) {
      setState(() => _errorText = 'El monto inicial debe ser un número mayor o igual a 0');
      return;
    }
    if (targetText.isNotEmpty && (targetAmount == null || targetAmount <= 0)) {
      setState(() => _errorText = 'El monto objetivo debe ser un número mayor a 0');
      return;
    }

    Navigator.pop(
      context,
      NewAccountData(
        name: name,
        initialAmount: initialAmount,
        targetAmount: targetAmount,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Nueva cuenta de ahorro',
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),

            LedgerField(label: 'Nombre', controller: _nameController),
            const SizedBox(height: 22),

            LedgerField(
              label: 'Monto inicial',
              controller: _initialAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 22),

            LedgerField(
              label: 'Monto objetivo (opcional)',
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 22),

            Text(
              'Color',
              style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
            ),
            const SizedBox(height: 10),
            _buildColorPicker(),

            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Crear cuenta',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: accountColorPalette.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.text, width: 2)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: AppColors.ink)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
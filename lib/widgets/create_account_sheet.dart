import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import 'ledger_field.dart';

// Paleta de colores disponibles para personalizar una cuenta.
// Elegidos para que se sigan viendo bien sobre el fondo oscuro de
// la app (nada demasiado apagado ni demasiado saturado).
const List<Color> accountColorPalette = [
  AppColors.usd, // azul-violeta (color por defecto)
  AppColors.bs, // ámbar
  Color(0xFF4CD3A5), // menta
  Color(0xFFF06292), // rosa
  Color(0xFFB388FF), // lavanda
  Color(0xFF4FC3F7), // celeste
];

// El resultado que le devuelve la hoja a quien la llamó, para que
// la pantalla de Cuentas sepa qué hacer con los datos.
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

// Función helper: así se abre la hoja desde cualquier pantalla.
// Devuelve los datos si el usuario guardó, o null si canceló.
Future<NewAccountData?> showCreateAccountSheet(BuildContext context) {
  return showModalBottomSheet<NewAccountData>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true, // permite que la hoja crezca con el teclado
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

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    final name = _nameController.text.trim();
    final initialAmount =
        double.tryParse(_initialAmountController.text.replaceAll(',', '.'));
    final targetText = _targetAmountController.text.trim();
    final targetAmount =
        targetText.isEmpty ? null : double.tryParse(targetText.replaceAll(',', '.'));

    if (name.isEmpty) {
      _showError('Ponle un nombre a la cuenta');
      return;
    }
    if (initialAmount == null || initialAmount < 0) {
      _showError('El monto inicial debe ser un número mayor o igual a 0');
      return;
    }
    if (targetText.isNotEmpty && (targetAmount == null || targetAmount <= 0)) {
      _showError('El monto objetivo debe ser un número mayor a 0');
      return;
    }

    // Cierra la hoja devolviendo los datos ya validados. Quien la
    // abrió (accounts_screen.dart) decide qué hacer con ellos —
    // por ahora, solo agregarlos a la lista en memoria.
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.ibmPlexSans()),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding.viewInsets empuja el contenido hacia arriba cuando el
    // teclado aparece, para que no tape el campo que estás llenando.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
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
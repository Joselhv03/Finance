import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import 'create_account_sheet.dart' show accountColorPalette;
import 'ledger_field.dart';

class EditAccountData {
  final String name;
  final double? targetAmount;
  final Color color;

  EditAccountData({
    required this.name,
    required this.color,
    this.targetAmount,
  });
}

Future<EditAccountData?> showEditAccountSheet(
  BuildContext context, {
  required String initialName,
  required double? initialTarget,
  required Color initialColor,
}) {
  return showModalBottomSheet<EditAccountData>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _EditAccountSheetContent(
      initialName: initialName,
      initialTarget: initialTarget,
      initialColor: initialColor,
    ),
  );
}

class _EditAccountSheetContent extends StatefulWidget {
  final String initialName;
  final double? initialTarget;
  final Color initialColor;

  const _EditAccountSheetContent({
    required this.initialName,
    required this.initialTarget,
    required this.initialColor,
  });

  @override
  State<_EditAccountSheetContent> createState() => _EditAccountSheetContentState();
}

class _EditAccountSheetContentState extends State<_EditAccountSheetContent> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _targetController = TextEditingController(
    text: widget.initialTarget != null ? widget.initialTarget!.toStringAsFixed(2) : '',
  );
  late Color _selectedColor = widget.initialColor;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final targetText = _targetController.text.trim();
    final targetAmount =
        targetText.isEmpty ? null : double.tryParse(targetText.replaceAll(',', '.'));

    if (name.isEmpty) {
      _showError('Ponle un nombre a la cuenta');
      return;
    }
    if (targetText.isNotEmpty && (targetAmount == null || targetAmount <= 0)) {
      _showError('El monto objetivo debe ser un número mayor a 0');
      return;
    }

    Navigator.pop(
      context,
      EditAccountData(name: name, targetAmount: targetAmount, color: _selectedColor),
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              'Editar cuenta',
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
              label: 'Monto objetivo (opcional)',
              controller: _targetController,
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
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  'Guardar cambios',
                  style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w500),
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
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppColors.text, width: 2) : null,
            ),
            child: isSelected ? const Icon(Icons.check, size: 16, color: AppColors.ink) : null,
          ),
        );
      }).toList(),
    );
  }
}
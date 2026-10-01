import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import 'edit_account_sheet.dart';

class ExpandableAccountCard extends StatefulWidget {
  final String name;
  final double total;
  final double? target; // null = sin meta, no muestra barra de progreso
  final Color color;

  // Se ejecuta cuando el usuario confirma los cambios en la hoja de
  // edición. El widget solo "pide" los nuevos datos; es el padre
  // (accounts_screen.dart) quien decide cómo actualizar la lista.
  final ValueChanged<EditAccountData> onEdit;

  // Se ejecuta SOLO después de que el usuario confirma el diálogo
  // de "¿seguro que quieres eliminar?" dentro de esta misma tarjeta.
  final VoidCallback onDelete;

  const ExpandableAccountCard({
    super.key,
    required this.name,
    required this.total,
    required this.color,
    required this.onEdit,
    required this.onDelete,
    this.target,
  });

  @override
  State<ExpandableAccountCard> createState() => _ExpandableAccountCardState();
}

class _ExpandableAccountCardState extends State<ExpandableAccountCard> {
  bool _expanded = false;

  Future<void> _handleEditTap() async {
    final result = await showEditAccountSheet(
      context,
      initialName: widget.name,
      initialTarget: widget.target,
      initialColor: widget.color,
    );
    if (result != null) {
      widget.onEdit(result);
    }
  }

  Future<void> _handleDeleteTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Eliminar cuenta',
          style: GoogleFonts.newsreader(fontSize: 18, color: AppColors.text),
        ),
        content: Text(
          '¿Seguro que quieres eliminar "${widget.name}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.ibmPlexSans(color: AppColors.textDim),
            ),
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

    // confirmed puede ser true, false, o null (si tocó fuera del
    // diálogo para cerrarlo) — solo procedemos si es true.
    if (confirmed == true) {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.name,
                        style: GoogleFonts.ibmPlexSans(fontSize: 14, color: AppColors.text),
                      ),
                    ],
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textDim,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _buildExpandedContent(),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final progress = widget.target != null && widget.target! > 0
        ? (widget.total / widget.target!).clamp(0.0, 1.0)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.total.toStringAsFixed(2)} \$',
            style: GoogleFonts.newsreader(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: widget.color,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.line,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Meta: ${widget.target!.toStringAsFixed(2)} \$  ·  ${(progress * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.ibmPlexMono(fontSize: 11, color: AppColors.textDim),
            ),
          ],

          // ── Botones de editar/eliminar, al final del contenido
          // expandido, como pediste.
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleEditTap,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('Editar', style: GoogleFonts.ibmPlexSans(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDim,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleDeleteTap,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text('Eliminar', style: GoogleFonts.ibmPlexSans(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
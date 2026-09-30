import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class ExpandableAccountCard extends StatefulWidget {
  final String name;
  final double total;
  final double? target; // null = sin meta, no muestra barra de progreso
  final Color color;

  const ExpandableAccountCard({
    super.key,
    required this.name,
    required this.total,
    required this.color,
    this.target,
  });

  @override
  State<ExpandableAccountCard> createState() => _ExpandableAccountCardState();
}

class _ExpandableAccountCardState extends State<ExpandableAccountCard> {
  bool _expanded = false;

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
          // Encabezado: siempre visible, es lo que se toca para
          // expandir o colapsar.
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
                      // Puntito de color: identifica la cuenta de un
                      // vistazo, incluso colapsada.
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.name,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          color: AppColors.text,
                        ),
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

          // AnimatedCrossFade anima suavemente entre "nada" y el
          // contenido expandido, en vez de que aparezca de golpe.
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
        ],
      ),
    );
  }
}
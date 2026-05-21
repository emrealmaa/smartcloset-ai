import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enums/body_enums.dart';
import '../../../providers/character_provider.dart';
import '../../../theme/app_theme.dart';

class Step1Body extends ConsumerWidget {
  const Step1Body({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Boy
        _SectionLabel('Boy'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: state.heightCm.toDouble(),
                min: 150,
                max: 210,
                divisions: 60,
                activeColor: AppTheme.neonGreen,
                inactiveColor: AppTheme.softGray,
                onChanged: (v) => notifier.setHeight(v.round()),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warmWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.softGray),
              ),
              child: Text(
                '${state.heightCm} cm',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.charcoal),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Kilo
        _SectionLabel('Kilo'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: state.weightKg,
                min: 40,
                max: 150,
                divisions: 110,
                activeColor: AppTheme.neonGreen,
                inactiveColor: AppTheme.softGray,
                onChanged: notifier.setWeight,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warmWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.softGray),
              ),
              child: Text(
                '${state.weightKg.round()} kg',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.charcoal),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Vücut tipi
        _SectionLabel('Vücut Tipin'),
        const SizedBox(height: 4),
        Text(
          'Genel yapını en iyi hangisi tanımlıyor?',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: BodyType.values
              .map((type) => _BodyTypeCard(
                    type: type,
                    isSelected: state.bodyType == type,
                    onTap: () => notifier.setBodyType(type),
                  ))
              .toList(),
        ),

        const SizedBox(height: 24),

        // Proporsiyon
        _SectionLabel('Proporsiyon'),
        const SizedBox(height: 12),
        _SegmentRow<ShoulderWidth>(
          label: 'Omuz Genişliği',
          values: ShoulderWidth.values,
          selected: state.shoulderWidth,
          labelOf: (v) => v.label,
          onSelect: notifier.setShoulderWidth,
        ),
        const SizedBox(height: 10),
        _SegmentRow<TorsoLength>(
          label: 'Torso Uzunluğu',
          values: TorsoLength.values,
          selected: state.torsoLength,
          labelOf: (v) => v.label,
          onSelect: notifier.setTorsoLength,
        ),
        const SizedBox(height: 10),
        _SegmentRow<LegLength>(
          label: 'Bacak Uzunluğu',
          values: LegLength.values,
          selected: state.legLength,
          labelOf: (v) => v.label,
          onSelect: notifier.setLegLength,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Body Type Card ────────────────────────────────────────────────
class _BodyTypeCard extends StatelessWidget {
  final BodyType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyTypeCard(
      {required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonGreen.withOpacity(0.08)
              : AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.neonGreen : AppTheme.softGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BodyShapeIcon(type: type, isSelected: isSelected),
            const SizedBox(height: 6),
            Text(
              type.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.neonGreen : AppTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                type.description,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 9, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Body Shape Icon (custom paint) ────────────────────────────────
class _BodyShapeIcon extends StatelessWidget {
  final BodyType type;
  final bool isSelected;

  const _BodyShapeIcon({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppTheme.neonGreen : AppTheme.mediumGray;
    return SizedBox(
      width: 36,
      height: 44,
      child: CustomPaint(painter: _BodyPainter(type: type, color: color)),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final BodyType type;
  final Color color;

  _BodyPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case BodyType.triangle:
        // Üçgen: üst dar, alt geniş
        final path = Path()
          ..moveTo(w * 0.35, 0)
          ..lineTo(w * 0.65, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(path, paint);
      case BodyType.invertedTriangle:
        // Ters üçgen: üst geniş, alt dar
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w * 0.65, h)
          ..lineTo(w * 0.35, h)
          ..close();
        canvas.drawPath(path, paint);
      case BodyType.rectangle:
        // Dikdörtgen: eşit genişlik
        final rect = Rect.fromLTWH(w * 0.1, 0, w * 0.8, h);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
      case BodyType.oval:
        // Oval: ortası geniş
        final path = Path()
          ..moveTo(w * 0.2, 0)
          ..lineTo(w * 0.8, 0)
          ..lineTo(w, h * 0.5)
          ..lineTo(w * 0.8, h)
          ..lineTo(w * 0.2, h)
          ..lineTo(0, h * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      case BodyType.athletic:
        // Atletik: omuz geniş, bel dar, kalça orta
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w * 0.75, h * 0.45)
          ..lineTo(w * 0.72, h * 0.5)
          ..lineTo(w * 0.78, h)
          ..lineTo(w * 0.22, h)
          ..lineTo(w * 0.28, h * 0.5)
          ..lineTo(w * 0.25, h * 0.45)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.type != type || old.color != color;
}

// ── Section Label ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.charcoal,
      ),
    );
  }
}

// ── Segment Row ───────────────────────────────────────────────────
class _SegmentRow<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _SegmentRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Row(
            children: values.map((v) {
              final isSelected = v == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.charcoal
                          : AppTheme.warmWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.charcoal : AppTheme.softGray,
                      ),
                    ),
                    child: Text(
                      labelOf(v),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.charcoal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

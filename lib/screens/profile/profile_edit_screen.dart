import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/enums/body_enums.dart';
import '../../core/enums/face_enums.dart';
import '../../core/enums/skin_enums.dart';
import '../../core/enums/style_enums.dart';
import '../../providers/character_provider.dart';
import '../../theme/app_theme.dart';

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileEditProvider);
    final notifier = ref.read(profileEditProvider.notifier);

    ref.listen(profileEditProvider, (_, next) {
      if (next.saved) Navigator.of(context).pop();
    });

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _Header(isSaving: state.isSaving, onSave: () => notifier.save()),
            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  // ── Vücut ────────────────────────────────────
                  _sectionTitle('Vücut'),
                  const SizedBox(height: 16),
                  _SliderRow(
                    label: 'Boy',
                    value: state.heightCm.toDouble(),
                    min: 150,
                    max: 210,
                    divisions: 60,
                    display: '${state.heightCm} cm',
                    onChanged: (v) => notifier.setHeight(v.round()),
                  ),
                  const SizedBox(height: 16),
                  _SliderRow(
                    label: 'Kilo',
                    value: state.weightKg,
                    min: 40,
                    max: 150,
                    divisions: 110,
                    display: '${state.weightKg.round()} kg',
                    onChanged: notifier.setWeight,
                  ),
                  const SizedBox(height: 20),
                  _subLabel('Vücut Tipi'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.9,
                    children: BodyType.values
                        .map((t) => _BodyTypeCard(
                              type: t,
                              isSelected: state.bodyType == t,
                              onTap: () => notifier.setBodyType(t),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _subLabel('Proporsiyon'),
                  const SizedBox(height: 12),
                  _SegmentRow<ShoulderWidth>(
                    label: 'Omuz',
                    values: ShoulderWidth.values,
                    selected: state.shoulderWidth,
                    labelOf: (v) => v.label,
                    onSelect: notifier.setShoulderWidth,
                  ),
                  const SizedBox(height: 8),
                  _SegmentRow<TorsoLength>(
                    label: 'Torso',
                    values: TorsoLength.values,
                    selected: state.torsoLength,
                    labelOf: (v) => v.label,
                    onSelect: notifier.setTorsoLength,
                  ),
                  const SizedBox(height: 8),
                  _SegmentRow<LegLength>(
                    label: 'Bacak',
                    values: LegLength.values,
                    selected: state.legLength,
                    labelOf: (v) => v.label,
                    onSelect: notifier.setLegLength,
                  ),

                  _divider(),

                  // ── Ten & Göz ─────────────────────────────────
                  _sectionTitle('Ten & Göz'),
                  const SizedBox(height: 16),
                  _subLabel('Cilt Rengi'),
                  const SizedBox(height: 12),
                  Row(
                    children: SkinDepth.values.map((depth) {
                      final isSel = state.skinDepth == depth;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => notifier.setSkinDepth(depth),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: depth.swatchColor,
                                  border: Border.all(
                                    color: isSel
                                        ? AppTheme.charcoal
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: AppTheme.charcoal
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                depth.label,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSel
                                      ? AppTheme.charcoal
                                      : AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  _subLabel('Cilt Alt Tonu'),
                  const SizedBox(height: 12),
                  ...SkinUndertone.values.map((undertone) {
                    final isSel = state.skinUndertone == undertone;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => notifier.setSkinUndertone(undertone),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSel
                                ? undertone.accentColor.withValues(alpha: 0.07)
                                : AppTheme.warmWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                  ? undertone.accentColor
                                  : AppTheme.softGray,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: undertone.accentColor
                                      .withValues(alpha: 0.2),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: undertone.accentColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      undertone.label,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.charcoal,
                                      ),
                                    ),
                                    Text(
                                      undertone.description,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSel)
                                Icon(Icons.check_circle,
                                    color: undertone.accentColor, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  _subLabel('Göz Rengi'),
                  const SizedBox(height: 12),
                  _ColorCircleRow<EyeColor>(
                    values: EyeColor.values,
                    selected: state.eyeColor,
                    colorOf: (e) => e.swatchColor,
                    labelOf: (e) => e.label,
                    onSelect: notifier.setEyeColor,
                  ),

                  _divider(),

                  // ── Saç & Yüz ─────────────────────────────────
                  _sectionTitle('Saç & Yüz'),
                  const SizedBox(height: 16),
                  _subLabel('Yüz Şekli'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: FaceShape.values.map((shape) {
                      final isSel = state.faceShape == shape;
                      return _ChipCard(
                        label: shape.label,
                        isSelected: isSel,
                        icon: _faceShapeIcon(shape),
                        onTap: () => notifier.setFaceShape(shape),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  _subLabel('Saç Rengi'),
                  const SizedBox(height: 12),
                  _ColorCircleRow<HairColor>(
                    values: HairColor.values,
                    selected: state.hairColor,
                    colorOf: (e) => e.swatchColor,
                    labelOf: (e) => e.label,
                    onSelect: notifier.setHairColor,
                  ),

                  const SizedBox(height: 20),
                  _subLabel('Saç Uzunluğu'),
                  const SizedBox(height: 8),
                  _ChipWrap<HairLength>(
                    values: HairLength.values,
                    selected: state.hairLength,
                    labelOf: (e) => e.label,
                    onSelect: notifier.setHairLength,
                  ),

                  const SizedBox(height: 16),
                  _subLabel('Saç Dokusu'),
                  const SizedBox(height: 8),
                  _ChipWrap<HairTexture>(
                    values: HairTexture.values,
                    selected: state.hairTexture,
                    labelOf: (e) => e.label,
                    onSelect: notifier.setHairTexture,
                  ),

                  const SizedBox(height: 16),
                  _subLabel('Sakal'),
                  const SizedBox(height: 8),
                  _ChipWrap<BeardStyle>(
                    values: BeardStyle.values,
                    selected: state.beardStyle,
                    labelOf: (e) => e.label,
                    onSelect: notifier.setBeardStyle,
                  ),

                  _divider(),

                  // ── Stil Tercihleri ───────────────────────────
                  _sectionTitle('Stil Tercihleri'),
                  const SizedBox(height: 4),
                  Text(
                    'Birden fazla seçebilirsin.',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ...StyleGoal.values.map((goal) {
                    final isSel = state.styleGoals.contains(goal);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => notifier.toggleStyleGoal(goal),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.charcoal
                                : AppTheme.warmWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                  ? AppTheme.charcoal
                                  : AppTheme.softGray,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(goal.emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.label,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSel
                                            ? Colors.white
                                            : AppTheme.charcoal,
                                      ),
                                    ),
                                    Text(
                                      goal.description,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        color: isSel
                                            ? Colors.white60
                                            : AppTheme.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSel
                                      ? AppTheme.accentGreen
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSel
                                        ? AppTheme.accentGreen
                                        : AppTheme.softGray,
                                    width: 2,
                                  ),
                                ),
                                child: isSel
                                    ? const Icon(Icons.check,
                                        size: 12, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  if (state.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────
Widget _sectionTitle(String text) => Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.charcoal,
        letterSpacing: -0.3,
      ),
    );

Widget _subLabel(String text) => Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.charcoal,
      ),
    );

Widget _divider() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Container(height: 1, color: AppTheme.softGray),
    );

IconData _faceShapeIcon(FaceShape shape) => switch (shape) {
      FaceShape.oval => Icons.egg_outlined,
      FaceShape.round => Icons.circle_outlined,
      FaceShape.square => Icons.crop_square,
      FaceShape.rectangle => Icons.crop_portrait,
      FaceShape.heart => Icons.favorite_border,
      FaceShape.diamond => Icons.diamond_outlined,
    };

// ── Header ────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  const _Header({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warmWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.softGray),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppTheme.charcoal),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Profili Düzenle',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoal,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: isSaving ? null : onSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: isSaving
                    ? AppTheme.mediumGray
                    : AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Kaydet',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slider Row ────────────────────────────────────────────────────
class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subLabel(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppTheme.neonGreen,
                inactiveColor: AppTheme.softGray,
                onChanged: onChanged,
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
                display,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.charcoal),
              ),
            ),
          ],
        ),
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
              ? AppTheme.neonGreen.withValues(alpha: 0.08)
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
            SizedBox(
              width: 32,
              height: 40,
              child: CustomPaint(
                painter: _BodyPainter(
                  type: type,
                  color: isSelected ? AppTheme.neonGreen : AppTheme.mediumGray,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.neonGreen : AppTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.35, 0)
              ..lineTo(w * 0.65, 0)
              ..lineTo(w, h)
              ..lineTo(0, h)
              ..close(),
            paint);
      case BodyType.invertedTriangle:
        canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..lineTo(w, 0)
              ..lineTo(w * 0.65, h)
              ..lineTo(w * 0.35, h)
              ..close(),
            paint);
      case BodyType.rectangle:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.1, 0, w * 0.8, h), const Radius.circular(4)),
            paint);
      case BodyType.oval:
        canvas.drawPath(
            Path()
              ..moveTo(w * 0.2, 0)
              ..lineTo(w * 0.8, 0)
              ..lineTo(w, h * 0.5)
              ..lineTo(w * 0.8, h)
              ..lineTo(w * 0.2, h)
              ..lineTo(0, h * 0.5)
              ..close(),
            paint);
      case BodyType.athletic:
        canvas.drawPath(
            Path()
              ..moveTo(0, 0)
              ..lineTo(w, 0)
              ..lineTo(w * 0.75, h * 0.45)
              ..lineTo(w * 0.72, h * 0.5)
              ..lineTo(w * 0.78, h)
              ..lineTo(w * 0.22, h)
              ..lineTo(w * 0.28, h * 0.5)
              ..lineTo(w * 0.25, h * 0.45)
              ..close(),
            paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.type != type || old.color != color;
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
          width: 60,
          child: Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Row(
            children: values.map((v) {
              final isSel = v == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSel ? AppTheme.charcoal : AppTheme.warmWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSel
                            ? AppTheme.charcoal
                            : AppTheme.softGray,
                      ),
                    ),
                    child: Text(
                      labelOf(v),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : AppTheme.charcoal,
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

// ── Color Circle Row ──────────────────────────────────────────────
class _ColorCircleRow<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final Color Function(T) colorOf;
  final String Function(T) labelOf;
  final void Function(T) onSelect;
  const _ColorCircleRow({
    required this.values,
    required this.selected,
    required this.colorOf,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((v) {
          final isSel = v == selected;
          return GestureDetector(
            onTap: () => onSelect(v),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorOf(v),
                      border: Border.all(
                        color: isSel
                            ? AppTheme.charcoal
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labelOf(v),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight:
                          isSel ? FontWeight.w700 : FontWeight.w400,
                      color: isSel
                          ? AppTheme.charcoal
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Chip Card ─────────────────────────────────────────────────────
class _ChipCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  const _ChipCard(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.charcoal : AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.charcoal : AppTheme.softGray,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppTheme.mediumGray),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip Wrap ─────────────────────────────────────────────────────
class _ChipWrap<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;
  const _ChipWrap({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final isSel = v == selected;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSel ? AppTheme.charcoal : AppTheme.warmWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSel ? AppTheme.charcoal : AppTheme.softGray,
              ),
            ),
            child: Text(
              labelOf(v),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : AppTheme.charcoal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

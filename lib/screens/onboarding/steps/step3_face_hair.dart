import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enums/face_enums.dart';
import '../../../providers/character_provider.dart';
import '../../../theme/app_theme.dart';

class Step3FaceHair extends ConsumerWidget {
  const Step3FaceHair({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Yüz Şekli
        _label('Yüz Şekli'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: FaceShape.values.map((shape) {
            final isSelected = state.faceShape == shape;
            return _ChipCard(
              label: shape.label,
              isSelected: isSelected,
              onTap: () => notifier.setFaceShape(shape),
              icon: _faceShapeIcon(shape),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Göz Rengi
        _label('Göz Rengi'),
        const SizedBox(height: 12),
        _ColorCircleRow<EyeColor>(
          values: EyeColor.values,
          selected: state.eyeColor,
          colorOf: (e) => e.swatchColor,
          labelOf: (e) => e.label,
          onSelect: notifier.setEyeColor,
        ),

        const SizedBox(height: 24),

        // Saç Rengi
        _label('Saç Rengi'),
        const SizedBox(height: 12),
        _ColorCircleRow<HairColor>(
          values: HairColor.values,
          selected: state.hairColor,
          colorOf: (e) => e.swatchColor,
          labelOf: (e) => e.label,
          onSelect: notifier.setHairColor,
        ),

        const SizedBox(height: 24),

        // Saç Uzunluğu
        _label('Saç Uzunluğu'),
        const SizedBox(height: 8),
        _ChipWrap<HairLength>(
          values: HairLength.values,
          selected: state.hairLength,
          labelOf: (e) => e.label,
          onSelect: notifier.setHairLength,
        ),

        const SizedBox(height: 20),

        // Saç Dokusu
        _label('Saç Dokusu'),
        const SizedBox(height: 8),
        _ChipWrap<HairTexture>(
          values: HairTexture.values,
          selected: state.hairTexture,
          labelOf: (e) => e.label,
          onSelect: notifier.setHairTexture,
        ),

        const SizedBox(height: 20),

        // Sakal
        _label('Sakal'),
        const SizedBox(height: 8),
        _ChipWrap<BeardStyle>(
          values: BeardStyle.values,
          selected: state.beardStyle,
          labelOf: (e) => e.label,
          onSelect: notifier.setBeardStyle,
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal),
      );

  IconData _faceShapeIcon(FaceShape shape) => switch (shape) {
        FaceShape.oval => Icons.egg_outlined,
        FaceShape.round => Icons.circle_outlined,
        FaceShape.square => Icons.crop_square,
        FaceShape.rectangle => Icons.crop_portrait,
        FaceShape.heart => Icons.favorite_border,
        FaceShape.diamond => Icons.diamond_outlined,
      };
}

// ── Chip Card ─────────────────────────────────────────────────────
class _ChipCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _ChipCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.charcoal
              : AppTheme.warmWhite,
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
                  size: 20,
                  color: isSelected ? Colors.white : AppTheme.mediumGray),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
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
          final isSelected = v == selected;
          return GestureDetector(
            onTap: () => onSelect(v),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorOf(v),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.charcoal
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
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
        final isSelected = v == selected;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.charcoal : AppTheme.warmWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppTheme.charcoal : AppTheme.softGray,
              ),
            ),
            child: Text(
              labelOf(v),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.charcoal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enums/skin_enums.dart';
import '../../../providers/character_provider.dart';
import '../../../theme/app_theme.dart';

class Step2Skin extends ConsumerWidget {
  const Step2Skin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Cilt Rengi
        _sectionLabel('Cilt Rengi'),
        const SizedBox(height: 12),
        Row(
          children: SkinDepth.values.map((depth) {
            final isSelected = state.skinDepth == depth;
            return Expanded(
              child: GestureDetector(
                onTap: () => notifier.setSkinDepth(depth),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: depth.swatchColor,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.charcoal
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.charcoal.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      depth.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
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

        const SizedBox(height: 32),

        // Cilt Alt Tonu
        _sectionLabel('Cilt Alt Tonu'),
        const SizedBox(height: 4),
        Text(
          'Bileğindeki damarların rengine bak.',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        ...SkinUndertone.values.map((undertone) {
          final isSelected = state.skinUndertone == undertone;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => notifier.setSkinUndertone(undertone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? undertone.accentColor.withOpacity(0.06)
                      : AppTheme.warmWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? undertone.accentColor
                        : AppTheme.softGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: undertone.accentColor.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: undertone.accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            undertone.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            undertone.description,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: undertone.accentColor, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Önizleme palette
        if (state.skinUndertone != null) ...[
          _sectionLabel('Sana Uyan Renkler'),
          const SizedBox(height: 12),
          _PalettePreview(undertone: state.skinUndertone!),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) {
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

class _PalettePreview extends StatelessWidget {
  final SkinUndertone undertone;
  const _PalettePreview({required this.undertone});

  @override
  Widget build(BuildContext context) {
    final colors = undertone.palette;
    final labels = undertone.paletteLabels;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Row(
        children: List.generate(colors.length, (i) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 9, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

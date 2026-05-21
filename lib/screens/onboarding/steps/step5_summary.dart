import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enums/body_enums.dart';
import '../../../core/enums/face_enums.dart';
import '../../../core/enums/skin_enums.dart';
import '../../../core/enums/style_enums.dart';
import '../../../providers/character_provider.dart';
import '../../../theme/app_theme.dart';

class Step5Summary extends ConsumerWidget {
  const Step5Summary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    if (!state.step1Valid || !state.step2Valid || !state.step3Valid) {
      return const Center(child: Text('Lütfen önceki adımları tamamla.'));
    }

    final undertone = state.skinUndertone!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Başlık
        Text(
          'Karakterin hazır!',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.charcoal,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sana özel stil kuralların oluşturuldu.',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),

        // Karakter Kartı
        _CharacterCard(state: state),

        const SizedBox(height: 20),

        // Renk Paleti
        _label('Renk Paletin'),
        const SizedBox(height: 4),
        Text(
          'Cilt alt tonuna göre sana en çok yakışan renkler:',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        _PaletteCard(undertone: undertone),

        const SizedBox(height: 20),

        // Stil Tercihleri (varsa)
        if (state.styleGoals.isNotEmpty) ...[
          _label('Tarz Hedeflerin'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.styleGoals
                .map((g) => _StyleChip(goal: g))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Özet uyarı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonGreen.withOpacity(0.06),
                AppTheme.accentGreen.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.neonGreen.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.neonGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bu bilgiler gardırobunu analiz etmek ve sana özel '
                  'kombinler üretmek için kullanılacak. '
                  'Profili istediğin zaman güncelleyebilirsin.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.neonGreen,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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
}

// ── Character Card ────────────────────────────────────────────────
class _CharacterCard extends StatelessWidget {
  final OnboardingState state;
  const _CharacterCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst şerit
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      color: AppTheme.neonGreen, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karakter Profili',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${state.bodyType!.label} · ${state.skinUndertone!.label} Ton',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stat grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _Stat(
                        icon: Icons.straighten,
                        label: 'Boy / Kilo',
                        value:
                            '${state.heightCm} cm · ${state.weightKg.round()} kg'),
                    const SizedBox(width: 12),
                    _Stat(
                        icon: Icons.face,
                        label: 'Yüz Şekli',
                        value: state.faceShape!.label),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Stat(
                        icon: Icons.palette_outlined,
                        label: 'Cilt',
                        value:
                            '${state.skinDepth!.label} · ${state.skinUndertone!.label}'),
                    const SizedBox(width: 12),
                    _Stat(
                        icon: Icons.content_cut,
                        label: 'Saç',
                        value:
                            '${state.hairLength!.label} · ${state.hairTexture!.label}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Stat(
                        icon: Icons.remove_red_eye_outlined,
                        label: 'Göz',
                        value: state.eyeColor!.label),
                    const SizedBox(width: 12),
                    _Stat(
                        icon: Icons.accessibility_new,
                        label: 'Omuz / Bacak',
                        value:
                            '${state.shoulderWidth!.label} · ${state.legLength!.label}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: AppTheme.accentGreen),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Palette Card ──────────────────────────────────────────────────
class _PaletteCard extends StatelessWidget {
  final SkinUndertone undertone;
  const _PaletteCard({required this.undertone});

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
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
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

// ── Style Chip ────────────────────────────────────────────────────
class _StyleChip extends StatelessWidget {
  final StyleGoal goal;
  const _StyleChip({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            goal.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

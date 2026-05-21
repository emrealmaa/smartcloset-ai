import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enums/style_enums.dart';
import '../../../providers/character_provider.dart';
import '../../../theme/app_theme.dart';

class Step4StylePrefs extends ConsumerWidget {
  const Step4StylePrefs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text(
          'Hangi tarzlara ilgi duyuyorsun?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Birden fazla seçebilirsin.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: AppTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 20),
        ...StyleGoal.values.map((goal) {
          final isSelected = state.styleGoals.contains(goal);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => notifier.toggleStyleGoal(goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.charcoal
                      : AppTheme.warmWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.charcoal
                        : AppTheme.softGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppTheme.accentGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentGreen
                              : AppTheme.softGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.neonGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppTheme.neonGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bu adım opsiyoneldir. Seçim yapmadan da devam edebilirsin.',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, color: AppTheme.neonGreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

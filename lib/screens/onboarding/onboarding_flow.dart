import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/character_provider.dart';
import '../../theme/app_theme.dart';
import 'steps/step1_body.dart';
import 'steps/step2_skin.dart';
import 'steps/step3_face_hair.dart';
import 'steps/step4_style_prefs.dart';
import 'steps/step5_summary.dart';
import '../home/home_screen.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  late final PageController _pageController;

  static const _stepTitles = [
    'Vücut Ölçülerin',
    'Cilt Profilin',
    'Yüz & Saç',
    'Tarz Tercihlerim',
    'Karakterin Hazır!',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onNext(OnboardingState state) async {
    if (state.step < 3) {
      ref.read(onboardingProvider.notifier).nextStep();
      _goToStep(state.step + 1);
    } else if (state.step == 3) {
      // Adım 4'ten özet ekranına geç
      ref.read(onboardingProvider.notifier).nextStep();
      _goToStep(4);
    } else if (state.step == 4) {
      // Kaydet
      final success = await ref.read(onboardingProvider.notifier).save();
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    }
  }

  void _onBack(OnboardingState state) {
    if (state.step > 0) {
      ref.read(onboardingProvider.notifier).prevStep();
      _goToStep(state.step - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Step1Body(),
                  Step2Skin(),
                  Step3FaceHair(),
                  Step4StylePrefs(),
                  Step5Summary(),
                ],
              ),
            ),
            _buildFooter(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OnboardingState state) {
    final isLast = state.step == 4;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.step > 0)
                GestureDetector(
                  onTap: () => _onBack(state),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warmWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.softGray),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppTheme.charcoal),
                  ),
                )
              else
                const SizedBox(width: 36),
              const Spacer(),
              if (!isLast)
                Text(
                  '${state.step + 1} / 5',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLast) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (state.step + 1) / 5,
                backgroundColor: AppTheme.softGray,
                color: AppTheme.neonGreen,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _stepTitles[state.step],
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoal,
                letterSpacing: -0.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFooter(OnboardingState state) {
    final isSaving = state.isSaving;
    final canProceed = state.currentStepValid;
    final isLast = state.step == 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                state.error!,
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.errorRed, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  (!canProceed || isSaving) ? null : () => _onNext(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppTheme.neonGreen : AppTheme.charcoal,
                disabledBackgroundColor: AppTheme.softGray,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLast ? 'Gardıroba Başla' : 'İleri',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
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

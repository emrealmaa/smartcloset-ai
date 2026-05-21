import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/enums/body_enums.dart';
import '../core/enums/skin_enums.dart';
import '../core/enums/face_enums.dart';
import '../core/enums/style_enums.dart';
import '../models/character_profile.dart';
import '../data/repositories/character_repository.dart';

// ── Repository provider ───────────────────────────────────────────
final characterRepositoryProvider = Provider<CharacterRepository>(
  (_) => CharacterRepository(),
);

// ── Mevcut kullanıcının karakter profili ──────────────────────────
final characterProfileProvider = FutureProvider<CharacterProfile?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return ref.read(characterRepositoryProvider).getProfile(user.uid);
});

// ── Onboarding State ──────────────────────────────────────────────
class OnboardingState {
  final int step; // 0 – 4

  // Adım 1
  final int heightCm;
  final double weightKg;
  final BodyType? bodyType;
  final ShoulderWidth? shoulderWidth;
  final TorsoLength? torsoLength;
  final LegLength? legLength;

  // Adım 2
  final SkinDepth? skinDepth;
  final SkinUndertone? skinUndertone;

  // Adım 3
  final FaceShape? faceShape;
  final EyeColor? eyeColor;
  final HairColor? hairColor;
  final HairLength? hairLength;
  final HairTexture? hairTexture;
  final BeardStyle? beardStyle;

  // Adım 4
  final List<StyleGoal> styleGoals;

  // Meta
  final bool isSaving;
  final String? error;

  const OnboardingState({
    this.step = 0,
    this.heightCm = 175,
    this.weightKg = 75,
    this.bodyType,
    this.shoulderWidth,
    this.torsoLength,
    this.legLength,
    this.skinDepth,
    this.skinUndertone,
    this.faceShape,
    this.eyeColor,
    this.hairColor,
    this.hairLength,
    this.hairTexture,
    this.beardStyle,
    this.styleGoals = const [],
    this.isSaving = false,
    this.error,
  });

  bool get step1Valid =>
      bodyType != null &&
      shoulderWidth != null &&
      torsoLength != null &&
      legLength != null;

  bool get step2Valid => skinDepth != null && skinUndertone != null;

  bool get step3Valid =>
      faceShape != null &&
      eyeColor != null &&
      hairColor != null &&
      hairLength != null &&
      hairTexture != null &&
      beardStyle != null;

  bool get step4Valid => true; // stil tercihleri opsiyonel

  bool get currentStepValid => switch (step) {
        0 => step1Valid,
        1 => step2Valid,
        2 => step3Valid,
        3 => step4Valid,
        _ => true,
      };

  OnboardingState copyWith({
    int? step,
    int? heightCm,
    double? weightKg,
    BodyType? bodyType,
    ShoulderWidth? shoulderWidth,
    TorsoLength? torsoLength,
    LegLength? legLength,
    SkinDepth? skinDepth,
    SkinUndertone? skinUndertone,
    FaceShape? faceShape,
    EyeColor? eyeColor,
    HairColor? hairColor,
    HairLength? hairLength,
    HairTexture? hairTexture,
    BeardStyle? beardStyle,
    List<StyleGoal>? styleGoals,
    bool? isSaving,
    String? error,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyType: bodyType ?? this.bodyType,
      shoulderWidth: shoulderWidth ?? this.shoulderWidth,
      torsoLength: torsoLength ?? this.torsoLength,
      legLength: legLength ?? this.legLength,
      skinDepth: skinDepth ?? this.skinDepth,
      skinUndertone: skinUndertone ?? this.skinUndertone,
      faceShape: faceShape ?? this.faceShape,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
      hairLength: hairLength ?? this.hairLength,
      hairTexture: hairTexture ?? this.hairTexture,
      beardStyle: beardStyle ?? this.beardStyle,
      styleGoals: styleGoals ?? this.styleGoals,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// ── Onboarding Notifier ───────────────────────────────────────────
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  final _repo = CharacterRepository();

  void setStep(int step) => state = state.copyWith(step: step);

  void nextStep() {
    if (state.step < 4) state = state.copyWith(step: state.step + 1);
  }

  void prevStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  // Adım 1
  void setHeight(int cm) => state = state.copyWith(heightCm: cm);
  void setWeight(double kg) => state = state.copyWith(weightKg: kg);
  void setBodyType(BodyType t) => state = state.copyWith(bodyType: t);
  void setShoulderWidth(ShoulderWidth v) =>
      state = state.copyWith(shoulderWidth: v);
  void setTorsoLength(TorsoLength v) => state = state.copyWith(torsoLength: v);
  void setLegLength(LegLength v) => state = state.copyWith(legLength: v);

  // Adım 2
  void setSkinDepth(SkinDepth v) => state = state.copyWith(skinDepth: v);
  void setSkinUndertone(SkinUndertone v) =>
      state = state.copyWith(skinUndertone: v);

  // Adım 3
  void setFaceShape(FaceShape v) => state = state.copyWith(faceShape: v);
  void setEyeColor(EyeColor v) => state = state.copyWith(eyeColor: v);
  void setHairColor(HairColor v) => state = state.copyWith(hairColor: v);
  void setHairLength(HairLength v) => state = state.copyWith(hairLength: v);
  void setHairTexture(HairTexture v) => state = state.copyWith(hairTexture: v);
  void setBeardStyle(BeardStyle v) => state = state.copyWith(beardStyle: v);

  // Adım 4
  void toggleStyleGoal(StyleGoal goal) {
    final current = List<StyleGoal>.from(state.styleGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(styleGoals: current);
  }

  // Kaydet
  Future<bool> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final s = state;
    if (!s.step1Valid || !s.step2Valid || !s.step3Valid) return false;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final now = DateTime.now();
      final profile = CharacterProfile(
        userId: user.uid,
        heightCm: s.heightCm,
        weightKg: s.weightKg,
        bodyType: s.bodyType!,
        shoulderWidth: s.shoulderWidth!,
        torsoLength: s.torsoLength!,
        legLength: s.legLength!,
        skinDepth: s.skinDepth!,
        skinUndertone: s.skinUndertone!,
        faceShape: s.faceShape!,
        eyeColor: s.eyeColor!,
        hairColor: s.hairColor!,
        hairLength: s.hairLength!,
        hairTexture: s.hairTexture!,
        beardStyle: s.beardStyle!,
        styleGoals: s.styleGoals,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.saveProfile(profile);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (_) => OnboardingNotifier(),
);

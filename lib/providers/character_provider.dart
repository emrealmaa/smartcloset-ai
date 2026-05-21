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

// ── Profile Edit State ────────────────────────────────────────────
class ProfileEditState {
  final int heightCm;
  final double weightKg;
  final BodyType bodyType;
  final ShoulderWidth shoulderWidth;
  final TorsoLength torsoLength;
  final LegLength legLength;
  final SkinDepth skinDepth;
  final SkinUndertone skinUndertone;
  final FaceShape faceShape;
  final EyeColor eyeColor;
  final HairColor hairColor;
  final HairLength hairLength;
  final HairTexture hairTexture;
  final BeardStyle beardStyle;
  final List<StyleGoal> styleGoals;
  final DateTime originalCreatedAt;
  final bool isSaving;
  final bool saved;
  final String? error;

  const ProfileEditState({
    required this.heightCm,
    required this.weightKg,
    required this.bodyType,
    required this.shoulderWidth,
    required this.torsoLength,
    required this.legLength,
    required this.skinDepth,
    required this.skinUndertone,
    required this.faceShape,
    required this.eyeColor,
    required this.hairColor,
    required this.hairLength,
    required this.hairTexture,
    required this.beardStyle,
    required this.styleGoals,
    required this.originalCreatedAt,
    this.isSaving = false,
    this.saved = false,
    this.error,
  });

  factory ProfileEditState.fromProfile(CharacterProfile p) => ProfileEditState(
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        bodyType: p.bodyType,
        shoulderWidth: p.shoulderWidth,
        torsoLength: p.torsoLength,
        legLength: p.legLength,
        skinDepth: p.skinDepth,
        skinUndertone: p.skinUndertone,
        faceShape: p.faceShape,
        eyeColor: p.eyeColor,
        hairColor: p.hairColor,
        hairLength: p.hairLength,
        hairTexture: p.hairTexture,
        beardStyle: p.beardStyle,
        styleGoals: p.styleGoals,
        originalCreatedAt: p.createdAt,
      );

  ProfileEditState copyWith({
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
    bool? saved,
    String? error,
  }) =>
      ProfileEditState(
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
        originalCreatedAt: originalCreatedAt,
        isSaving: isSaving ?? this.isSaving,
        saved: saved ?? this.saved,
        error: error,
      );
}

// ── Profile Edit Notifier ─────────────────────────────────────────
class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final CharacterRepository _repo;
  final Ref _ref;

  ProfileEditNotifier(this._repo, this._ref, CharacterProfile initial)
      : super(ProfileEditState.fromProfile(initial));

  void setHeight(int cm) => state = state.copyWith(heightCm: cm);
  void setWeight(double kg) => state = state.copyWith(weightKg: kg);
  void setBodyType(BodyType v) => state = state.copyWith(bodyType: v);
  void setShoulderWidth(ShoulderWidth v) =>
      state = state.copyWith(shoulderWidth: v);
  void setTorsoLength(TorsoLength v) => state = state.copyWith(torsoLength: v);
  void setLegLength(LegLength v) => state = state.copyWith(legLength: v);
  void setSkinDepth(SkinDepth v) => state = state.copyWith(skinDepth: v);
  void setSkinUndertone(SkinUndertone v) =>
      state = state.copyWith(skinUndertone: v);
  void setFaceShape(FaceShape v) => state = state.copyWith(faceShape: v);
  void setEyeColor(EyeColor v) => state = state.copyWith(eyeColor: v);
  void setHairColor(HairColor v) => state = state.copyWith(hairColor: v);
  void setHairLength(HairLength v) => state = state.copyWith(hairLength: v);
  void setHairTexture(HairTexture v) => state = state.copyWith(hairTexture: v);
  void setBeardStyle(BeardStyle v) => state = state.copyWith(beardStyle: v);

  void toggleStyleGoal(StyleGoal goal) {
    final current = List<StyleGoal>.from(state.styleGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(styleGoals: current);
  }

  Future<bool> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    state = state.copyWith(isSaving: true, error: null);
    try {
      final s = state;
      final profile = CharacterProfile(
        userId: user.uid,
        heightCm: s.heightCm,
        weightKg: s.weightKg,
        bodyType: s.bodyType,
        shoulderWidth: s.shoulderWidth,
        torsoLength: s.torsoLength,
        legLength: s.legLength,
        skinDepth: s.skinDepth,
        skinUndertone: s.skinUndertone,
        faceShape: s.faceShape,
        eyeColor: s.eyeColor,
        hairColor: s.hairColor,
        hairLength: s.hairLength,
        hairTexture: s.hairTexture,
        beardStyle: s.beardStyle,
        styleGoals: s.styleGoals,
        createdAt: s.originalCreatedAt,
        updatedAt: DateTime.now(),
      );
      await _repo.saveProfile(profile);
      _ref.invalidate(characterProfileProvider);
      state = state.copyWith(isSaving: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final profileEditProvider = StateNotifierProvider.autoDispose<
    ProfileEditNotifier, ProfileEditState>(
  (ref) {
    final repo = ref.read(characterRepositoryProvider);
    final profile = ref.read(characterProfileProvider).value!;
    return ProfileEditNotifier(repo, ref, profile);
  },
);

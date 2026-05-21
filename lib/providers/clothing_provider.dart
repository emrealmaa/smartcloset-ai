import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/enums/clothing_enums.dart';
import '../core/utils/color_utils.dart';
import '../models/clothing_item.dart';
import '../data/repositories/clothing_repository.dart';

// ── Repository ────────────────────────────────────────────────────
final clothingRepositoryProvider = Provider<ClothingRepository>(
  (_) => ClothingRepository(),
);

// ── Tüm kıyafet listesi ───────────────────────────────────────────
final clothingListProvider = FutureProvider<List<ClothingItem>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  return ref.read(clothingRepositoryProvider).getAll(user.uid);
});

// ── Kategoriye göre filtreli liste ───────────────────────────────
final clothingByCategoryProvider =
    FutureProvider.family<List<ClothingItem>, ClothingCategory?>(
        (ref, category) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  final repo = ref.read(clothingRepositoryProvider);
  if (category == null) return repo.getAll(user.uid);
  return repo.getByCategory(user.uid, category);
});

// ── Toplam sayı ───────────────────────────────────────────────────
final clothingCountProvider = FutureProvider<int>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;
  return ref.read(clothingRepositoryProvider).count(user.uid);
});

// ── Add Clothing State ────────────────────────────────────────────
class AddClothingState {
  final String name;
  final String? brand;
  final ClothingCategory? category;
  final ClothingSubcategory? subcategory;

  final String? primaryColorHex;
  final String? primaryColorName;

  final FitType fitType;
  final LengthType? lengthType;
  final FabricType fabricType;
  final FabricWeight fabricWeight;
  final PatternType patternType;
  final PatternScale? patternScale;

  final List<OccasionTag> occasionTags;
  final List<SeasonTag> seasonTags;

  final ClothingCondition condition;
  final String? imagePath;
  final String? notes;

  final bool isSaving;
  final String? error;

  const AddClothingState({
    this.name = '',
    this.brand,
    this.category,
    this.subcategory,
    this.primaryColorHex,
    this.primaryColorName,
    this.fitType = FitType.regular,
    this.lengthType,
    this.fabricType = FabricType.cotton,
    this.fabricWeight = FabricWeight.medium,
    this.patternType = PatternType.solid,
    this.patternScale,
    this.occasionTags = const [],
    this.seasonTags = const [],
    this.condition = ClothingCondition.good,
    this.imagePath,
    this.notes,
    this.isSaving = false,
    this.error,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      category != null &&
      subcategory != null &&
      primaryColorHex != null;

  AddClothingState copyWith({
    String? name,
    String? brand,
    ClothingCategory? category,
    ClothingSubcategory? subcategory,
    String? primaryColorHex,
    String? primaryColorName,
    FitType? fitType,
    LengthType? lengthType,
    FabricType? fabricType,
    FabricWeight? fabricWeight,
    PatternType? patternType,
    PatternScale? patternScale,
    List<OccasionTag>? occasionTags,
    List<SeasonTag>? seasonTags,
    ClothingCondition? condition,
    String? imagePath,
    String? notes,
    bool? isSaving,
    String? error,
  }) {
    return AddClothingState(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      primaryColorName: primaryColorName ?? this.primaryColorName,
      fitType: fitType ?? this.fitType,
      lengthType: lengthType ?? this.lengthType,
      fabricType: fabricType ?? this.fabricType,
      fabricWeight: fabricWeight ?? this.fabricWeight,
      patternType: patternType ?? this.patternType,
      patternScale: patternScale ?? this.patternScale,
      occasionTags: occasionTags ?? this.occasionTags,
      seasonTags: seasonTags ?? this.seasonTags,
      condition: condition ?? this.condition,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// ── Add Clothing Notifier ─────────────────────────────────────────
class AddClothingNotifier extends StateNotifier<AddClothingState> {
  AddClothingNotifier() : super(const AddClothingState());

  final _repo = ClothingRepository();

  void setName(String v) => state = state.copyWith(name: v);
  void setBrand(String? v) => state = state.copyWith(brand: v);

  void setCategory(ClothingCategory v) =>
      state = state.copyWith(category: v, subcategory: null);

  void setSubcategory(ClothingSubcategory v) =>
      state = state.copyWith(subcategory: v);

  void setColor(String hex, String name) =>
      state = state.copyWith(primaryColorHex: hex, primaryColorName: name);

  void setFitType(FitType v) => state = state.copyWith(fitType: v);
  void setLengthType(LengthType? v) => state = state.copyWith(lengthType: v);
  void setFabricType(FabricType v) => state = state.copyWith(fabricType: v);
  void setFabricWeight(FabricWeight v) =>
      state = state.copyWith(fabricWeight: v);

  void setPatternType(PatternType v) => state = state.copyWith(
        patternType: v,
        patternScale: v == PatternType.solid ? null : state.patternScale,
      );

  void setPatternScale(PatternScale? v) =>
      state = state.copyWith(patternScale: v);

  void toggleOccasionTag(OccasionTag tag) {
    final list = List<OccasionTag>.from(state.occasionTags);
    list.contains(tag) ? list.remove(tag) : list.add(tag);
    state = state.copyWith(occasionTags: list);
  }

  void toggleSeasonTag(SeasonTag tag) {
    final list = List<SeasonTag>.from(state.seasonTags);
    list.contains(tag) ? list.remove(tag) : list.add(tag);
    state = state.copyWith(seasonTags: list);
  }

  void setCondition(ClothingCondition v) =>
      state = state.copyWith(condition: v);
  void setImagePath(String? v) => state = state.copyWith(imagePath: v);
  void setNotes(String? v) => state = state.copyWith(notes: v);

  Future<bool> save(void Function() onInvalidate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !state.isValid) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      final hex = state.primaryColorHex!;
      final now = DateTime.now();
      final item = ClothingItem(
        userId: user.uid,
        name: state.name.trim(),
        brand: (state.brand?.trim().isEmpty ?? true) ? null : state.brand,
        category: state.category!,
        subcategory: state.subcategory!,
        primaryColorHex: hex,
        primaryColorName: state.primaryColorName ?? hex,
        colorFamily: ColorUtils.computeFamily(hex),
        colorSaturation: ColorUtils.computeSaturation(hex),
        colorValue: ColorUtils.computeValue(hex),
        fitType: state.fitType,
        lengthType: state.lengthType,
        fabricType: state.fabricType,
        fabricWeight: state.fabricWeight,
        patternType: state.patternType,
        patternScale: state.patternScale,
        occasionTags: state.occasionTags,
        seasonTags: state.seasonTags,
        condition: state.condition,
        imagePath: state.imagePath,
        notes: state.notes,
        createdAt: now,
        updatedAt: now,
      );
      await _repo.add(item);
      onInvalidate(); // provider'ları yenile
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const AddClothingState();
}

final addClothingProvider =
    StateNotifierProvider.autoDispose<AddClothingNotifier, AddClothingState>(
  (_) => AddClothingNotifier(),
);

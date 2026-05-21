import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/engine/gap_analyzer.dart';
import '../domain/engine/outfit_builder.dart';
import '../models/outfit_suggestion.dart';
import '../models/wardrobe_gap.dart';
import 'character_provider.dart';
import 'clothing_provider.dart';

/// Kombin önerileri — karakter + gardırop birleşimi
final outfitSuggestionsProvider =
    FutureProvider<List<OutfitSuggestion>>((ref) async {
  final profile = ref.watch(characterProfileProvider).value;
  final clothing = ref.watch(clothingListProvider).value;

  if (profile == null || clothing == null || clothing.isEmpty) return [];

  // Compute engine'i isolate'e taşımak gerekmez (küçük veri setleri için OK)
  return OutfitBuilder.build(wardrobe: clothing, character: profile);
});

/// Gardırop eksik parça analizi
final wardrobeGapsProvider = FutureProvider<List<WardrobeGap>>((ref) async {
  final profile = ref.watch(characterProfileProvider).value;
  final clothing = ref.watch(clothingListProvider).value ?? [];

  if (profile == null) return [];
  return GapAnalyzer.analyze(clothing, profile);
});

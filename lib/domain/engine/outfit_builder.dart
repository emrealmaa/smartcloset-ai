import '../../core/enums/clothing_enums.dart';
import '../../models/character_profile.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit_suggestion.dart';
import 'body_fit_engine.dart';
import 'color_harmony_engine.dart';
import 'explanation_generator.dart';

class OutfitBuilder {
  static const int _minColorScore = 40;
  static const int _maxResults = 25;

  static List<OutfitSuggestion> build({
    required List<ClothingItem> wardrobe,
    required CharacterProfile character,
  }) {
    final rules = BodyFitEngine.computeRules(character.bodyType);
    final undertone = character.skinUndertone;

    // Aktif parçaları kategoriye göre ayır
    final tops = wardrobe
        .where((i) =>
            i.category == ClothingCategory.top &&
            BodyFitEngine.topPassesRules(rules, i))
        .toList();

    final bottoms = wardrobe
        .where((i) =>
            i.category == ClothingCategory.bottom &&
            BodyFitEngine.bottomPassesRules(rules, i))
        .toList();

    final outerwears = wardrobe
        .where((i) => i.category == ClothingCategory.outerwear)
        .toList();

    final suggestions = <OutfitSuggestion>[];

    for (final top in tops) {
      for (final bottom in bottoms) {
        // Desen uyumu kontrolü
        if (!ColorHarmonyEngine.passesPatternRule(top, bottom)) continue;

        // Renk uyum skoru
        final colorScore =
            ColorHarmonyEngine.scorePairing(top, bottom, undertone);
        if (colorScore < _minColorScore) continue;

        // Proporsiyon bonusu
        final bonus =
            BodyFitEngine.proportionBonus(rules, top, bottom);

        final totalScore = (colorScore + bonus).clamp(0, 100);

        // Çok yönlülük skoru — ortak occasion tag sayısına göre
        final versatility = _computeVersatility(top, bottom);

        // Açıklamalar üret
        final explanations = ExplanationGenerator.generate(
          top: top,
          bottom: bottom,
          undertone: undertone,
          bodyType: character.bodyType,
          colorScore: colorScore,
        );

        suggestions.add(OutfitSuggestion(
          items: [top, bottom],
          harmonyScore: totalScore,
          versatilityScore: versatility,
          explanations: explanations,
        ));
      }
    }

    // Skora göre sırala
    suggestions.sort((a, b) => b.harmonyScore.compareTo(a.harmonyScore));

    // Tekrar eden üst/alt çiftlerini kaldır (ilk görünenden sonra gösterme)
    final seen = <String>{};
    final deduplicated = suggestions.where((s) {
      final key = '${s.top.id}_${s.bottom.id}';
      return seen.add(key);
    }).toList();

    // En iyi N kombinasyona dış giyim ekle (varsa)
    return _addOuterwear(
        deduplicated.take(_maxResults).toList(), outerwears, character);
  }

  static int _computeVersatility(ClothingItem top, ClothingItem bottom) {
    final topOccasions = top.occasionTags.toSet();
    final bottomOccasions = bottom.occasionTags.toSet();
    final shared = topOccasions.intersection(bottomOccasions).length;

    // 0 ortak tag → 20, 1 → 40, 2 → 60, 3+ → 80–100
    if (shared == 0) return 20;
    if (shared == 1) return 45;
    if (shared == 2) return 65;
    return 85;
  }

  static List<OutfitSuggestion> _addOuterwear(
    List<OutfitSuggestion> suggestions,
    List<ClothingItem> outerwears,
    CharacterProfile character,
  ) {
    if (outerwears.isEmpty) return suggestions;

    return suggestions.map((s) {
      // Her kombine renk uyumlu bir dış giyim bulmaya çalış
      final compatible = outerwears.where((ow) {
        final scoreWithTop = ColorHarmonyEngine.scorePairing(
            ow, s.top, character.skinUndertone);
        return scoreWithTop >= 35;
      }).toList();

      if (compatible.isEmpty) return s;

      // En uyumlu dış giysimi seç
      compatible.sort((a, b) {
        final sa = ColorHarmonyEngine.scorePairing(
            a, s.top, character.skinUndertone);
        final sb = ColorHarmonyEngine.scorePairing(
            b, s.top, character.skinUndertone);
        return sb.compareTo(sa);
      });

      final ow = compatible.first;
      final layeringExp =
          ExplanationGenerator.generate(
        top: s.top,
        bottom: s.bottom,
        undertone: character.skinUndertone,
        bodyType: character.bodyType,
        colorScore: s.harmonyScore,
        outerwear: ow,
      );

      return OutfitSuggestion(
        items: [s.top, s.bottom, ow],
        harmonyScore: s.harmonyScore,
        versatilityScore: s.versatilityScore,
        explanations: layeringExp,
        occasion: s.occasion,
      );
    }).toList();
  }
}

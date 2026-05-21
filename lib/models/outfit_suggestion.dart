import 'clothing_item.dart';
import 'style_explanation.dart';

class OutfitSuggestion {
  final List<ClothingItem> items;      // [top, bottom, ?outerwear]
  final int harmonyScore;             // 0–100 renk/proporsiyon uyumu
  final int versatilityScore;         // 0–100 kaç ortama uyar
  final List<StyleExplanation> explanations;
  final String? occasion;             // 'casual' | 'work' | ...

  const OutfitSuggestion({
    required this.items,
    required this.harmonyScore,
    required this.versatilityScore,
    required this.explanations,
    this.occasion,
  });

  ClothingItem get top => items.first;
  ClothingItem get bottom => items[1];
  ClothingItem? get outerwear => items.length > 2 ? items[2] : null;
}

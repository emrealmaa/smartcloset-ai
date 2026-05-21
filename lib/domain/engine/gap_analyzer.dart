import '../../core/enums/clothing_enums.dart';
import '../../models/character_profile.dart';
import '../../models/clothing_item.dart';
import '../../models/wardrobe_gap.dart';

class GapAnalyzer {
  static List<WardrobeGap> analyze(
    List<ClothingItem> wardrobe,
    CharacterProfile character,
  ) {
    final gaps = <WardrobeGap>[];

    // ── 1. Nötr Alt Kontrolü ─────────────────────────────────
    final neutralBottoms = wardrobe.where((i) =>
        i.category == ClothingCategory.bottom &&
        (i.colorFamily == ColorFamily.achromatic ||
            i.colorFamily == ColorFamily.neutral ||
            i.colorFamily == ColorFamily.earth));

    if (neutralBottoms.length < 2) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Nötr Pantolon / Chino',
        colorSuggestion: 'Lacivert, gri veya bej',
        priority: 1,
        reason:
            'Gardırobunda 2\'den az nötr alt var. Nötr altlar, '
            'mevcut üstlerinizin %70\'iyle kombin yapmanı sağlayan '
            'temel çapa parçalardır.',
        tip: 'Slim veya regular fit lacivert chino ekle.',
      ));
    }

    // ── 2. Beyaz / Açık Renk Üst Kontrolü ───────────────────
    final lightTops = wardrobe.where((i) =>
        i.category == ClothingCategory.top &&
        i.colorValue == ColorValue.light);

    if (lightTops.isEmpty) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Açık Renk Üst (Gömlek / T-Shirt)',
        colorSuggestion: 'Beyaz, kırık beyaz veya açık gri',
        priority: 1,
        reason:
            'Açık renkli bir üst yok. Beyaz veya kırık beyaz üstler, '
            'her türlü alt ile kombinlenebilen evrensel parçalardır.',
        tip: 'Slim ya da regular fit beyaz Oxford gömlek ideal başlangıç noktası.',
      ));
    }

    // ── 3. Dış Giyim Kontrolü ────────────────────────────────
    final outerwears =
        wardrobe.where((i) => i.category == ClothingCategory.outerwear);

    if (outerwears.isEmpty) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Temel Dış Giyim',
        colorSuggestion: 'Lacivert blazer veya koyu ceket',
        priority: 2,
        reason:
            'Hiç dış giyim yok. Bir blazer veya ceket, casual kombinleri '
            'smart casual seviyesine taşıyan en pratik yatırımdır.',
        tip: 'Lacivert slim fit blazer neredeyse her kombinle çalışır.',
      ));
    }

    // ── 4. Ayakkabı Çeşitliliği ──────────────────────────────
    final shoes = wardrobe.where((i) => i.category == ClothingCategory.shoes);

    if (shoes.isEmpty) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Temel Ayakkabı',
        colorSuggestion: 'Beyaz sneaker veya koyu loafer',
        priority: 2,
        reason:
            'Gardırobunda hiç ayakkabı kaydı yok. '
            'Kombin önerileri ayakkabıyla tamamlandığında çok daha '
            'doğru bir değerlendirme sunar.',
        tip: 'Beyaz sneaker en çok yönlü başlangıç seçeneğidir.',
      ));
    }

    // ── 5. Mevsimsel Açık ────────────────────────────────────
    final hasSummerTop = wardrobe.any((i) =>
        i.category == ClothingCategory.top &&
        i.seasonTags.contains(SeasonTag.summer));

    if (!hasSummerTop) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Yazlık Üst',
        colorSuggestion: 'Hafif kumaş, açık renk',
        priority: 3,
        reason:
            'Yaz mevsimi için uygun üst yok. Keten veya pamuklu hafif '
            'üstler sıcak hava kombinlerini mümkün kılar.',
        tip: 'Keten gömlek hem şık hem serin tutar.',
      ));
    }

    // ── 6. Desen Çeşitliliği ─────────────────────────────────
    final patterned = wardrobe.where(
        (i) => i.patternType != PatternType.solid);

    if (patterned.isEmpty && wardrobe.length >= 5) {
      gaps.add(const WardrobeGap(
        subcategoryLabel: 'Desenli Parça',
        colorSuggestion: 'İnce çizgili gömlek veya ekose',
        priority: 3,
        reason:
            'Tüm parçalar solid renk. En az bir desenli parça gardıroba '
            'görsel çeşitlilik ve karakter katar.',
        tip: 'İnce çizgili gömlek solid altlarla mükemmel eşleşir.',
      ));
    }

    // Önceliğe göre sırala
    gaps.sort((a, b) => a.priority.compareTo(b.priority));
    return gaps;
  }
}

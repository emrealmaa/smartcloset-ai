import '../../core/enums/clothing_enums.dart';
import '../../core/enums/skin_enums.dart';
import '../../models/clothing_item.dart';

class ColorHarmonyEngine {
  // Cilt alt tonu → uyumlu renk aileleri
  static const Map<SkinUndertone, List<ColorFamily>> _undertoneMap = {
    SkinUndertone.warm: [
      ColorFamily.earth,
      ColorFamily.warm,
      ColorFamily.achromatic,
    ],
    SkinUndertone.cool: [
      ColorFamily.cool,
      ColorFamily.achromatic,
      ColorFamily.neutral,
    ],
    SkinUndertone.neutral: [
      ColorFamily.earth,
      ColorFamily.warm,
      ColorFamily.cool,
      ColorFamily.neutral,
      ColorFamily.achromatic,
    ],
  };

  // Tonal aile uyumluluk matrisi
  static bool _areTonallyCompatible(ColorFamily a, ColorFamily b) {
    if (a == b) return true;
    if (a == ColorFamily.achromatic || b == ColorFamily.achromatic) return true;
    if (a == ColorFamily.neutral || b == ColorFamily.neutral) return true;
    if ({a, b} == {ColorFamily.warm, ColorFamily.earth}) return true;
    if ({a, b} == {ColorFamily.cool, ColorFamily.neutral}) return true;
    // warm + cool genellikle çarpışır
    if ({a, b} == {ColorFamily.warm, ColorFamily.cool}) return false;
    if ({a, b} == {ColorFamily.earth, ColorFamily.cool}) return false;
    return true;
  }

  /// İki kıyafet arasındaki renk uyum skoru (0–100)
  static int scorePairing(
    ClothingItem a,
    ClothingItem b,
    SkinUndertone undertone,
  ) {
    int score = 0;

    final compatible = _undertoneMap[undertone]!;

    // Kural 1: Cilt tonuyla uyum (+40)
    if (compatible.contains(a.colorFamily)) score += 20;
    if (compatible.contains(b.colorFamily)) score += 20;

    // Kural 2: Koyu-açık değer zıtlığı (+20)
    if (a.colorValue != b.colorValue) score += 20;

    // Kural 3: İki parça da vibrant → ceza (-15)
    if (a.colorSaturation == ColorSaturation.vibrant &&
        b.colorSaturation == ColorSaturation.vibrant) {
      score -= 15;
    }

    // Kural 4: Tonal aile uyumu (+20)
    if (_areTonallyCompatible(a.colorFamily, b.colorFamily)) score += 20;

    return score.clamp(0, 100);
  }

  /// Desen uyum kontrolü — ikisi desenli ise farklı ölçek gerekli
  static bool passesPatternRule(ClothingItem top, ClothingItem bottom) {
    final topHasPattern = top.patternType != PatternType.solid;
    final bottomHasPattern = bottom.patternType != PatternType.solid;

    if (topHasPattern && bottomHasPattern) {
      // İki farklı desen → ancak farklı ölçekte kabul
      if (top.patternScale == null || bottom.patternScale == null) return false;
      return top.patternScale != bottom.patternScale;
    }
    return true;
  }

  /// Monoton-renk (monochrome) kombinasyonu mu?
  static bool isMonochrome(ClothingItem a, ClothingItem b) {
    return a.colorFamily == b.colorFamily &&
        a.colorSaturation != ColorSaturation.vibrant;
  }
}

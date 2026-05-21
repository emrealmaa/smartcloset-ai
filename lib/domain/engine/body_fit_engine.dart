import '../../core/enums/body_enums.dart';
import '../../core/enums/clothing_enums.dart';
import '../../models/body_fit_rules.dart';
import '../../models/clothing_item.dart';
import 'color_harmony_engine.dart';

class BodyFitEngine {
  static BodyFitRules computeRules(BodyType type) {
    return switch (type) {
      BodyType.invertedTriangle => const BodyFitRules(
          bodyType: BodyType.invertedTriangle,
          goodTopFits: [FitType.regular, FitType.relaxed],
          avoidTopFits: [FitType.oversized],
          goodBottomFits: [FitType.regular, FitType.slim],
          avoidBottomFits: [],
          avoidPatternOnTop: [PatternType.stripes],
          preferPatternOnBottom: true,
        ),

      BodyType.triangle => const BodyFitRules(
          bodyType: BodyType.triangle,
          goodTopFits: [FitType.oversized, FitType.relaxed],
          avoidTopFits: [FitType.slim],
          goodBottomFits: [FitType.relaxed, FitType.regular],
          avoidBottomFits: [FitType.slim],
          preferPatternOnTop: true,
          preferDarkBottoms: true,
        ),

      BodyType.rectangle => const BodyFitRules(
          bodyType: BodyType.rectangle,
          goodTopFits: [FitType.regular, FitType.slim, FitType.relaxed],
          avoidTopFits: [],
          goodBottomFits: [FitType.regular, FitType.slim],
          avoidBottomFits: [],
          preferContrastLayers: true,
        ),

      BodyType.oval => const BodyFitRules(
          bodyType: BodyType.oval,
          goodTopFits: [FitType.regular],
          avoidTopFits: [FitType.slim, FitType.oversized],
          goodBottomFits: [FitType.regular, FitType.slim],
          avoidBottomFits: [FitType.oversized],
          avoidPatternOnTop: [PatternType.stripes, PatternType.plaid],
          preferVerticalLines: true,
          preferMonochrome: true,
          preferDarkBottoms: true,
        ),

      BodyType.athletic => const BodyFitRules(
          bodyType: BodyType.athletic,
          goodTopFits: [FitType.slim, FitType.regular],
          avoidTopFits: [],
          goodBottomFits: [FitType.slim, FitType.regular],
          avoidBottomFits: [],
        ),
    };
  }

  static bool topPassesRules(BodyFitRules rules, ClothingItem item) {
    if (rules.avoidTopFits.contains(item.fitType)) return false;
    if (rules.goodTopFits.isNotEmpty &&
        !rules.goodTopFits.contains(item.fitType)) return false;
    if (rules.avoidPatternOnTop.contains(item.patternType)) return false;
    return true;
  }

  static bool bottomPassesRules(BodyFitRules rules, ClothingItem item) {
    if (rules.avoidBottomFits.contains(item.fitType)) return false;
    return true;
  }

  /// Vücut tipine özgü proporsiyon bonusu (0–20)
  static int proportionBonus(
    BodyFitRules rules,
    ClothingItem top,
    ClothingItem bottom,
  ) {
    int bonus = 0;
    if (rules.preferDarkBottoms && bottom.colorValue == ColorValue.dark) {
      bonus += 10;
    }
    if (rules.preferPatternOnTop && top.patternType != PatternType.solid) {
      bonus += 10;
    }
    if (rules.preferPatternOnBottom && bottom.patternType != PatternType.solid) {
      bonus += 10;
    }
    if (rules.preferMonochrome && ColorHarmonyEngine.isMonochrome(top, bottom)) {
      bonus += 10;
    }
    return bonus.clamp(0, 20);
  }
}

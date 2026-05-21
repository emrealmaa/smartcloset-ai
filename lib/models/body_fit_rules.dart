import '../core/enums/body_enums.dart';
import '../core/enums/clothing_enums.dart';

class BodyFitRules {
  final BodyType bodyType;

  // Üst için
  final List<FitType> goodTopFits;
  final List<FitType> avoidTopFits;

  // Alt için
  final List<FitType> goodBottomFits;
  final List<FitType> avoidBottomFits;

  // Desen tercihleri
  final bool preferPatternOnTop;   // üste desen çek → alt vurgu kır
  final bool preferPatternOnBottom;
  final List<PatternType> avoidPatternOnTop;

  // Renk tercihleri
  final bool preferDarkBottoms;    // oval/üçgen için alt koyu
  final bool preferMonochrome;     // oval için tek renk uzatır
  final bool preferVerticalLines;  // oval için dikey çizgi
  final bool preferContrastLayers; // dikdörtgen için katman zıtlığı

  const BodyFitRules({
    required this.bodyType,
    required this.goodTopFits,
    required this.avoidTopFits,
    required this.goodBottomFits,
    required this.avoidBottomFits,
    this.preferPatternOnTop = false,
    this.preferPatternOnBottom = false,
    this.avoidPatternOnTop = const [],
    this.preferDarkBottoms = false,
    this.preferMonochrome = false,
    this.preferVerticalLines = false,
    this.preferContrastLayers = false,
  });
}

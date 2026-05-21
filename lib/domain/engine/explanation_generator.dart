import 'package:flutter/material.dart';
import '../../core/enums/body_enums.dart';
import '../../core/enums/clothing_enums.dart';
import '../../core/enums/skin_enums.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit_suggestion.dart';
import '../../models/style_explanation.dart';

class ExplanationGenerator {
  static List<StyleExplanation> generate({
    required ClothingItem top,
    required ClothingItem bottom,
    required SkinUndertone undertone,
    required BodyType bodyType,
    required int colorScore,
    ClothingItem? outerwear,
  }) {
    final explanations = <StyleExplanation>[];

    // ── Renk & Cilt Tonu ──────────────────────────────────────
    final colorExp = _colorUndertoneExplanation(top, bottom, undertone);
    if (colorExp != null) explanations.add(colorExp);

    // ── Kalıp & Vücut Tipi ────────────────────────────────────
    final fitExp = _fitBodyExplanation(top, bodyType);
    if (fitExp != null) explanations.add(fitExp);

    // ── Renk Değeri Zıtlığı ───────────────────────────────────
    final valueExp = _colorValueExplanation(top, bottom);
    if (valueExp != null) explanations.add(valueExp);

    // ── Desen Dengesi ─────────────────────────────────────────
    final patternExp = _patternExplanation(top, bottom);
    if (patternExp != null) explanations.add(patternExp);

    // ── Dış Giyim Katmanı ─────────────────────────────────────
    if (outerwear != null) {
      explanations.add(_layeringExplanation(outerwear));
    }

    return explanations;
  }

  // ── Renk & Cilt Tonu Açıklaması ─────────────────────────────
  static StyleExplanation? _colorUndertoneExplanation(
    ClothingItem top,
    ClothingItem bottom,
    SkinUndertone undertone,
  ) {
    final compatible = _compatibleFamilies(undertone);
    final topOk = compatible.contains(top.colorFamily);
    final bottomOk = compatible.contains(bottom.colorFamily);

    if (!topOk && !bottomOk) return null;

    final undertoneLabel = undertone.label.toLowerCase();
    String body;

    if (topOk && bottomOk) {
      body =
          '${top.primaryColorName} ve ${bottom.primaryColorName} renkleri, '
          '$undertoneLabel cilt alt tonunla uyumlu. '
          '${_undertoneColorReason(undertone)}';
    } else if (topOk) {
      body =
          '${top.primaryColorName}, $undertoneLabel cilt alt tonunla uyumlu. '
          '${_undertoneColorReason(undertone)} '
          'Alt renk ise nötr konumda dengeleme görevi üstleniyor.';
    } else {
      body =
          '${bottom.primaryColorName}, $undertoneLabel cilt alt tonunla uyumlu. '
          'Üst parça nötr tonuyla renk dengesini koruyor.';
    }

    return StyleExplanation(
      rule: 'color_undertone_match',
      title: 'Renk & Cilt Tonu',
      body: body,
      icon: Icons.palette_outlined,
    );
  }

  static String _undertoneColorReason(SkinUndertone undertone) {
    return switch (undertone) {
      SkinUndertone.warm =>
        'Sıcak alt tonlar; camel, hardal, terrakota ve zeytin yeşili gibi '
            'toprak tonlarıyla canlı ve sağlıklı görünür.',
      SkinUndertone.cool =>
        'Soğuk alt tonlar; lacivert, bordo, slate ve orman yeşili gibi '
            'jewel tone renklerle parlak bir görünüm yakalar.',
      SkinUndertone.neutral =>
        'Nötr alt ton hem sıcak hem soğuk aile renklerini taşıyabilir; '
            'bu durum geniş bir renk yelpazesi sunar.',
    };
  }

  static List<ColorFamily> _compatibleFamilies(SkinUndertone undertone) {
    return switch (undertone) {
      SkinUndertone.warm => [
          ColorFamily.earth,
          ColorFamily.warm,
          ColorFamily.achromatic
        ],
      SkinUndertone.cool => [
          ColorFamily.cool,
          ColorFamily.achromatic,
          ColorFamily.neutral
        ],
      SkinUndertone.neutral => ColorFamily.values,
    };
  }

  // ── Kalıp & Vücut Tipi ───────────────────────────────────────
  static StyleExplanation? _fitBodyExplanation(
      ClothingItem top, BodyType bodyType) {
    final String body = switch (bodyType) {
      BodyType.invertedTriangle => switch (top.fitType) {
          FitType.regular =>
            'Regular kesim, geniş omuzlarını daha dar göstererek '
                'vücudun V şeklini dengeler. Göz, vücudun tamamına yayılır.',
          FitType.relaxed =>
            'Relaxed kesim, omuz-kalça dengesini yumuşatarak '
                'ters üçgen silueti daha orantılı gösterir.',
          FitType.slim =>
            'Slim kesim omuzları görsel olarak vurgulamakla birlikte '
                'bel hattını belirgin kılar ve orantılı bir görünüm sunar.',
          FitType.oversized =>
            'Oversized kesim omuzları daha da genişletebilir; '
                'dikkatli renk seçimiyle bu etki minimize edilmiştir.',
        },
      BodyType.triangle => switch (top.fitType) {
          FitType.oversized =>
            'Oversized kesim, üst gövdeyi görsel olarak büyüterek '
                'omuz-kalça dengesini kurar. Dikkat çekiciyi yukarıya taşır.',
          FitType.relaxed =>
            'Relaxed kesim, üst vücudu biraz hacimlendirir ve '
                'omuz genişliğini kalçaya oranla dengeye getirir.',
          _ =>
            'Bu kesim, omuz bölgesini görsel olarak öne çıkararak '
                'üçgen vücut tipinde denge sağlar.',
        },
      BodyType.rectangle =>
        'Bu kombinasyon, katman ve renk zıtlığı sayesinde '
            'dikdörtgen vücut tipinde görsel derinlik ve bel tanımı oluşturur.',
      BodyType.oval => switch (top.fitType) {
          FitType.regular =>
            'Regular kesim, bel bölgesini vurgulamadan düşey bir '
                'hat oluşturur. Oval vücut tipinde uzatıcı etki yaratır.',
          _ =>
            'Bu kesim, vücudu dikey hatlarla uzatır ve '
                'bel bölgesini öne çıkarmadan orantılı görünüm sunar.',
        },
      BodyType.athletic =>
        '${top.fitType.label} kesim, atletik vücut tipinin '
            'orantılı yapısını ön plana çıkarır. Kaslı hatları dengeli gösterir.',
    };

    return StyleExplanation(
      rule: 'fit_body_match',
      title: 'Kalıp & Vücut Tipi',
      body: body,
      icon: Icons.straighten,
    );
  }

  // ── Renk Değeri Zıtlığı ─────────────────────────────────────
  static StyleExplanation? _colorValueExplanation(
      ClothingItem top, ClothingItem bottom) {
    if (top.colorValue == bottom.colorValue) return null;

    final topLabel =
        top.colorValue == ColorValue.dark ? 'Koyu' : 'Açık';
    final bottomLabel =
        bottom.colorValue == ColorValue.dark ? 'koyu' : 'açık';

    return StyleExplanation(
      rule: 'color_value_contrast',
      title: 'Ton Zıtlığı',
      body: '$topLabel üst + $bottomLabel alt kombinasyonu, görsel '
          'derinlik ve dinamizm yaratıyor. Ton değeri zıtlığı, kıyafete '
          'boyut kazandıran en klasik renk dengeleme tekniklerinden biri.',
      icon: Icons.contrast,
    );
  }

  // ── Desen Dengesi ────────────────────────────────────────────
  static StyleExplanation? _patternExplanation(
      ClothingItem top, ClothingItem bottom) {
    final topHasPattern = top.patternType != PatternType.solid;
    final bottomHasPattern = bottom.patternType != PatternType.solid;

    if (!topHasPattern && !bottomHasPattern) return null;

    String body;
    if (topHasPattern && !bottomHasPattern) {
      body =
          '${top.patternType.label} desenli üst, düz (solid) bir alt ile '
          'dengeleniyor. Bu kural gözü desenli parçaya odaklar ve '
          'kıyafeti okunabilir kılar — iki desenin çakışması önlenir.';
    } else if (!topHasPattern && bottomHasPattern) {
      body =
          'Düz üst, ${bottom.patternType.label} desenli alt ile '
          'eşleşiyor. Desen dikkatini bel altına taşır ve üst '
          'gövdeyi nötr tutarak dengeli bir görünüm oluşturur.';
    } else {
      // İkisi de desenli — farklı ölçek sayesinde geçti
      body =
          'İki desenli parça, farklı ölçeklerde seçilerek çakışma önlendi. '
          '${top.patternScale != null ? top.patternScale!.name.toUpperCase() : ""} '
          'ölçekli üst ve '
          '${bottom.patternScale != null ? bottom.patternScale!.name.toUpperCase() : ""} '
          'ölçekli alt görsel hiyerarşi kurar.';
    }

    return StyleExplanation(
      rule: 'pattern_balance',
      title: 'Desen Dengesi',
      body: body,
      icon: Icons.pattern,
    );
  }

  // ── Katman Açıklaması ────────────────────────────────────────
  static StyleExplanation _layeringExplanation(ClothingItem outerwear) {
    return StyleExplanation(
      rule: 'layering',
      title: 'Katmanlama',
      body:
          '${outerwear.name} eklendiğinde kombin daha yapılandırılmış bir '
          'görünüm kazanıyor. Katmanlama; mevsim geçişlerinde hem işlevsel '
          'hem de görsel derinlik sunar. Dış giyim, bütünün çerçevesini oluşturur.',
      icon: Icons.layers_outlined,
    );
  }

  static List<StyleExplanation> generateForSuggestion(
          OutfitSuggestion s,
          SkinUndertone undertone,
          BodyType bodyType) =>
      generate(
        top: s.top,
        bottom: s.bottom,
        undertone: undertone,
        bodyType: bodyType,
        colorScore: s.harmonyScore,
        outerwear: s.outerwear,
      );
}

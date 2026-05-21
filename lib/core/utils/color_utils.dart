import 'dart:math';
import 'package:flutter/material.dart';
import '../enums/clothing_enums.dart';

/// Bir hex renk string'inden (ör. "#1a237e" veya "1a237e")
/// ColorFamily, ColorSaturation ve ColorValue hesaplar.
class ColorUtils {
  static Color fromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    final value = int.parse(
      clean.length == 6 ? 'FF$clean' : clean,
      radix: 16,
    );
    return Color(value);
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// HSL bileşenlerini hesapla
  static ({double h, double s, double l}) _toHsl(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final maxC = max(r, max(g, b));
    final minC = min(r, min(g, b));
    final delta = maxC - minC;

    final l = (maxC + minC) / 2;

    double s = 0;
    if (delta != 0) {
      s = delta / (1 - (2 * l - 1).abs());
    }

    double h = 0;
    if (delta != 0) {
      if (maxC == r) {
        h = 60 * (((g - b) / delta) % 6);
      } else if (maxC == g) {
        h = 60 * (((b - r) / delta) + 2);
      } else {
        h = 60 * (((r - g) / delta) + 4);
      }
    }
    if (h < 0) h += 360;

    return (h: h, s: s, l: l);
  }

  static ColorFamily computeFamily(String hex) {
    final color = fromHex(hex);
    final hsl = _toHsl(color);
    final h = hsl.h;
    final s = hsl.s;
    final l = hsl.l;

    // Akromatik: siyah, beyaz, gri (satürasyon çok düşük)
    if (s < 0.10) return ColorFamily.achromatic;

    // Toprak tonları: bej, kahve, hardal, camel aralığı
    if (h >= 20 && h <= 55 && s < 0.55 && l < 0.70) {
      return ColorFamily.earth;
    }

    // Sıcak: kırmızı, turuncu, sarı, sıcak yeşil
    if (h < 70 || h >= 330) return ColorFamily.warm;

    // Soğuk: mavi, mor, soğuk yeşil
    if (h >= 180 && h < 330) return ColorFamily.cool;

    // Nötr yeşil aralığı
    if (h >= 70 && h < 180) {
      return s < 0.35 ? ColorFamily.neutral : ColorFamily.cool;
    }

    return ColorFamily.neutral;
  }

  static ColorSaturation computeSaturation(String hex) {
    final hsl = _toHsl(fromHex(hex));
    final s = hsl.s;
    if (s < 0.25) return ColorSaturation.muted;
    if (s < 0.60) return ColorSaturation.medium;
    return ColorSaturation.vibrant;
  }

  static ColorValue computeValue(String hex) {
    final hsl = _toHsl(fromHex(hex));
    final l = hsl.l;
    if (l > 0.65) return ColorValue.light;
    if (l > 0.35) return ColorValue.medium;
    return ColorValue.dark;
  }

  /// Yaygın kıyafet renkleri — seçici için
  static const List<({String hex, String name})> presetColors = [
    // Akromatik
    (hex: '#FFFFFF', name: 'Beyaz'),
    (hex: '#F5F5F5', name: 'Kırık Beyaz'),
    (hex: '#D0D0D0', name: 'Açık Gri'),
    (hex: '#808080', name: 'Gri'),
    (hex: '#404040', name: 'Koyu Gri'),
    (hex: '#1A1A1A', name: 'Siyah'),
    // Mavi
    (hex: '#1B3A6B', name: 'Lacivert'),
    (hex: '#2E5BA8', name: 'Koyu Mavi'),
    (hex: '#5B9BD5', name: 'Mavi'),
    (hex: '#AEC6E8', name: 'Açık Mavi'),
    // Yeşil
    (hex: '#2D6B4A', name: 'Koyu Yeşil'),
    (hex: '#6B7C45', name: 'Zeytin Yeşili'),
    (hex: '#4CAF50', name: 'Yeşil'),
    (hex: '#A8C5A0', name: 'Açık Yeşil'),
    // Toprak
    (hex: '#C19A6B', name: 'Camel'),
    (hex: '#8B6914', name: 'Hardal'),
    (hex: '#C0704A', name: 'Terrakota'),
    (hex: '#7B4F2E', name: 'Kahverengi'),
    (hex: '#3B1F0A', name: 'Koyu Kahve'),
    // Kırmızı / Bordo
    (hex: '#7B2D42', name: 'Bordo'),
    (hex: '#C0392B', name: 'Kırmızı'),
    (hex: '#E57373', name: 'Açık Kırmızı'),
    // Sarı / Turuncu
    (hex: '#C9A227', name: 'Hardal Sarısı'),
    (hex: '#E67E22', name: 'Turuncu'),
    // Bej / Krem
    (hex: '#F5E6D3', name: 'Krem'),
    (hex: '#D4C5A9', name: 'Bej'),
    (hex: '#A0856A', name: 'Taupe'),
    // Pembe / Mor
    (hex: '#C48EA0', name: 'Gül Kurusu'),
    (hex: '#7B5C8B', name: 'Mor'),
    // Denim
    (hex: '#3D5A80', name: 'Denim Mavisi'),
    (hex: '#6B8CAE', name: 'Açık Denim'),
  ];
}

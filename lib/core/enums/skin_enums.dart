import 'package:flutter/material.dart';

enum SkinDepth { veryFair, fair, medium, olive, brown, dark }

enum SkinUndertone { warm, cool, neutral }

extension SkinDepthX on SkinDepth {
  String get label => switch (this) {
        SkinDepth.veryFair => 'Çok Açık',
        SkinDepth.fair => 'Açık',
        SkinDepth.medium => 'Orta',
        SkinDepth.olive => 'Buğday',
        SkinDepth.brown => 'Esmer',
        SkinDepth.dark => 'Koyu',
      };

  Color get swatchColor => switch (this) {
        SkinDepth.veryFair => const Color(0xFFFDE8D8),
        SkinDepth.fair => const Color(0xFFF5C9A8),
        SkinDepth.medium => const Color(0xFFD4956A),
        SkinDepth.olive => const Color(0xFFB07840),
        SkinDepth.brown => const Color(0xFF7B4F2E),
        SkinDepth.dark => const Color(0xFF3E2010),
      };
}

extension SkinUndertoneX on SkinUndertone {
  String get label => switch (this) {
        SkinUndertone.warm => 'Sıcak',
        SkinUndertone.cool => 'Soğuk',
        SkinUndertone.neutral => 'Nötr',
      };

  String get description => switch (this) {
        SkinUndertone.warm =>
          'Bileğindeki damarlar yeşil görünüyor. Cildinde altın, sarı veya şeftali tonu baskın.',
        SkinUndertone.cool =>
          'Bileğindeki damarlar mavi/mor görünüyor. Cildinde pembe veya kırmızı ton baskın.',
        SkinUndertone.neutral =>
          'Damarlarında hem yeşil hem mavi var. Cildinde belirgin bir ton yok.',
      };

  Color get accentColor => switch (this) {
        SkinUndertone.warm => const Color(0xFFC9A227),
        SkinUndertone.cool => const Color(0xFF4A7CB5),
        SkinUndertone.neutral => const Color(0xFF6B7C6B),
      };

  // Recommended palette colors for the character summary
  List<Color> get palette => switch (this) {
        SkinUndertone.warm => const [
            Color(0xFFC19A6B), // Camel
            Color(0xFF6B7C45), // Olive
            Color(0xFFC0704A), // Terracotta
            Color(0xFFC9A227), // Mustard
          ],
        SkinUndertone.cool => const [
            Color(0xFF1B3A6B), // Navy
            Color(0xFF7B2D42), // Burgundy
            Color(0xFF6E7B8B), // Slate
            Color(0xFF2D6B4A), // Forest
          ],
        SkinUndertone.neutral => const [
            Color(0xFFC19A6B), // Camel
            Color(0xFF1B3A6B), // Navy
            Color(0xFF8C8178), // Warm Grey
            Color(0xFF6B7C45), // Olive
          ],
      };

  List<String> get paletteLabels => switch (this) {
        SkinUndertone.warm => ['Camel', 'Zeytin', 'Terrakota', 'Hardal'],
        SkinUndertone.cool => ['Lacivert', 'Bordo', 'Slate', 'Orman'],
        SkinUndertone.neutral => ['Camel', 'Lacivert', 'Gri', 'Zeytin'],
      };
}

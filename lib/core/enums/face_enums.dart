import 'package:flutter/material.dart';

enum FaceShape { oval, round, square, rectangle, heart, diamond }

enum BeardStyle { none, stubble, short, medium, full }

enum HairLength { bald, veryShort, short, medium, long }

enum HairTexture { straight, wavy, curly }

enum EyeColor { brown, hazel, green, blue, grey, black }

enum HairColor { black, darkBrown, brown, auburn, blonde, grey, white, red }

extension FaceShapeX on FaceShape {
  String get label => switch (this) {
        FaceShape.oval => 'Oval',
        FaceShape.round => 'Yuvarlak',
        FaceShape.square => 'Kare',
        FaceShape.rectangle => 'Dikdörtgen',
        FaceShape.heart => 'Kalp',
        FaceShape.diamond => 'Elmas',
      };

  String get emoji => switch (this) {
        FaceShape.oval => '🥚',
        FaceShape.round => '⭕',
        FaceShape.square => '⬜',
        FaceShape.rectangle => '▬',
        FaceShape.heart => '🫀',
        FaceShape.diamond => '🔷',
      };
}

extension BeardStyleX on BeardStyle {
  String get label => switch (this) {
        BeardStyle.none => 'Yok',
        BeardStyle.stubble => 'Hafif',
        BeardStyle.short => 'Kısa',
        BeardStyle.medium => 'Orta',
        BeardStyle.full => 'Tam Sakal',
      };
}

extension HairLengthX on HairLength {
  String get label => switch (this) {
        HairLength.bald => 'Dazlak',
        HairLength.veryShort => 'Çok Kısa',
        HairLength.short => 'Kısa',
        HairLength.medium => 'Orta',
        HairLength.long => 'Uzun',
      };
}

extension HairTextureX on HairTexture {
  String get label => switch (this) {
        HairTexture.straight => 'Düz',
        HairTexture.wavy => 'Dalgalı',
        HairTexture.curly => 'Kıvırcık',
      };
}

extension EyeColorX on EyeColor {
  String get label => switch (this) {
        EyeColor.brown => 'Kahverengi',
        EyeColor.hazel => 'Ela',
        EyeColor.green => 'Yeşil',
        EyeColor.blue => 'Mavi',
        EyeColor.grey => 'Gri',
        EyeColor.black => 'Siyah',
      };

  Color get swatchColor => switch (this) {
        EyeColor.brown => const Color(0xFF6B3F1A),
        EyeColor.hazel => const Color(0xFF8B6914),
        EyeColor.green => const Color(0xFF3A6B3A),
        EyeColor.blue => const Color(0xFF2A5298),
        EyeColor.grey => const Color(0xFF7B8794),
        EyeColor.black => const Color(0xFF1A1A1A),
      };
}

extension HairColorX on HairColor {
  String get label => switch (this) {
        HairColor.black => 'Siyah',
        HairColor.darkBrown => 'Koyu Kahve',
        HairColor.brown => 'Kahverengi',
        HairColor.auburn => 'Kızıl-Kahve',
        HairColor.blonde => 'Sarı',
        HairColor.grey => 'Gri',
        HairColor.white => 'Beyaz',
        HairColor.red => 'Kızıl',
      };

  Color get swatchColor => switch (this) {
        HairColor.black => const Color(0xFF1A1A1A),
        HairColor.darkBrown => const Color(0xFF3B1F0A),
        HairColor.brown => const Color(0xFF6B3F1A),
        HairColor.auburn => const Color(0xFF8B3A1F),
        HairColor.blonde => const Color(0xFFD4A843),
        HairColor.grey => const Color(0xFF9E9E9E),
        HairColor.white => const Color(0xFFEEEEEE),
        HairColor.red => const Color(0xFFB02020),
      };
}

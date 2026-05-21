import 'package:flutter/material.dart';

enum StyleLessonCategory { color, fit, pattern }

extension StyleLessonCategoryX on StyleLessonCategory {
  String get label => switch (this) {
        StyleLessonCategory.color => 'Renk',
        StyleLessonCategory.fit => 'Fit',
        StyleLessonCategory.pattern => 'Desen',
      };

  Color get chipColor => switch (this) {
        StyleLessonCategory.color => const Color(0xFF6B4EFF),
        StyleLessonCategory.fit => const Color(0xFF3D7A4F),
        StyleLessonCategory.pattern => const Color(0xFFE07B39),
      };

  IconData get icon => switch (this) {
        StyleLessonCategory.color => Icons.palette_outlined,
        StyleLessonCategory.fit => Icons.straighten_outlined,
        StyleLessonCategory.pattern => Icons.texture_outlined,
      };
}

class StyleLesson {
  final String id;
  final StyleLessonCategory category;
  final String title;
  final String summary;
  final List<String> bullets;
  final String? tip;

  const StyleLesson({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.bullets,
    this.tip,
  });
}

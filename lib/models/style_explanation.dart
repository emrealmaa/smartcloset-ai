import 'package:flutter/material.dart';

class StyleExplanation {
  final String rule;   // unique identifier
  final String title;  // "Renk & Cilt Tonu"
  final String body;   // eğitim metni
  final IconData icon;

  const StyleExplanation({
    required this.rule,
    required this.title,
    required this.body,
    required this.icon,
  });
}

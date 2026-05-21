import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/engine/style_education_engine.dart';
import '../models/style_lesson.dart';
import 'character_provider.dart';

final styleLessonsProvider = FutureProvider<List<StyleLesson>>((ref) async {
  final profile = ref.watch(characterProfileProvider).value;
  if (profile == null) return [];
  return StyleEducationEngine.generate(profile);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_model.dart';
import '../services/database_service.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

// Seçili kategori
final selectedCategoryProvider = StateProvider<String>((ref) => 'Tümü');

// Tüm kıyafetler
final clothingListProvider = FutureProvider<List<ClothingModel>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'Tümü') {
    return db.getAllClothes();
  }
  return db.getClothesByCategory(category);
});

// Kıyafet sayısı
final clothingCountProvider = FutureProvider<int>((ref) async {
  ref.watch(clothingListProvider); // listeye bağımlı, değişince güncellenir
  return ref.watch(databaseServiceProvider).getClothingCount();
});

// Kıyafet işlemleri
final clothingActionsProvider = Provider<ClothingActions>((ref) {
  return ClothingActions(ref);
});

class ClothingActions {
  final Ref _ref;
  ClothingActions(this._ref);

  Future<void> addClothing(ClothingModel item) async {
    await _ref.read(databaseServiceProvider).insertClothing(item);
    _ref.invalidate(clothingListProvider);
    _ref.invalidate(clothingCountProvider);
  }

  Future<void> deleteClothing(String id) async {
    await _ref.read(databaseServiceProvider).deleteClothing(id);
    _ref.invalidate(clothingListProvider);
    _ref.invalidate(clothingCountProvider);
  }
}

import '../../core/enums/clothing_enums.dart';
import '../../models/clothing_item.dart';
import '../local/daos/clothing_dao.dart';

class ClothingRepository {
  final ClothingDao _dao = ClothingDao();

  Future<List<ClothingItem>> getAll(String userId) =>
      _dao.getAllByUser(userId);

  Future<List<ClothingItem>> getByCategory(
          String userId, ClothingCategory category) =>
      _dao.getByCategory(userId, category);

  Future<ClothingItem?> getById(int id) => _dao.getById(id);

  Future<void> add(ClothingItem item) => _dao.insert(item);

  Future<void> update(ClothingItem item) => _dao.update(item);

  Future<void> delete(int id) => _dao.softDelete(id);

  Future<int> count(String userId) => _dao.countByUser(userId);
}

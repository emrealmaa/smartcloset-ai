import '../../data/local/daos/character_dao.dart';
import '../../models/character_profile.dart';

class CharacterRepository {
  final CharacterDao _dao = CharacterDao();

  Future<CharacterProfile?> getProfile(String userId) =>
      _dao.getByUserId(userId);

  Future<bool> hasProfile(String userId) async {
    final profile = await _dao.getByUserId(userId);
    return profile != null;
  }

  Future<void> saveProfile(CharacterProfile profile) async {
    final existing = await _dao.getByUserId(profile.userId);
    if (existing == null) {
      await _dao.insert(profile);
    } else {
      await _dao.update(profile.copyWith(
        id: existing.id,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteProfile(String userId) => _dao.delete(userId);
}

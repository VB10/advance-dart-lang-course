import '../../../../00_architecture/result.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';

/// Not exported by the barrel: no other feature can name this type.
final class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this._profiles);
  final Map<int, Profile> _profiles;

  @override
  Future<Result<Profile>> fetch(int id) async {
    final profile = _profiles[id];
    return profile == null ? const Err(ServerFailure(404)) : Ok(profile);
  }
}

import '../00_architecture/result.dart';
import 'profile.dart';
import 'profile_repository.dart';

final class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this._profiles, {this.online = true});
  final Map<int, Profile> _profiles;
  bool online;

  @override
  Future<Result<Profile>> fetch(int id) async {
    if (!online) return const Err(NetworkFailure());
    final profile = _profiles[id];
    return profile == null ? const Err(ServerFailure(404)) : Ok(profile);
  }
}

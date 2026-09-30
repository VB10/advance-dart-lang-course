import '../../../../00_architecture/result.dart';
import 'profile.dart';
import 'profile_repository.dart';

final class GetProfile {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(int id) => _repository.fetch(id);
}

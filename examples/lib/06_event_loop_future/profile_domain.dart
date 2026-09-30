import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show User, UserId;

final class Profile {
  const Profile({required this.user, required this.followers});
  final User user;
  final int followers;
}

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile(UserId id);
}

final class GetProfile {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(UserId id) => _repository.getProfile(id);
}

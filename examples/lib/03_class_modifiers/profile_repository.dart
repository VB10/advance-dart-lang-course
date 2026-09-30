import '../00_architecture/result.dart';
import 'profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> fetch(int id);
}

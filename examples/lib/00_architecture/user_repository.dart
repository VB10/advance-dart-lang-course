import 'result.dart';
import 'user.dart';

abstract interface class UserRepository {
  Future<Result<User>> getUser(UserId id);
}

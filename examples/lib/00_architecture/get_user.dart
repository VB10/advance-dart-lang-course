import 'result.dart';
import 'user.dart';
import 'user_repository.dart';

final class GetUser {
  const GetUser(this._repository);
  final UserRepository _repository;

  Future<Result<User>> call(UserId id) => _repository.getUser(id);
}

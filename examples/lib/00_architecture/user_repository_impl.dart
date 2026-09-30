import 'result.dart';
import 'user.dart';
import 'user_remote_data_source.dart';
import 'user_repository.dart';

final class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remote);
  final UserRemoteDataSource _remote;

  @override
  Future<Result<User>> getUser(UserId id) async {
    try {
      return _toUser(await _remote.fetchUser(id.value));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.statusCode));
    } catch (e, st) {
      return Err(UnexpectedFailure(e, st));
    }
  }
}

Result<User> _toUser(Json json) => switch (json) {
  {'id': final int id, 'name': final String name} => Ok(User(id: UserId(id), name: name)),
  _ => Err(UnexpectedFailure(FormatException('Bad user JSON: $json'), StackTrace.current)),
};

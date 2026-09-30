import 'dart:async';

import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show Json, ServerException, User, UserId;
import 'profile_domain.dart';

abstract interface class ProfileRemoteDataSource {
  /// Both throw [ServerException] on a non-2xx response.
  Future<Json> fetchUser(int id);
  Future<Json> fetchStats(int id);
}

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote, {this.timeLimit = const Duration(seconds: 10)});
  final ProfileRemoteDataSource _remote;
  final Duration timeLimit;

  @override
  Future<Result<Profile>> getProfile(UserId id) async {
    final requests = (_remote.fetchUser(id.value), _remote.fetchStats(id.value));
    try {
      final (user, stats) = await requests.wait.timeout(timeLimit);
      return _toProfile(user, stats);
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on ParallelWaitError<(Json?, Json?), (AsyncError?, AsyncError?)> catch (error) {
      return _toFailure(error.errors.$1 ?? error.errors.$2!);
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

Result<Profile> _toProfile(Json user, Json stats) => switch ((user, stats)) {
  ({'id': final int id, 'name': final String name}, {'followers': final int followers}) => Ok(
    Profile(
      user: User(id: UserId(id), name: name),
      followers: followers,
    ),
  ),
  _ => Err(UnexpectedFailure(const FormatException('Bad profile JSON'), StackTrace.current)),
};

Result<Profile> _toFailure(AsyncError first) => switch (first.error) {
  ServerException(:final statusCode) => Err(ServerFailure(statusCode)),
  final error => Err(UnexpectedFailure(error, first.stackTrace)),
};

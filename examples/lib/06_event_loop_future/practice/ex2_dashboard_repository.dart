import 'dart:async';

import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show ServerException, UserId;
import 'ex2_dashboard_domain.dart';

abstract interface class DashboardRemoteDataSource {
  /// Both throw [ServerException] on a non-2xx response.
  Future<String> fetchUserName(int id);
  Future<int> fetchUnreadCount(int id);
}

final class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote, {this.timeLimit = const Duration(seconds: 10)});
  final DashboardRemoteDataSource _remote;
  final Duration timeLimit;

  @override
  Future<Result<Dashboard>> load(UserId id) async {
    final requests = (_remote.fetchUserName(id.value), _remote.fetchUnreadCount(id.value));
    try {
      final (name, unread) = await requests.wait.timeout(timeLimit);
      return Ok(Dashboard(userName: name, unread: unread));
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on ParallelWaitError<(String?, int?), (AsyncError?, AsyncError?)> catch (error) {
      final (name, _) = error.values;
      if (name != null) return Ok(Dashboard(userName: name, unread: null));
      return _toFailure(error.errors.$1!);
    }
  }
}

Result<Dashboard> _toFailure(AsyncError nameError) => switch (nameError.error) {
  ServerException(:final statusCode) => Err(ServerFailure(statusCode)),
  final error => Err(UnexpectedFailure(error, nameError.stackTrace)),
};

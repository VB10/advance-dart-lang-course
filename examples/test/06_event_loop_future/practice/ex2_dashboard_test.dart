import 'dart:async';

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/00_architecture/user_feature.dart'
    show ServerException, UserId;
import 'package:dartadvance_examples/06_event_loop_future/practice/ex2_dashboard_domain.dart';
import 'package:dartadvance_examples/06_event_loop_future/practice/ex2_dashboard_notifier.dart';
import 'package:dartadvance_examples/06_event_loop_future/practice/ex2_dashboard_repository.dart';
import 'package:test/test.dart';

/// Each request is a Completer the test finishes by hand.
final class _FakeRemote implements DashboardRemoteDataSource {
  final name = Completer<String>();
  final unread = Completer<int>();
  final calls = <String>[];

  @override
  Future<String> fetchUserName(int id) {
    calls.add('name');
    return name.future;
  }

  @override
  Future<int> fetchUnreadCount(int id) {
    calls.add('unread');
    return unread.future;
  }
}

void main() {
  const id = UserId(7);

  test('both requests start before either completes', () async {
    final remote = _FakeRemote();
    final pending = DashboardRepositoryImpl(remote).load(id);

    expect(remote.calls, ['name', 'unread']);
    remote.unread.complete(3);
    remote.name.complete('Ada');
    final dashboard = (await pending as Ok<Dashboard>).value;
    expect(dashboardTitle(DashboardReady(dashboard)), 'Ada (3)');
  });

  test('ParallelWaitError keeps the successful value: a missing badge is still Ok', () async {
    final remote = _FakeRemote();
    final pending = DashboardRepositoryImpl(remote).load(id);
    remote.name.complete('Ada');
    remote.unread.completeError(const ServerException(500));

    final dashboard = (await pending as Ok<Dashboard>).value;
    expect((dashboard.userName, dashboard.unread), ('Ada', null));
  });

  test('a failing required request maps to its Failure', () async {
    final remote = _FakeRemote();
    final pending = DashboardRepositoryImpl(remote).load(id);
    remote.name.completeError(const ServerException(503));
    remote.unread.complete(1);

    final failure = (await pending as Err<Dashboard>).failure;
    expect(failure, isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503));
  });

  test('a timeout maps to NetworkFailure', () async {
    final repository = DashboardRepositoryImpl(_FakeRemote(), timeLimit: Duration.zero);
    final result = await repository.load(id);
    expect((result as Err<Dashboard>).failure, isA<NetworkFailure>());
  });

  test('start() is fire-and-forget and the state settles later', () async {
    final remote = _FakeRemote();
    final notifier = DashboardNotifier(DashboardRepositoryImpl(remote))..start(id);

    expect(notifier.state, isA<DashboardLoading>());
    expect(dashboardTitle(notifier.state), 'Loading...');
    remote.name.complete('Ada');
    remote.unread.completeError(const ServerException(500));
    await pumpEventQueue();
    expect(dashboardTitle(notifier.state), 'Ada');
  });
}

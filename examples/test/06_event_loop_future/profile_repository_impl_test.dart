import 'dart:async';

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/00_architecture/user_feature.dart'
    show Json, ServerException, UserId;
import 'package:dartadvance_examples/06_event_loop_future/profile_domain.dart';
import 'package:dartadvance_examples/06_event_loop_future/profile_repository_impl.dart';
import 'package:test/test.dart';

import 'profile_fakes.dart';

Future<Failure> _failureOf(FakeProfileRemote remote, {Duration? timeLimit}) async {
  final repository = timeLimit == null
      ? ProfileRepositoryImpl(remote)
      : ProfileRepositoryImpl(remote, timeLimit: timeLimit);
  final result = await repository.getProfile(const UserId(7));
  return (result as Err<Profile>).failure;
}

void main() {
  test('parallel requests combine into Ok(Profile)', () async {
    final repository = ProfileRepositoryImpl(FakeProfileRemote(user: adaUser, stats: adaStats));
    final result = await repository.getProfile(const UserId(7));
    final profile = (result as Ok<Profile>).value;
    expect((profile.user.name, profile.followers), ('Ada', 42));
  });

  test('a timeout maps to NetworkFailure', () async {
    final remote = FakeProfileRemote(user: adaUser, stats: () => Completer<Json>().future);
    expect(await _failureOf(remote, timeLimit: Duration.zero), isA<NetworkFailure>());
  });

  test('a ServerException inside ParallelWaitError maps to ServerFailure', () async {
    final remote = FakeProfileRemote(
      user: adaUser,
      stats: () => Future.error(const ServerException(503)),
    );
    expect(
      await _failureOf(remote),
      isA<ServerFailure>().having((failure) => failure.statusCode, 'statusCode', 503),
    );
  });

  test('any other error maps to UnexpectedFailure', () async {
    final remote = FakeProfileRemote(user: () => Future.error(StateError('x')), stats: adaStats);
    expect(await _failureOf(remote), isA<UnexpectedFailure>());
  });
}

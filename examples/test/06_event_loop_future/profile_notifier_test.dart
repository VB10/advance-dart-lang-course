import 'package:dartadvance_examples/00_architecture/user_feature.dart'
    show ServerException, UserId;
import 'package:dartadvance_examples/06_event_loop_future/profile_domain.dart';
import 'package:dartadvance_examples/06_event_loop_future/profile_notifier.dart';
import 'package:dartadvance_examples/06_event_loop_future/profile_repository_impl.dart';
import 'package:test/test.dart';

import 'profile_fakes.dart';

ProfileNotifier _notifier(FakeProfileRemote remote) =>
    ProfileNotifier(GetProfile(ProfileRepositoryImpl(remote)));

void main() {
  test('start() fires the load without awaiting and the state settles later', () async {
    final notifier = _notifier(FakeProfileRemote(user: adaUser, stats: adaStats))
      ..start(const UserId(7));
    expect(notifier.state, isA<ProfileLoading>());
    await pumpEventQueue();
    expect(notifier.state, isA<ProfileLoaded>());
  });

  test('a failure becomes ProfileError with the failure message', () async {
    final remote = FakeProfileRemote(
      user: () => Future.error(const ServerException(500)),
      stats: adaStats,
    );
    final notifier = _notifier(remote);
    await notifier.load(const UserId(7));
    expect(notifier.state, isA<ProfileError>().having((s) => s.message, 'message', 'Server error'));
  });
}

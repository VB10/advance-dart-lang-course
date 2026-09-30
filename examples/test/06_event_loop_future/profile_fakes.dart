import 'package:dartadvance_examples/00_architecture/user_feature.dart' show Json;
import 'package:dartadvance_examples/06_event_loop_future/profile_repository_impl.dart';

final class FakeProfileRemote implements ProfileRemoteDataSource {
  FakeProfileRemote({required this.user, required this.stats});
  final Future<Json> Function() user;
  final Future<Json> Function() stats;

  @override
  Future<Json> fetchUser(int id) => user();

  @override
  Future<Json> fetchStats(int id) => stats();
}

Future<Json> adaUser() => Future.value(<String, Object?>{'id': 7, 'name': 'Ada'});
Future<Json> adaStats() => Future.value(<String, Object?>{'followers': 42});

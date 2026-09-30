import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/00_architecture/user_feature.dart';
import 'package:test/test.dart';

final class _FakeRemote implements UserRemoteDataSource {
  _FakeRemote(this._respond);
  final Future<Json> Function(int id) _respond;

  @override
  Future<Json> fetchUser(int id) => _respond(id);
}

GetUser _getUser(Future<Json> Function(int id) respond) =>
    GetUser(UserRepositoryImpl(_FakeRemote(respond)));

void main() {
  test('valid JSON becomes Ok(User)', () async {
    final result = await _getUser((id) async => {'id': id, 'name': 'Ada'})(const UserId(7));
    expect(result, isA<Ok<User>>());
    expect(describe(result), 'Hello, Ada');
    expect((result as Ok<User>).value.id, const UserId(7));
  });

  test('ServerException maps to ServerFailure', () async {
    final result = await _getUser((_) => throw const ServerException(503))(const UserId(1));
    expect(describe(result), 'Server said 503');
  });

  test('malformed JSON maps to UnexpectedFailure', () async {
    final result = await _getUser((_) async => {'id': '1'})(const UserId(1));
    expect(result, isA<Err<User>>());
    expect((result as Err<User>).failure, isA<UnexpectedFailure>());
  });

  test('unknown errors keep their stack trace', () async {
    final result = await _getUser((_) => throw StateError('boom'))(const UserId(1));
    final failure = (result as Err<User>).failure as UnexpectedFailure;
    expect(failure.error, isA<StateError>());
    expect(failure.stackTrace.toString(), isNotEmpty);
  });
}

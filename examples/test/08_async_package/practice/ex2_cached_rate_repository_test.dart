import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/08_async_package/practice/ex2_cached_rate_repository.dart';
import 'package:test/test.dart';

final class _FakeRemote implements RateRemoteDataSource {
  final requests = <String>[];
  final responses = <Future<double> Function()>[];

  @override
  Future<double> fetchRate(String currency) {
    requests.add(currency);
    return responses.removeAt(0)();
  }
}

void main() {
  test('within the TTL one remote call serves every caller', () async {
    final remote = _FakeRemote()..responses.add(() async => 32.5);
    final repository = CachedRateRepository(remote, ttl: const Duration(hours: 1));

    final results = await Future.wait([repository.usdTo('TRY'), repository.usdTo('TRY')]);
    final again = await repository.usdTo('TRY');

    expect(remote.requests, ['TRY']);
    expect([...results, again].map((result) => (result as Ok<double>).value), [32.5, 32.5, 32.5]);
  });

  test('a failure becomes Err and is not cached for the TTL', () async {
    final remote = _FakeRemote()
      ..responses.add(() async => throw const FormatException('bad rate'))
      ..responses.add(() async => 33.0);
    final repository = CachedRateRepository(remote, ttl: const Duration(hours: 1));

    final failed = await repository.usdTo('TRY');
    final retried = await repository.usdTo('TRY');

    expect(
      failed,
      isA<Err<double>>().having(
        (err) => err.failure,
        'failure',
        isA<UnexpectedFailure>().having((failure) => failure.error, 'error', isFormatException),
      ),
    );
    expect(retried, isA<Ok<double>>().having((ok) => ok.value, 'value', 33.0));
    expect(remote.requests, ['TRY', 'TRY'], reason: 'retried despite the 1h TTL');
  });
}

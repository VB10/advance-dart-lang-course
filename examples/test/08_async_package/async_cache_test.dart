import 'package:dartadvance_examples/08_async_package/async_cache.dart';
import 'package:test/test.dart';

void main() {
  test('AsyncCache reuses the value until it is invalidated', () async {
    var fetches = 0;
    final cache = RatesCache(() async => ++fetches * 1.0, ttl: const Duration(hours: 1));
    expect(await cache.rate, 1.0);
    expect(await cache.rate, 1.0);
    expect(fetches, 1);

    cache.refresh();
    expect(await cache.rate, 2.0);
    expect(fetches, 2);
  });

  test('AsyncCache expires after the duration', () async {
    var fetches = 0;
    final cache = RatesCache(() async => ++fetches * 1.0, ttl: Duration.zero);
    expect(await cache.rate, 1.0);
    await pumpEventQueue();
    expect(await cache.rate, 2.0);
  });

  test('AsyncCache caches a failure for the whole TTL as well', () async {
    var fetches = 0;
    final cache = RatesCache(() async {
      fetches++;
      throw StateError('offline');
    }, ttl: const Duration(hours: 1));
    await expectLater(cache.rate, throwsStateError);
    await expectLater(cache.rate, throwsStateError);
    expect(fetches, 1);
  });
}

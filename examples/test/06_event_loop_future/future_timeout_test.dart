import 'dart:async';

import 'package:dartadvance_examples/06_event_loop_future/future_timeout.dart';
import 'package:test/test.dart';

void main() {
  const limit = Duration.zero;

  test('without onTimeout a late future fails with TimeoutException', () {
    expect(fetchOrThrow(Completer<String>().future, limit), throwsA(isA<TimeoutException>()));
  });

  test('with onTimeout a late future yields the fallback value', () async {
    expect(await fetchOrCached(Completer<String>().future, limit), 'cached');
  });

  test('a source that finishes in time wins over the fallback', () async {
    expect(await fetchOrCached(Future.value('fresh'), const Duration(seconds: 1)), 'fresh');
  });
}

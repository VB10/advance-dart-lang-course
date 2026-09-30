import 'dart:async';

import 'package:dartadvance_examples/08_async_package/future_group.dart';
import 'package:test/test.dart';

void main() {
  test('FutureGroup keeps insertion order and completes after close', () async {
    final slow = Completer<int>();
    final all = uploadAll(Stream.fromIterable([slow.future, Future.value(2)]));
    await pumpEventQueue();
    slow.complete(1);
    expect(await all, [1, 2]);
  });

  test('FutureGroup fails with the first error', () async {
    final failing = Completer<int>();
    final all = uploadAll(Stream.fromIterable([Future.value(1), failing.future]));
    await pumpEventQueue();
    failing.completeError(StateError('x'));
    await expectLater(all, throwsStateError);
  });
}

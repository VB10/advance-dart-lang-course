import 'dart:async';

import 'package:dartadvance_examples/07_streams/pausable_counter.dart';
import 'package:test/test.dart';

void main() {
  test('the source stays inert until listened and produces nothing while paused', () async {
    final log = <String>[];
    final stream = pausableCounter(4, log: log.add);
    await pumpEventQueue();
    expect(log, isEmpty);

    final received = <int>[];
    late final StreamSubscription<int> subscription;
    subscription = stream.listen((value) {
      received.add(value);
      if (value == 2) subscription.pause();
    });
    await pumpEventQueue();
    expect(received, [1, 2]);
    expect(log, ['onListen', 'produce 1', 'produce 2', 'onPause']);

    subscription.resume();
    await subscription.asFuture<void>();
    expect(received, [1, 2, 3, 4]);
    expect(log.skip(4), ['onResume', 'produce 3', 'produce 4', 'onCancel']);
  });

  test('cancel triggers onCancel and stops production', () async {
    final log = <String>[];
    final received = <int>[];
    late final StreamSubscription<int> subscription;
    subscription = pausableCounter(100, log: log.add).listen((value) {
      received.add(value);
      if (value == 2) subscription.cancel();
    });
    await pumpEventQueue();

    expect(received, [1, 2]);
    expect(log.last, 'onCancel');
    expect(log.where((event) => event.startsWith('produce')), hasLength(2));
  });
}

import 'dart:async';

import 'package:dartadvance_examples/06_event_loop_future/practice/ex1_boot_order.dart';
import 'package:test/test.dart';

void main() {
  test('sync first, then microtasks in queue order, then Timer.run', () async {
    expect(await bootOrder(), [
      'loadConfig: before await',
      'boot: end of function',
      'scheduleMicrotask',
      'loadConfig: after await',
      'Timer.run',
    ]);
  });

  test('a microtask queued after a Timer.run still runs before it', () async {
    final log = <String>[];
    final done = Completer<void>();
    Timer.run(() {
      log.add('timer');
      done.complete();
    });
    scheduleMicrotask(() => log.add('microtask'));
    log.add('sync');

    expect(log, ['sync']);
    await done.future;
    expect(log, ['sync', 'microtask', 'timer']);
  });
}

import 'package:dartadvance_examples/06_event_loop_future/microtask_order.dart';
import 'package:test/test.dart';

void main() {
  test('sync code runs first, then every microtask, then event-queue callbacks', () async {
    expect(await eventLoopOrder(), [
      'sync: end of function',
      'microtask: scheduleMicrotask',
      'microtask: Future.microtask',
      'event: Timer.run',
      'event: Future()',
    ]);
  });
}

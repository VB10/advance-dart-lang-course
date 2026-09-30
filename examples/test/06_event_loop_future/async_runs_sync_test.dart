import 'package:dartadvance_examples/06_event_loop_future/async_runs_sync.dart';
import 'package:test/test.dart';

void main() {
  test('an async function runs synchronously until its first await', () async {
    final log = callWithoutAwait();
    expect(log, ['greet: before await', 'caller: next statement']);
    await Future<void>.delayed(Duration.zero);
    expect(log.last, 'greet: after await');
  });
}

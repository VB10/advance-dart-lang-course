import 'package:dartadvance_examples/08_async_package/restartable_timer.dart';
import 'package:test/test.dart';

void main() {
  test('pings in the same turn collapse into one call and a later ping runs again', () async {
    var fired = 0;
    final debouncer = Debouncer(Duration.zero, () => fired++);
    await pumpEventQueue();
    expect(fired, 0, reason: 'idle until the first ping');

    debouncer
      ..ping()
      ..ping()
      ..ping();
    await pumpEventQueue();
    expect(fired, 1);

    debouncer.ping();
    await pumpEventQueue();
    expect(fired, 2);
    debouncer.dispose();
  });
}

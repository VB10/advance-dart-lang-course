import 'package:dartadvance_examples/08_async_package/cancelable_completer.dart';
import 'package:test/test.dart';

void main() {
  test('CancelableCompleter onCancel stops the underlying work', () async {
    final operation = slowSquare(4, delay: Duration.zero);
    await operation.cancel();
    await pumpEventQueue();
    expect(operation.isCanceled, isTrue);
    expect(operation.isCompleted, isFalse, reason: 'timer cancelled, complete() never ran');

    expect(await slowSquare(4, delay: Duration.zero).value, 16);
  });
}

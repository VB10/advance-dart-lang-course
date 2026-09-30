import 'dart:async';

import 'package:dartadvance_examples/08_async_package/cancelable_from_future.dart';
import 'package:test/test.dart';

void main() {
  test(
    'after cancel the value never completes, the late result is discarded and onCancel runs once',
    () async {
      final request = Completer<String>();
      var cancelCalls = 0;
      final operation = fetchCancelable(request.future, onCancel: () => cancelCalls++);

      var valueCompleted = false;
      unawaited(operation.value.then((_) => valueCompleted = true));
      final described = describe(operation);

      await operation.cancel();
      await operation.cancel();
      request.complete('late response');
      await pumpEventQueue();

      expect(operation.isCanceled, isTrue);
      expect(operation.isCompleted, isFalse);
      expect(cancelCalls, 1);
      expect(valueCompleted, isFalse);
      expect(await described, 'cancelled');
    },
  );

  test('without cancel valueOrCancellation completes with the value', () async {
    final operation = fetchCancelable(Future.value('hits'));
    expect(await describe(operation), 'hits');
    expect(operation.isCompleted, isTrue);
    expect(operation.isCanceled, isFalse);
  });

  test('cancel after completion does nothing', () async {
    var cancelCalls = 0;
    final operation = fetchCancelable(Future.value('done'), onCancel: () => cancelCalls++);
    expect(await operation.value, 'done');
    await operation.cancel();
    expect(operation.isCanceled, isFalse);
    expect(cancelCalls, 0);
  });
}

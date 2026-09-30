import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/practice/ex3_latest_results.dart';
import 'package:test/test.dart';

void main() {
  test('a slow old result never overtakes the newer query', () async {
    final completers = <String, CancelableCompleter<String>>{};
    final cancelled = <String>[];
    CancelableOperation<String> search(String query) {
      final completer = completers[query] = CancelableCompleter<String>(
        onCancel: () => cancelled.add(query),
      );
      return completer.operation;
    }

    final queries = StreamController<String>();
    final emitted = <String>[];
    final done = latestResults(queries.stream, search).forEach(emitted.add);

    queries
      ..add('ph')
      ..add('phone');
    await pumpEventQueue();
    completers['phone']!.complete('PHONE');
    completers['ph']!.complete('PH');
    await queries.close();
    await done;

    expect(emitted, ['PHONE']);
    expect(cancelled, ['ph'], reason: 'the older operation was cancelled');
  });

  test('cancelling the output cancels the source and the pending operation', () async {
    var cancelCalls = 0;
    var sourceCancelled = false;
    final queries = StreamController<int>(onCancel: () => sourceCancelled = true);
    CancelableOperation<int> square(int n) =>
        CancelableCompleter<int>(onCancel: () => cancelCalls++).operation;

    final subscription = latestResults(queries.stream, square).listen(null);
    queries.add(3);
    await pumpEventQueue();
    await subscription.cancel();

    expect(sourceCancelled, isTrue);
    expect(cancelCalls, 1);
    await queries.close();
  });

  test('an operation error is forwarded as an error event and the output closes', () async {
    final results = latestResults(
      Stream.fromIterable([1]),
      (int n) => CancelableOperation<int>.fromFuture(Future.error(StateError('down'))),
    );
    await expectLater(results, emitsInOrder([emitsError(isStateError), emitsDone]));
  });
}

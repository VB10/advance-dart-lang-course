import 'dart:async';
import 'dart:isolate';

import 'package:dartadvance_examples/09_isolates/capture_rules.dart';
import 'package:dartadvance_examples/09_isolates/decode_orders.dart';
import 'package:dartadvance_examples/09_isolates/price_worker.dart';
import 'package:test/test.dart';

void main() {
  group('decode_orders', () {
    const body = '[{"id":1,"total":9.5},{"id":2,"total":20}]';

    test('a small body parses inline into orders', () async {
      final orders = await decodeOrders(body);
      expect(orders.map((order) => order.id), [1, 2]);
      expect(orders.last.total, 20.0);
    });

    test('a body over the threshold parses in an isolate with the same result', () async {
      final orders = await decodeOrders(body, isolateThreshold: 1);
      expect(orders.map((order) => order.total), [9.5, 20.0]);
    });

    test('the naive always-isolate version returns the same orders', () async {
      final orders = await naiveDecodeOrders(body);
      expect(orders.map((order) => order.id), [1, 2]);
    });

    test('a FormatException crosses the isolate boundary with its type', () {
      expect(decodeOrders('{oops', isolateThreshold: 1), throwsFormatException);
    });
  });

  group('capture_rules', () {
    test('the caller list is a copy and stays unsorted', () async {
      final totals = [30, 10, 20];
      expect(await sortedTotals(totals), [10, 20, 30]);
      expect(totals, [30, 10, 20]);
    });

    test('a global mutated in the isolate stays 0 in the main isolate', () async {
      expect(await countInIsolate(), 1);
      expect(await countInIsolate(), 1);
      expect(loadedOrderCount, 0);
    });

    test('capturing a ReceivePort fails because it is unsendable', () {
      expect(captureReceivePort(), throwsA(isA<ArgumentError>()));
    });
  });

  group('price_worker', () {
    test('answers sequential and concurrent requests in order', () async {
      final worker = await PriceWorker.spawn();
      expect(await worker.withTax(1000), 1200);
      expect(await Future.wait([worker.withTax(100), worker.withTax(200)]), [120, 240]);
      worker.close();
      await worker.exited;
    });

    test('a handled worker error arrives as RemoteError', () async {
      final worker = await PriceWorker.spawn();
      await expectLater(worker.withTax(-1), throwsA(isA<RemoteError>()));
      worker.close();
      await worker.exited;
    });

    test('close completes exited, and later requests fail with StateError', () async {
      final worker = await PriceWorker.spawn();
      worker.close();
      await worker.exited.timeout(const Duration(seconds: 2));
      await expectLater(worker.withTax(100), throwsStateError);
    });

    test('naive version hangs on a dead worker and turns RemoteError into TypeError', () async {
      final worker = await PriceWorker.spawn();
      await expectLater(worker.naiveWithTax(-1), throwsA(isA<TypeError>()));
      worker.close();
      await worker.exited;
      expect(
        worker.naiveWithTax(100).timeout(const Duration(milliseconds: 300)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}

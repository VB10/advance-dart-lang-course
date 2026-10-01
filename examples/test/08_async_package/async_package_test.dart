import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/async_cache.dart';
import 'package:dartadvance_examples/08_async_package/async_memoizer.dart';
import 'package:dartadvance_examples/08_async_package/cancelable_search.dart';
import 'package:dartadvance_examples/08_async_package/stream_group.dart';
import 'package:dartadvance_examples/08_async_package/stream_queue.dart';
import 'package:test/test.dart';

void main() {
  group('cancelable_search', () {
    test('a newer query cancels the older one and the older result is discarded', () async {
      final requests = <String, Completer<List<String>>>{};
      final search = ProductSearch((query) => (requests[query] = Completer()).future);

      final old = search.search('sh');
      final latest = search.search('shoe');
      requests['shoe']!.complete(['shoe']);
      requests['sh']!.complete(['shirt', 'shoe']);

      expect(await old, isNull);
      expect(await latest, ['shoe']);
    });

    test('naive search delivers the stale reply too', () async {
      final requests = <String, Completer<List<String>>>{};
      final search = ProductSearch((query) => (requests[query] = Completer()).future);

      final old = search.searchNaive('sh');
      final latest = search.searchNaive('shoe');
      requests['shoe']!.complete(['shoe']);
      requests['sh']!.complete(['shirt', 'shoe']);

      expect(await old, ['shirt', 'shoe']);
      expect(await latest, ['shoe']);
    });

    test('cancel after completion does nothing', () async {
      final operation = CancelableOperation.fromFuture(Future.value('done'));
      expect(await operation.value, 'done');
      await operation.cancel();
      expect(operation.isCanceled, isFalse);
    });

    test('the cancelled request keeps running, only its result is ignored', () async {
      var finished = false;
      final search = ProductSearch((query) async {
        await pumpEventQueue();
        finished = true;
        return [query];
      });
      final old = search.search('a');
      unawaited(search.search('ab'));
      expect(await old, isNull);
      await pumpEventQueue(times: 50);
      expect(finished, isTrue);
    });
  });

  group('async_memoizer', () {
    test('runs once for concurrent and later callers', () async {
      var loads = 0;
      final gate = Completer<Map<String, String>>();
      final loader = ConfigLoader(() {
        loads++;
        return gate.future;
      });

      final first = loader.config;
      final second = loader.config;
      expect(loader.hasLoaded, isTrue);
      gate.complete({'env': 'prod'});
      expect(await first, {'env': 'prod'});
      expect(await second, {'env': 'prod'});
      expect(await loader.config, {'env': 'prod'});
      expect(loads, 1);
    });

    test('naive getter loads once per caller', () async {
      var loads = 0;
      final loader = ConfigLoader(() async {
        loads++;
        return {'env': 'prod'};
      });
      await Future.wait([loader.configNaive, loader.configNaive, loader.configNaive]);
      expect(loads, 3);
      expect(loader.hasLoaded, isFalse);
    });

    test('memoizes an error too, without retry', () async {
      var loads = 0;
      final loader = ConfigLoader(() async {
        loads++;
        throw StateError('disk');
      });
      await expectLater(loader.config, throwsStateError);
      await expectLater(loader.config, throwsStateError);
      expect(loads, 1);
    });
  });

  group('async_cache', () {
    test('reuses the value until it is invalidated', () async {
      var fetches = 0;
      final cache = RatesCache(() async => ++fetches * 1.0, ttl: const Duration(hours: 1));
      expect(await cache.rate, 1.0);
      expect(await cache.rate, 1.0);
      expect(fetches, 1);

      cache.refresh();
      expect(await cache.rate, 2.0);
      expect(fetches, 2);
    });

    test('naive getter fetches on every read', () async {
      var fetches = 0;
      final cache = RatesCache(() async => ++fetches * 1.0, ttl: const Duration(hours: 1));
      await cache.rateNaive;
      await cache.rateNaive;
      expect(fetches, 2);
    });

    test('expires after the duration', () async {
      var fetches = 0;
      final cache = RatesCache(() async => ++fetches * 1.0, ttl: Duration.zero);
      expect(await cache.rate, 1.0);
      await pumpEventQueue();
      expect(await cache.rate, 2.0);
    });

    test('caches a failure for the whole TTL as well', () async {
      var fetches = 0;
      final cache = RatesCache(() async {
        fetches++;
        throw StateError('offline');
      }, ttl: const Duration(hours: 1));
      await expectLater(cache.rate, throwsStateError);
      await expectLater(cache.rate, throwsStateError);
      expect(fetches, 1);
    });
  });

  group('stream_queue', () {
    test('pulls a header and then exactly that many items', () async {
      final lines = Stream.fromIterable(['ORDER 2', 'apple', 'pear', 'NEXT 0']);
      final message = await readMessage(lines);
      expect(message.title, 'ORDER');
      expect(message.items, ['apple', 'pear']);
    });

    test('naive first-then-take listens twice and fails', () async {
      final lines = StreamController<String>()..add('ORDER 2');
      await expectLater(readItemsNaive(lines.stream), throwsStateError);
    });

    test('peek does not consume and rest closes the queue', () async {
      final queue = StreamQueue(Stream.fromIterable([1, 2, 3, 4, 5]));
      expect(await queue.peek, 1);
      expect(await queue.next, 1);
      expect(await queue.take(2), [2, 3]);
      expect(await queue.hasNext, isTrue);
      expect(await queue.rest.toList(), [4, 5]);
      expect(() => queue.next, throwsStateError);
    });

    test('next fails with StateError when the stream ends first', () async {
      final queue = StreamQueue(const Stream<int>.empty());
      expect(await queue.hasNext, isFalse);
      await expectLater(queue.next, throwsStateError);
    });
  });

  group('stream_group', () {
    test('merge forwards both sources and closes after both closed', () async {
      final server = StreamController<String>();
      final device = StreamController<String>();
      final queue = StreamQueue(allAlerts(server.stream, device.stream));

      server.add('s1');
      expect(await queue.next, 's1');
      device.add('d1');
      expect(await queue.next, 'd1');

      unawaited(server.close());
      device.add('d2');
      expect(await queue.next, 'd2', reason: 'still open: device has not closed');
      unawaited(device.close());
      expect(await queue.hasNext, isFalse);
    });

    test('naive count and total listens twice and fails', () async {
      final prices = StreamController<int>()
        ..add(1)
        ..add(2)
        ..close();
      await expectLater(countAndTotalNaive(prices.stream), throwsStateError);
    });

    test('every splitter branch sees every event', () async {
      expect(await countAndTotal(Stream.fromIterable([10, 20, 30])), (3, 60));
    });

    test('a splitter replays to a late branch but asBroadcastStream does not', () async {
      final splitter = StreamSplitter(Stream.fromIterable([1, 2, 3]));
      final early = await splitter.split().toList();
      final late = await splitter.split().toList();
      await splitter.close();
      expect(
        [early, late],
        [
          [1, 2, 3],
          [1, 2, 3],
        ],
      );

      final broadcast = Stream.fromIterable([1, 2, 3]).asBroadcastStream();
      expect(await broadcast.toList(), [1, 2, 3]);
      expect(await broadcast.toList(), isEmpty);
    });
  });
}

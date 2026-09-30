import 'dart:async';

import 'package:dartadvance_examples/07_streams/async_generator.dart';
import 'package:dartadvance_examples/07_streams/controller_callbacks.dart';
import 'package:dartadvance_examples/07_streams/message_transformer.dart';
import 'package:dartadvance_examples/07_streams/price_watcher.dart';
import 'package:dartadvance_examples/07_streams/stream_kinds.dart';
import 'package:test/test.dart';

void main() {
  group('stream_kinds', () {
    test(
      'a single-subscription stream throws StateError on a second listen, even after cancel',
      () async {
        final stream = orderHistory(['paid', 'shipped']);
        expect(stream.isBroadcast, isFalse);
        final first = stream.listen(null);
        expect(() => stream.listen(null), throwsStateError);
        await first.cancel();
        expect(() => stream.listen(null), throwsStateError);
      },
    );

    test('a broadcast stream serves many listeners and drops events nobody hears', () async {
      final feed = OrderStatusFeed();
      expect(feed.statusChanges.isBroadcast, isTrue);
      feed.publish('lost');

      final first = <String>[];
      final second = <String>[];
      final firstSub = feed.statusChanges.listen(first.add);
      final secondSub = feed.statusChanges.listen(second.add);
      feed.publish('paid');
      await pumpEventQueue();
      await firstSub.cancel();
      await secondSub.cancel();

      expect(first, ['paid']);
      expect(second, ['paid']);
      await feed.close();
    });

    test('asBroadcastStream lets a single-subscription stream have two listeners', () async {
      final shared = shareable(orderHistory(['paid', 'shipped']));
      final results = await Future.wait([shared.toList(), shared.toList()]);
      expect(results, [
        ['paid', 'shipped'],
        ['paid', 'shipped'],
      ]);
    });
  });

  group('async_generator', () {
    test('an async* stream yields every page in order and ends on an empty page', () async {
      final pages = {
        0: [1, 2],
        1: [3],
      };
      final ids = await orderIds((page) async => pages[page] ?? [], onReleased: () {}).toList();
      expect(ids, [1, 2, 3]);
    });

    test('an early take stops fetching pages and runs finally once', () async {
      final requested = <int>[];
      var released = 0;
      final ids = await orderIds(
        (page) async {
          requested.add(page);
          return [page * 2, page * 2 + 1];
        },
        onReleased: () => released++,
      ).take(3).toList();

      expect(ids, [0, 1, 2]);
      expect(requested, [0, 1]);
      expect(released, 1);
    });
  });

  group('controller_callbacks', () {
    test('the source stays inert until listened and stops while paused', () async {
      final log = <String>[];
      final stream = courierPositions(log: log.add);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(log, isEmpty);

      final subscription = stream.listen(null);
      expect(log, ['onListen']);
      subscription.pause();
      expect(log, ['onListen', 'onPause']);
      subscription.resume();
      expect(log, ['onListen', 'onPause', 'onResume']);
      await subscription.cancel();
      expect(log.last, 'onCancel');
    });

    test('cancel triggers onCancel and no more positions arrive', () async {
      final log = <String>[];
      final positions = <int>[];
      final subscription = courierPositions(log: log.add).listen(positions.add);
      await Future<void>.delayed(const Duration(milliseconds: 55));
      await subscription.cancel();
      final countAtCancel = positions.length;
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(countAtCancel, greaterThan(0));
      expect(positions, hasLength(countAtCancel));
      expect(log.last, 'onCancel');
    });
  });

  group('message_transformer', () {
    test('trimMessages trims messages and drops empty ones', () async {
      final result = await Stream.fromIterable(['  hi ', '   ', 'yo'])
          .transform(trimMessages)
          .toList();
      expect(result, ['hi', 'yo']);
    });
  });

  group('price_watcher', () {
    test('dispose cancels the source and later events change nothing', () async {
      var cancelled = false;
      final controller = StreamController<double>(onCancel: () => cancelled = true);
      final watcher = PriceWatcher(controller.stream)..start();

      controller.add(10.5);
      await pumpEventQueue();
      expect(watcher.latestPrice, 10.5);

      await watcher.dispose();
      expect(cancelled, isTrue);
      controller.add(99);
      await pumpEventQueue();
      expect(watcher.latestPrice, 10.5);
    });

    test('calling start twice does not subscribe twice', () async {
      final controller = StreamController<double>.broadcast();
      final watcher = PriceWatcher(controller.stream)
        ..start()
        ..start();
      expect(controller.hasListener, isTrue);
      await watcher.dispose();
      expect(controller.hasListener, isFalse);
    });
  });
}

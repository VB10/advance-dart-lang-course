import 'package:dartadvance_examples/07_streams/broadcast_stream.dart';
import 'package:dartadvance_examples/07_streams/sum_stream.dart';
import 'package:test/test.dart';

void main() {
  test(
    'a single-subscription stream throws StateError on a second listen, even after cancel',
    () async {
      final stream = countStream(2);
      expect(stream.isBroadcast, isFalse);
      final first = stream.listen(null);
      expect(() => stream.listen(null), throwsStateError);
      await first.cancel();
      expect(() => stream.listen(null), throwsStateError);
    },
  );

  test('a broadcast stream serves many listeners and drops events nobody hears', () async {
    final events = ConnectivityEvents();
    expect(events.changes.isBroadcast, isTrue);
    events.report(online: false);

    final first = <bool>[];
    final second = <bool>[];
    final firstSubscription = events.changes.listen(first.add);
    final secondSubscription = events.changes.listen(second.add);
    events.report(online: true);
    await pumpEventQueue();
    await firstSubscription.cancel();
    await secondSubscription.cancel();

    expect(first, [true]);
    expect(second, [true]);
    await events.close();
  });

  test('asBroadcastStream lets a single-subscription stream have two listeners', () async {
    final shared = countStream(3).asBroadcastStream();
    final results = await Future.wait([shared.toList(), shared.toList()]);
    expect(results, [
      [1, 2, 3],
      [1, 2, 3],
    ]);
  });
}

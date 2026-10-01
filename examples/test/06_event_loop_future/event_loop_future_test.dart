import 'dart:async';

import 'package:dartadvance_examples/06_event_loop_future/event_loop_order.dart';
import 'package:dartadvance_examples/06_event_loop_future/fire_and_forget.dart';
import 'package:dartadvance_examples/06_event_loop_future/parallel_wait.dart';
import 'package:dartadvance_examples/06_event_loop_future/timeout_completer.dart';
import 'package:test/test.dart';

Future<T> _after<T>(int milliseconds, T value) =>
    Future.delayed(Duration(milliseconds: milliseconds), () => value);

final class _SilentClient implements LegacyLocationClient {
  @override
  void requestCity(void Function(String? city, Object? error) onDone) {}
}

final class _ChattyClient implements LegacyLocationClient {
  @override
  void requestCity(void Function(String? city, Object? error) onDone) {
    onDone('Ankara', null);
    onDone('Izmir', null);
    onDone(null, StateError('late'));
  }
}

/// Runs [body] and returns every error that reached the zone as unhandled.
Future<List<Object>> _unhandledErrors(void Function() body) async {
  final errors = <Object>[];
  runZonedGuarded(body, (error, _) => errors.add(error));
  await Future<void>.delayed(Duration.zero);
  return errors;
}

void main() {
  group('event_loop_order', () {
    test('sync code runs first, then every microtask, then event-queue callbacks', () async {
      expect(await orderOfExecution(), [
        'sync: end of function',
        'microtask: scheduleMicrotask',
        'microtask: Future.microtask',
        'event: Timer.run',
        'event: Future()',
      ]);
    });

    test('an async function runs synchronously until its first await', () async {
      final log = <String>[];
      final future = greet(log);
      log.add('caller: next statement');
      await future;
      expect(log, ['greet: before await', 'caller: next statement', 'greet: after await']);
    });
  });

  group('event_loop_order confirm', () {
    test('naive version returns before the queued analytics call runs', () async {
      final log = confirmOrderNaive();
      expect(log, ['state: updated']);
      await Future<void>.delayed(Duration.zero);
      expect(log, ['state: updated', 'analytics: sent']);
    });

    test('await returns only after state and analytics, in order', () async {
      expect(await confirmOrder(), ['state: updated', 'analytics: sent']);
    });
  });

  group('parallel_wait', () {
    final log = <String>[];
    Future<int> unread() async {
      log.add('unread start');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      log.add('unread end');
      return 3;
    }

    Future<String> name() async {
      log.add('name start');
      return 'Ada';
    }

    setUp(log.clear);

    test('sequential awaits start the second request only after the first ends', () async {
      expect(await loadSequential(unread, name), 'Ada has 3 unread');
      expect(log, ['unread start', 'unread end', 'name start']);
    });

    test('record wait starts both requests together and keeps each field type', () async {
      expect(await loadParallel(unread, name), 'Ada has 3 unread');
      expect(log, ['unread start', 'name start', 'unread end']);
    });

    test('ParallelWaitError still carries the successful values', () async {
      expect(
        await loadParallel(() => Future<int>.error(StateError('offline')), () async => 'Ada'),
        'partial: name=Ada count=null',
      );
    });

    test('Future.wait keeps the input order, not the completion order', () async {
      expect(await loadPrices([_after(20, 1), _after(1, 2), _after(10, 3)]), [1, 2, 3]);
    });

    test('Future.wait fails with the first error', () {
      expect(
        loadPrices([_after(1, 1), Future<int>.error(StateError('boom'))]),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('timeout_completer', () {
    test('without a limit a silent client stays pending forever', () async {
      var done = false;
      unawaited(cityForever(_SilentClient()).then((_) => done = true));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(done, isFalse);
    });

    test('a Completer ignores callbacks after the first one', () async {
      expect(await currentCity(_ChattyClient()), 'Ankara');
    });

    test('without onTimeout a silent client fails with TimeoutException', () {
      expect(cityOrThrow(_SilentClient(), Duration.zero), throwsA(isA<TimeoutException>()));
    });

    test('with onTimeout a silent client yields the fallback value', () async {
      expect(await cityOrDefault(_SilentClient(), Duration.zero), 'Istanbul');
    });

    test('a client that answers in time wins over the fallback', () async {
      expect(await cityOrDefault(_ChattyClient(), const Duration(seconds: 1)), 'Ankara');
    });
  });

  group('fire_and_forget', () {
    test('unawaited does not swallow the error', () async {
      final errors = await _unhandledErrors(() => trackScreenOpenedLoud(AnalyticsClient()));
      expect(errors, [isA<StateError>()]);
    });

    test('ignore swallows the error', () async {
      final errors = await _unhandledErrors(() => trackScreenOpenedQuiet(AnalyticsClient()));
      expect(errors, isEmpty);
    });

    test('catchError before unawaited reports the failure to you', () async {
      final reported = <Object>[];
      final errors = await _unhandledErrors(
        () => trackScreenOpenedSafe(AnalyticsClient(), reported.add),
      );
      expect(errors, isEmpty);
      expect(reported, [isA<StateError>()]);
    });
  });
}

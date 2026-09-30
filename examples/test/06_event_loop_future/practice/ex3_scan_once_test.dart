import 'dart:async';

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/06_event_loop_future/practice/ex3_scan_once.dart';
import 'package:test/test.dart';

/// Fires the given events synchronously and keeps the callback for later.
final class _FakeScanner implements BarcodeScanner {
  _FakeScanner([this.events = const []]);
  final List<ScanEvent> events;
  void Function(ScanEvent event)? onEvent;

  @override
  void start(void Function(ScanEvent event) onEvent) {
    this.onEvent = onEvent;
    events.forEach(onEvent);
  }
}

Matcher _okWith(Object? value) => isA<Ok<String?>>().having((r) => r.value, 'value', value);

void main() {
  test('the first event wins and a second callback does not throw', () async {
    final scanner = _FakeScanner([
      const ScanFound('4006381333931'),
      ScanFailed(StateError('late')),
    ]);

    expect(await scanOnce(scanner), _okWith('4006381333931'));
    expect(() => scanner.onEvent!(const ScanCancelled()), returnsNormally);
  });

  test('without the guard, completing twice is a StateError', () {
    final completer = Completer<int>()..complete(1);
    expect(completer.isCompleted, isTrue);
    expect(() => completer.complete(2), throwsStateError);
  });

  test('failure and cancel map through the exhaustive switch', () async {
    expect(
      await scanOnce(_FakeScanner([const ScanFailed('camera busy')])),
      isA<Err<String?>>().having((e) => e.failure, 'failure', isA<UnexpectedFailure>()),
    );
    expect(await scanOnce(_FakeScanner([const ScanCancelled()])), _okWith(null));
  });

  test('a later event completes the future and a timeout counts as cancel', () async {
    final later = _FakeScanner();
    final pending = scanOnce(later);
    Timer.run(() => later.onEvent!(const ScanFound('X')));
    expect(await pending, _okWith('X'));

    expect(await scanOnce(_FakeScanner(), timeLimit: Duration.zero), _okWith(null));
  });
}

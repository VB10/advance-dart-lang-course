import 'dart:async';

import 'package:dartadvance_examples/06_event_loop_future/callback_completer.dart';
import 'package:test/test.dart';

typedef _OnDone = void Function(String? city, Object? error);

final class _FakeLocationClient implements LegacyLocationClient {
  _FakeLocationClient(this._fire);
  final void Function(_OnDone onDone) _fire;

  @override
  void requestCity(_OnDone onDone) => _fire(onDone);
}

void main() {
  test('the future completes with the callback value', () async {
    final client = _FakeLocationClient((onDone) => Timer.run(() => onDone('Izmir', null)));
    expect(await currentCity(client), 'Izmir');
  });

  test('the future completes with the callback error', () {
    final client = _FakeLocationClient((onDone) => onDone(null, StateError('denied')));
    expect(currentCity(client), throwsA(isA<StateError>()));
  });

  test('the isCompleted guard ignores a second callback', () async {
    final client = _FakeLocationClient((onDone) {
      onDone('Izmir', null);
      onDone('Ankara', null);
    });
    expect(await currentCity(client), 'Izmir');
  });
}

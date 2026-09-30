import 'package:dartadvance_examples/03_class_modifiers/clock.dart';
import 'package:test/test.dart';

// This test file is another library, so `implements Clock` is allowed; `extends` is not.
final class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

void main() {
  test('an interface class with a default implementation is constructible', () {
    expect(const Clock().now(), isA<DateTime>());
  });

  test('another library can re-implement an interface class', () {
    final fixed = DateTime.utc(2026, 1, 1);
    final Clock clock = _FixedClock(fixed);
    expect(clock.now(), fixed);
  });
}

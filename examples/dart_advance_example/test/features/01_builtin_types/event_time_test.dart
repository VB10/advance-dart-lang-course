import 'package:dart_advance_example/features/01_builtin_types/model/event_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const iso = '2026-11-02T17:30:00Z';
  final event = EventTime();

  test('parse keeps a Z time in UTC', () {
    final time = event.startWrong(iso);
    expect(time.isUtc, isTrue);
    expect(event.label(time), '17:30');
  });

  test('toLocal moves it to the device time zone', () {
    final time = event.start(iso);
    expect(time.isUtc, isFalse);
    expect(time.isAtSameMomentAs(DateTime.utc(2026, 11, 2, 17, 30)), isTrue);
    expect(
      event.label(time),
      event.label(DateTime.utc(2026, 11, 2, 17, 30).toLocal()),
    );
  });
}

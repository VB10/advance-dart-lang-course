import 'package:dart_advance_example/features/01_builtin_types/model/resend_countdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final countdown = ResendCountdown();

  test('/ with round shows the wrong minute and no padding', () {
    expect(countdown.labelWrong(150), '3:30');
    expect(countdown.labelWrong(125), '2:5');
  });

  test('~/ and % give minute and padded second', () {
    expect(countdown.label(150), '2:30');
    expect(countdown.label(125), '2:05');
    expect(countdown.label(59), '0:59');
    expect(countdown.label(0), '0:00');
  });
}

import 'package:dartadvance_examples/01_builtin_types/practice/ex1_floor_division.dart';
import 'package:test/test.dart';

void main() {
  test('floorDiv rounds down where ~/ truncates toward zero', () {
    expect(-7 ~/ 2, -3);
    expect(floorDiv(-7, 2), -4);
    expect(floorDiv(7, 2), 3);
    expect(floorDiv(-6, 2), -3);
  });

  test('floorDiv rejects a non-positive divisor', () {
    expect(() => floorDiv(1, 0), throwsArgumentError);
    expect(() => floorDiv(1, -2), throwsArgumentError);
  });

  test('weekdayIndex stays in 0..6 for negative offsets, unlike remainder', () {
    expect(weekdayIndex(-1), 6);
    expect(weekdayIndex(-8), 6);
    expect(weekdayIndex(9), 2);
    expect((-1).remainder(7), -1);
  });
}

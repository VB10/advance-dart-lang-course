import 'package:dartadvance_examples/02_typedefs/practice/ex3_rating_summary.dart';
import 'package:test/test.dart';

void main() {
  test('int and double scores are both counted; malformed rows skipped', () {
    final summary = summarize([
      {'score': 4},
      {'score': 4.5},
      {'score': '5'},
      {'rating': 5},
    ]);
    expect(summary.count, 2);
    expect(summary.skipped, 2);
    expect(summary.average, 4.25);
  });

  test('the average of ints is a double', () {
    final summary = summarize([
      {'score': 4},
      {'score': 5},
    ]);
    expect(summary.average, 4.5);
    expect(summary.average, isA<double>());
  });

  test('no valid rows gives 0.0, not a division error', () {
    final summary = summarize([]);
    expect(summary.average, 0.0);
    expect(summary.count, 0);
  });
}

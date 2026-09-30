import 'package:dartadvance_examples/09_isolates/practice/ex1_sorted_in_isolate.dart';
import 'package:test/test.dart';

void main() {
  test('the result is sorted and the caller list is untouched', () async {
    final input = [3, 1, 2];
    expect(await sortedInIsolate(input), [1, 2, 3]);
    expect(input, [3, 1, 2]);
  });

  test('an ArgumentError from the isolate keeps its type', () async {
    await expectLater(
      sortedInIsolate([]),
      throwsA(isA<ArgumentError>().having((error) => error.name, 'name', 'numbers')),
    );
  });
}

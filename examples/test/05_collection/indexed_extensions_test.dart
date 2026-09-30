import 'package:dartadvance_examples/05_collection/indexed_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('mapIndexed, whereIndexed, slices and none work with the index', () {
    final result = indexedOps(['a', 'b', 'c'], [1, 2, 3, 4, 5]);
    expect(result.labels, ['1. a', '2. b', '3. c']);
    expect(result.evens, ['a', 'c']);
    expect(result.pages, [
      [1, 2],
      [3, 4],
      [5],
    ]);
    expect(result.noneNegative, isTrue);
  });
}

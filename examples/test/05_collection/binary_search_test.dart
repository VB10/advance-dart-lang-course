import 'package:dartadvance_examples/05_collection/binary_search.dart';
import 'package:test/test.dart';

void main() {
  test('binarySearch finds an index or -1; lowerBound gives the insert point', () {
    expect(searchSorted([10, 20, 30, 40]), (found: 2, missing: -1, insertAt: 3));
  });
}

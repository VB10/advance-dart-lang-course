import 'package:dartadvance_examples/05_collection/splay_tree.dart';
import 'package:test/test.dart';

void main() {
  test('SplayTreeMap / SplayTreeSet iterate in sorted order and answer range queries', () {
    final index = PriceIndex()
      ..add(4500, 'mouse')
      ..add(1500, 'cable')
      ..add(9900, 'keyboard');
    expect(index.pricesAscending, [1500, 4500, 9900]);
    expect(index.cheapest, 'cable');
    expect(index.bestUnder(5000), 'mouse');
    expect(index.bestUnder(1000), isNull);
    expect(sortedTags(['dart', 'Async', 'flutter', 'DART']).toList(), ['Async', 'dart', 'flutter']);
  });
}

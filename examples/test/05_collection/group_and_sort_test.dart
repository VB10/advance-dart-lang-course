import 'package:dartadvance_examples/05_collection/group_by.dart';
import 'package:dartadvance_examples/05_collection/sorted_by.dart';
import 'package:test/test.dart';

const _sales = <Sale>[
  (city: 'IST', sku: 'a', amount: 30),
  (city: 'ANK', sku: 'b', amount: 10),
  (city: 'IST', sku: 'c', amount: 20),
];

void main() {
  test('groupListsBy equals groupBy; sortedBy returns a new list; compareNatural', () {
    final grouped = salesByCity(_sales);
    expect(grouped.keys, ['IST', 'ANK']);
    expect(grouped['IST']!.map((sale) => sale.sku), ['a', 'c']);
    expect(salesByCityFunction(_sales), grouped);
    expect(byAmount(_sales).map((sale) => sale.amount), [10, 20, 30]);
    expect(_sales.first.amount, 30); // source untouched
    expect(naturalOrder(['v10', 'v2', 'v1']), ['v1', 'v2', 'v10']);
    expect(['v10', 'v2', 'v1']..sort(), ['v1', 'v10', 'v2']); // plain lexical
  });
}

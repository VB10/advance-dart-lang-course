import 'package:dartadvance_examples/05_collection/order_rows_mapping.dart';
import 'package:test/test.dart';

void main() {
  test('rows are grouped per customer and sorted by total descending', () {
    const rows = <OrderRow>[
      (customer: 'ayse', orderId: 'o1', totalMinor: 100),
      (customer: 'can', orderId: 'o2', totalMinor: 300),
      (customer: 'ayse', orderId: 'o3', totalMinor: 500),
    ];
    final result = rowsByCustomer(rows);
    expect(result.keys, ['ayse', 'can']);
    expect(result['ayse']!.map((row) => row.orderId), ['o3', 'o1']);
  });
}

import 'package:dartadvance_examples/04_libraries_metadata/part_demo/order_builder.dart';
import 'package:test/test.dart';

void main() {
  test('a part file shares private members and imports with its library', () {
    final order = OrderBuilder()
      ..add('apple', quantity: 3)
      ..add('pear');

    expect(order.skus, ['apple', 'pear']);
    expect(order.totalQuantity, 4);
  });
}

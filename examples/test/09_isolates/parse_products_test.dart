import 'dart:convert';

import 'package:dartadvance_examples/09_isolates/parse_products.dart';
import 'package:test/test.dart';

void main() {
  test('parseProducts maps valid JSON and rejects bad rows and non-lists', () {
    final body = jsonEncode([
      {'id': 0, 'name': 'Product 0', 'price': 0},
      {'id': 1, 'name': 'Product 1', 'price': 1.5},
    ]);
    expect(parseProducts(body).map((product) => product.name), ['Product 0', 'Product 1']);
    expect(() => parseProducts('[{"id":"1"}]'), throwsFormatException);
    expect(() => parseProducts('{}'), throwsFormatException);
  });
}

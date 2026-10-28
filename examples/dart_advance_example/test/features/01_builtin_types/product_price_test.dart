import 'package:dart_advance_example/features/01_builtin_types/model/product_price.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final price = ProductPrice();

  test('double toString shows a raw number', () {
    expect(price.labelWrong(1250000), '1250000.0 ₺');
    expect(price.labelWrong(1499.9), '1499.9 ₺');
  });

  test('int cents formats lira, kuruş and thousands', () {
    expect(price.label(125000000), '1.250.000,00 ₺');
    expect(price.label(149990), '1.499,90 ₺');
    expect(price.label(5), '0,05 ₺');
  });
}

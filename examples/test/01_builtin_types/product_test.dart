import 'package:dartadvance_examples/01_builtin_types/price_format.dart';
import 'package:dartadvance_examples/01_builtin_types/product_json.dart';
import 'package:test/test.dart';

void main() {
  test('an integral JSON field stays int and a num field becomes double', () {
    final tea = productFromJson('{"id": 1, "name": "Tea", "price_minor": 4550, "rating": 4}');
    expect(tea.priceMinor, 4550);
    expect(tea.rating, 4.0);
    expect(tea.rating, isA<double>());
    final cup = productFromJson('{"id": 2, "name": "Cup", "price_minor": 100, "rating": null}');
    expect(cup.rating, isNull);
  });

  test('a double where an int is required is rejected', () {
    expect(
      () => productFromJson('{"id": 1, "name": "Tea", "price_minor": 45.5, "rating": 4}'),
      throwsFormatException,
    );
  });

  test('formatPrice uses exact integer arithmetic', () {
    expect(formatPrice(4550), '45,50 ₺');
    expect(formatPrice(7), '0,07 ₺');
  });
}

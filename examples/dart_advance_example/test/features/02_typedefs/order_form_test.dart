import 'package:dart_advance_example/features/02_typedefs/model/order_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inline and typedef versions give the same errors', () {
    const form = OrderForm(name: '', quantity: 0, price: 12.5);
    String? name(String? v) => (v == null || v.isEmpty) ? 'name' : null;
    String? quantity(int? v) => (v == null || v < 1) ? 'quantity' : null;
    String? price(double? v) => (v == null || v <= 0) ? 'price' : null;

    expect(form.errors(name, quantity, price), ['name', 'quantity']);
    expect(form.errorsWrong(name, quantity, price), ['name', 'quantity']);
    expect(name, isA<Validator<String>>());
  });
}

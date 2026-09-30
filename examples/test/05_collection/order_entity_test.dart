import 'package:dartadvance_examples/05_collection/order_entity.dart';
import 'package:test/test.dart';

void main() {
  test('entity equality compares list contents and hashCode agrees', () {
    final a = Order(id: '1', skus: ['x', 'y']);
    final b = Order(id: '1', skus: ['x', 'y']);
    expect(a == b, isTrue);
    expect(a.hashCode, b.hashCode);
    expect({a, b}.length, 1);
    expect(Order(id: '1', skus: ['y', 'x']) == a, isFalse);
    expect(() => a.skus.add('z'), throwsUnsupportedError);
  });
}

import 'package:dart_advance_example/features/03_class_design/model/invoice_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('identical says false for equal values, == says true', () {
    final a = InvoiceItem('Kalem', 2, 500);
    final b = InvoiceItem('Kalem', 2, 500);
    expect(a.sameAsWrong(b), isFalse);
    expect(a.sameAs(b), isTrue);
    expect(a.hashCode, b.hashCode);
    expect(a.sameAs(InvoiceItem('Kalem', 3, 500)), isFalse);
  });
}

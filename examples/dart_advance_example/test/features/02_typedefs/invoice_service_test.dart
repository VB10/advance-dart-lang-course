import 'package:dart_advance_example/features/02_typedefs/model/invoice_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('alias accepts swapped ints, extension type exposes .value', () {
    final service = InvoiceService();
    const OrderIdAlias customerNo = 1042;
    const CustomerIdAlias orderNo = 7;
    expect(OrderIdAlias, int);
    expect(
      service.invoiceWrong(customerNo, orderNo),
      'Sipariş #1042, müşteri #7',
    );
    expect(
      service.invoice(OrderId(7), CustomerId(1042)),
      'Sipariş #7, müşteri #1042',
    );
    expect(OrderId(7).value, 7);
  });
}

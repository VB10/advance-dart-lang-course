import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_advance_example/features/02_typedefs/model/invoice_lines.dart';
import 'package:dart_advance_example/features/02_typedefs/model/invoice_service.dart';
import 'package:dart_advance_example/features/02_typedefs/model/order_form.dart';

/// Builds the cards shown on the typedefs page.
final class TypedefsExamples {
  List<TopicExample> build() {
    const form = OrderForm(name: '', quantity: 0, price: 12.5);
    String? nameRule(String? v) =>
        (v == null || v.isEmpty) ? 'Ürün adı boş' : null;
    String? quantityRule(int? v) =>
        (v == null || v < 1) ? 'Adet en az 1' : null;
    String? priceRule(double? v) =>
        (v == null || v <= 0) ? 'Fiyat 0 üstü' : null;

    final rows = <Map<String, Object?>>[
      {'name': 'Kalem', 'price': 4},
      {'name': 'Defter', 'price': 12.5},
    ];
    final lines = InvoiceLines();
    var wrongTotal = '';
    try {
      wrongTotal = '${lines.totalWrong(rows)}';
    } on TypeError catch (error) {
      wrongTotal = 'TypeError: ${error.toString().split('\n').first}';
    }

    final orderNo = 7;
    final customerNo = 1042;
    final service = InvoiceService();

    return [
      TopicExample(
        title: '1) Fonksiyon typedef\'i',
        negative: Text(
          '${form.errorsWrong(nameRule, quantityRule, priceRule)}',
        ),
        positive: Text('${form.errors(nameRule, quantityRule, priceRule)}'),
      ),
      TopicExample(
        title: '2) Json alias',
        negative: Text(wrongTotal),
        positive: Text('Toplam ${lines.total(rows)}'),
      ),
      TopicExample(
        title: '3) Alias yeni tip değildir',
        negative: Text(service.invoiceWrong(customerNo, orderNo)),
        positive: Text(
          service.invoice(OrderId(orderNo), CustomerId(customerNo)),
        ),
      ),
    ];
  }
}

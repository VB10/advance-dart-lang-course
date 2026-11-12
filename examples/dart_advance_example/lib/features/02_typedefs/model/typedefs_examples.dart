import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_advance_example/features/02_typedefs/model/invoice_lines.dart';
import 'package:dart_advance_example/features/02_typedefs/model/invoice_service.dart';
import 'package:dart_advance_example/features/02_typedefs/model/order_form.dart';
import 'package:dart_advance_example/features/02_typedefs/model/record_point.dart';
import 'package:dart_advance_example/features/02_typedefs/model/transfer.dart';
import 'package:dart_advance_example/features/02_typedefs/model/stock_service.dart';
import 'package:dart_advance_example/features/02_typedefs/model/cart_line.dart';

/// Builds the cards shown on the typedefs page.
final class TypedefsExamples {
  List<TopicExample> build() {
    final map = StoreMap();
    final transferScreen = TransferScreen();
    final stockService = StockService();
    const line = CartLine(name: 'Kalem', qty: 3, cents: 450, discount: 50);
    const wrongLine = ('Kalem', 3, 450, 50);

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
      TopicExample(
        title: '4) Record alias',
        negative: Text('Enlem ${map.storeWrong().$1}'),
        positive: Text('Enlem ${map.store().lat}, boylam ${map.store().lng}'),
      ),
      TopicExample(
        title: '5) İsimli parametre',
        negative: Text(transferScreen.sendWrong(transferScreen.moveWrong)),
        positive: Text(transferScreen.send(transferScreen.transfer)),
      ),
      TopicExample(
        title: '6) AsyncResult',
        negative: FutureBuilder<Result<int>>(
          future: stockService.stockWrong('kalem'),
          builder: (_, snap) =>
              Text(snap.hasData ? stockService.describe(snap.data!) : '…'),
        ),
        positive: FutureBuilder<Result<int>>(
          future: stockService.stock('kalem'),
          builder: (_, snap) =>
              Text(snap.hasData ? stockService.describe(snap.data!) : '…'),
        ),
      ),
      TopicExample(
        title: '7) Record mu class mı',
        negative: Text('Satır toplamı ${CartLine.totalWrong(wrongLine)} kuruş'),
        positive: Text('Satır toplamı ${line.total} kuruş'),
      ),
    ];
  }
}

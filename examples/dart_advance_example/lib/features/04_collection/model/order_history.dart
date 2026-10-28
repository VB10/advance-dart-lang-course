import 'package:collection/collection.dart';

/// Sipariş geçmişi: siparişler ay başlıkları altında; API durumuna göre sıralı gönderir.
final class Order {
  const Order(this.no, this.month);

  final String no;
  final String month;
}

final class OrderHistory {
  // Olumsuz: ay değişince yeni başlık; liste tarihe göre sıralı değilse 'Ekim' iki kez çıkar.
  List<(String, List<Order>)> sectionsWrong(List<Order> orders) {
    final sections = <(String, List<Order>)>[];
    for (final order in orders) {
      if (sections.isEmpty || sections.last.$1 != order.month) {
        sections.add((order.month, []));
      }
      sections.last.$2.add(order);
    }
    return sections;
  }

  // Olumlu: groupBy her ayı bir anahtar yapar; sıra bozuk gelse de her ay bir kez.
  List<(String, List<Order>)> sections(List<Order> orders) => [
    for (final MapEntry(:key, :value) in groupBy(
      orders,
      (o) => o.month,
    ).entries)
      (key, value),
  ];
}

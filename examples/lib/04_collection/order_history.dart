// Düzelt: /dartadvance Projemde listeyi tarih, kategori ya da durum başlıkları altında gösteren
//    ve gruplamayı elle (önceki elemanla karşılaştırarak ya da Map kurarak) yapan yerleri bul.
//    groupBy ile düzelt, sırasız girdiyle test yaz.
// Üret: /dartadvance Bana sipariş geçmişini ay başlıkları altında gösteren bir bölüm listesi
//    kuran sınıf yaz.
import 'package:collection/collection.dart';

/// One order in the order history.
final class Order {
  const Order(this.no, this.month);

  final String no;
  final String month;
}

/// Order history under month headers; the API sorts by status, not by date.
final class OrderHistory {
  // ✗ A new header whenever the month changes: unsorted input shows 'Ekim' twice.
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

  List<(String, List<Order>)> sections(List<Order> orders) => [
    for (final MapEntry(:key, :value) in groupBy(orders, (o) => o.month).entries) (key, value),
  ]; // each month once
}

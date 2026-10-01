// Düzelt: /dartadvance Projemde `list.sort()` ile yerinde sıralayan veya elle gruplayan
//    yerleri bul, `sortedBy`/`groupListsBy` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana kullanıcı listesini şehre göre gruplayıp her şehirde en yeni
//    üyeyi ilk gösteren bir fonksiyon yaz.
import 'package:collection/collection.dart';

typedef Order = ({String city, String sku, int amount});

Map<String, List<Order>> ordersByCity(Iterable<Order> orders) =>
    orders.groupListsBy((order) => order.city);

List<Order> sortInPlace(List<Order> orders) =>
    orders..sort((a, b) => b.amount.compareTo(a.amount)); // mutates the input

List<Order> biggestFirst(Iterable<Order> orders) =>
    orders.sortedByCompare((order) => order.amount, (a, b) => b.compareTo(a)); // input untouched

List<String> numberedLines(List<Order> orders) =>
    orders.mapIndexed((index, order) => '${index + 1}. ${order.sku}').toList();

List<String> versionsInOrder(Iterable<String> versions) =>
    versions.sorted(compareNatural); // v2 before v10

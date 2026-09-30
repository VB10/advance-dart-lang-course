import 'package:collection/collection.dart';

typedef Order = ({String city, String sku, int amount});

Map<String, List<Order>> ordersByCity(Iterable<Order> orders) =>
    orders.groupListsBy((order) => order.city);

// Returns a new list; core List.sort sorts in place and returns void.
List<Order> biggestFirst(Iterable<Order> orders) =>
    orders.sortedByCompare((order) => order.amount, (a, b) => b.compareTo(a));

List<String> numberedLines(List<Order> orders) =>
    orders.mapIndexed((index, order) => '${index + 1}. ${order.sku}').toList();

List<String> versionsInOrder(Iterable<String> versions) => versions.sorted(compareNatural);

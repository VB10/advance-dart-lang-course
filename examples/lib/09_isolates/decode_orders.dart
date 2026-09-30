import 'dart:convert';
import 'dart:isolate';

final class Order {
  const Order({required this.id, required this.total});
  final int id;
  final double total;
}

/// Small bodies parse inline; the closure captures only `body`.
Future<List<Order>> decodeOrders(String body, {int isolateThreshold = 50 * 1024}) async {
  if (body.length < isolateThreshold) return parseOrders(body);
  return Isolate.run(() => parseOrders(body), debugName: 'parseOrders');
}

/// Pure and top-level: safe to run on any isolate.
List<Order> parseOrders(String body) {
  final rows = jsonDecode(body) as List<Object?>;
  return [
    for (final row in rows.cast<Map<String, Object?>>())
      Order(id: row['id']! as int, total: (row['total']! as num).toDouble()),
  ];
}

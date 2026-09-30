import 'dart:convert';

import 'product_domain.dart';

/// Pure, synchronous and top-level: safe to run on any isolate.
List<Product> parseProducts(String body) => switch (jsonDecode(body)) {
  final List<Object?> rows => rows.map(_parseRow).toList(),
  final other => throw FormatException('Expected a JSON list, got ${other.runtimeType}'),
};

Product _parseRow(Object? row) => switch (row) {
  {'id': final int id, 'name': final String name, 'price': final num price} => Product(
    id: id,
    name: name,
    price: price.toDouble(),
  ),
  _ => throw FormatException('Bad product row: $row'),
};

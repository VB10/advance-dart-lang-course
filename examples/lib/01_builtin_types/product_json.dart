import 'dart:convert';

import 'never_helper.dart';
import 'product.dart';

Product productFromJson(String source) {
  final Object? decoded = jsonDecode(source);
  if (decoded case {
    'id': int id,
    'name': String name,
    'price_minor': int priceMinor,
    'rating': num? rating,
  }) {
    return Product(id: id, name: name, priceMinor: priceMinor, rating: rating?.toDouble());
  }
  fail('Malformed product: $source'); // Never: no `return` needed after it.
}

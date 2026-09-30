import 'dart:collection';

import 'package:dartadvance_examples/05_collection/literal_insertion_order.dart';
import 'package:test/test.dart';

void main() {
  test('literals are LinkedHashMap / LinkedHashSet and keep insertion order', () {
    expect(<String, int>{}, isA<LinkedHashMap<String, int>>());
    expect(<String>{}, isA<LinkedHashSet<String>>());
    final order = literalOrder();
    expect(order.mapKeys, ['zeynep', 'ali', 'mert', 'bora']);
    expect(order.setElements, ['flutter', 'dart', 'async']);
  });
}

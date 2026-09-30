import 'dart:collection';

final class CartState {
  final List<String> _items = [];

  UnmodifiableListView<String> get items => UnmodifiableListView(_items);

  void add(String sku) => _items.add(sku);
}

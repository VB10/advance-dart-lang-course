import 'dart:collection';

final class CartState {
  CartState(List<String> skus) : skus = List.unmodifiable(skus);

  // A copy: later changes to the caller's list do not leak in.
  final List<String> skus;

  CartState add(String sku) => CartState([...skus, sku]);
}

final class CartViewModel {
  final List<String> _skus = [];

  // A live view: read-only for callers, but follows _skus.
  List<String> get skus => UnmodifiableListView(_skus);

  void add(String sku) => _skus.add(sku);
}

// Düzelt: /dartadvance Projemde state/ViewModel'de `List` alanını doğrudan saklayan ya da
//    açan yerleri bul, `List.unmodifiable`/`UnmodifiableListView` ile düzelt, test yaz.
// Üret: /dartadvance Bana ürün listesi tutan bir sepet state'i ve listeyi salt-okunur açan
//    bir ViewModel yaz.
import 'dart:collection';

final class LeakyCart {
  LeakyCart(this.skus);

  final List<String> skus; // caller's later add() changes this state
}

final class CartState {
  CartState(List<String> skus) : skus = List.unmodifiable(skus);

  final List<String> skus; // a copy: nothing leaks in

  CartState add(String sku) => CartState([...skus, sku]);
}

final class CartViewModel {
  final List<String> _skus = [];

  List<String> get skus => UnmodifiableListView(_skus); // live read-only view

  void add(String sku) => _skus.add(sku);
}

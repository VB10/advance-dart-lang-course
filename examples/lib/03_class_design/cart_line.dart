// Düzelt: /dartadvance Projemde state ve değer nesnesi sınıflarında final olmayan alanları ve
//    bu alanları yerinde değiştirip aynı nesneyi yeniden yayınlayan yerleri bul. @immutable ve
//    copyWith ile düzelt, yeni nesnenin yayınlandığını test et.
// Üret: /dartadvance Bana sepet satırı için @immutable bir state sınıfı ve adet artıran,
//    her değişiklikte yeni nesne yayınlayan bir store yaz.
import 'package:meta/meta.dart';

/// A cart line; the screen shows the quantity of the last published line.
@immutable
final class CartLine {
  const CartLine(this.name, this.quantity);

  final String name;
  final int quantity;

  @useResult
  CartLine copyWith({int? quantity}) => CartLine(name, quantity ?? this.quantity);
}

// ✗ A mutable field; @immutable reports it, the ignore hides the warning.
@immutable
// ignore: must_be_immutable
final class CartLineWrong {
  CartLineWrong(this.name, this.quantity);

  final String name;
  int quantity;
}

/// Publishes a new line only when it is a different object (like ValueNotifier).
final class CartStore<T> {
  CartStore(this._line, this.render) : shown = render(_line);

  T _line;

  /// Builds the text the screen shows for a line.
  final String Function(T line) render;

  /// What the screen last rebuilt with.
  String shown;

  T get line => _line;

  set line(T next) {
    if (identical(next, _line)) return; // same object: no rebuild
    _line = next;
    shown = render(next);
  }
}

final class QuantityButton {
  // ✗ Mutates in place and republishes the same object: the screen is not rebuilt.
  void increaseWrong(CartStore<CartLineWrong> store) {
    store.line.quantity++;
    store.line = store.line;
  }

  void increase(CartStore<CartLine> store) =>
      store.line = store.line.copyWith(quantity: store.line.quantity + 1);
}

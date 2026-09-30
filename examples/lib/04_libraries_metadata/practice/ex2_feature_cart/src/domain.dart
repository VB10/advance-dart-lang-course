import 'package:meta/meta.dart';

import '../../../../00_architecture/result.dart';

@immutable
final class CartItem {
  const CartItem(this.sku, this.quantity);
  final String sku;
  final int quantity;
}

abstract interface class CartRepository {
  /// Adds [item] and returns the new total quantity of the cart.
  Future<Result<int>> add(CartItem item);
}

final class AddToCart {
  const AddToCart(this._repository);
  final CartRepository _repository;

  Future<Result<int>> call(String sku, {int quantity = 1}) =>
      _repository.add(CartItem(sku, quantity));
}

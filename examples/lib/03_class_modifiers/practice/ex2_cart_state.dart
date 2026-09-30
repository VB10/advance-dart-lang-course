import '../../00_architecture/result.dart';

abstract interface class CartRepository {
  Future<Result<int>> addItem(String sku);
}

sealed class CartState {
  const CartState();
}

final class CartIdle extends CartState {
  const CartIdle(this.itemCount);
  final int itemCount;
}

final class CartAdding extends CartState {
  const CartAdding();
}

final class CartFailed extends CartState {
  const CartFailed(this.failure);
  final Failure failure;
}

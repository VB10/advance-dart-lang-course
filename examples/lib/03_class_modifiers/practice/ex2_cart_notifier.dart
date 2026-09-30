import '../../00_architecture/result.dart';
import '../state_notifier.dart';
import 'ex2_cart_state.dart';

final class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._repository) : super(const CartIdle(0));
  final CartRepository _repository;

  Future<void> add(String sku) async {
    emit(const CartAdding());
    final result = await _repository.addItem(sku);
    emit(switch (result) {
      Ok(:final value) => CartIdle(value),
      Err(:final failure) => CartFailed(failure),
    });
  }
}

String cartBadge(CartState state) => switch (state) {
  CartIdle(itemCount: 0) => 'Empty',
  CartIdle(:final itemCount) => '$itemCount item(s)',
  CartAdding() => 'Adding...',
  CartFailed(failure: NetworkFailure()) => 'Offline',
  CartFailed(failure: ServerFailure(:final statusCode)) => 'Error $statusCode',
  CartFailed(failure: UnexpectedFailure()) => 'Try again',
};

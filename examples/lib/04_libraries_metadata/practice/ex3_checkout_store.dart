import '../../00_architecture/result.dart';
import '../metadata/store.dart';
import 'ex3_checkout_state.dart';

/// `Store` is `base` in another library, so this class must be `base`, `final` or `sealed`.
final class CheckoutStore extends Store<CheckoutState> {
  CheckoutStore(this._charge) : super(const CheckoutIdle());
  final Future<Result<String>> Function(int amountCents) _charge;

  bool _closed = false;

  Future<void> pay(int amountCents) async {
    if (_closed) return;
    emit(const CheckoutSubmitting());
    final result = await _charge(amountCents);
    if (_closed) return;
    emit(switch (result) {
      Ok(:final value) => CheckoutPaid(value),
      Err(:final failure) => CheckoutFailed(failure.message),
    });
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}

String checkoutLabel(CheckoutState state) => switch (state) {
  CheckoutIdle() => 'Pay',
  CheckoutSubmitting() => 'Paying...',
  CheckoutPaid(:final receiptId) => 'Paid: $receiptId',
  CheckoutFailed(:final message) => 'Retry ($message)',
};

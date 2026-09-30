import 'package:meta/meta.dart';

@immutable
sealed class CheckoutState {
  const CheckoutState();
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

final class CheckoutPaid extends CheckoutState {
  const CheckoutPaid(this.receiptId);
  final String receiptId;
}

final class CheckoutFailed extends CheckoutState {
  const CheckoutFailed(this.message);
  final String message;
}

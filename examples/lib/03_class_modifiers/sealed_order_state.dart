sealed class OrderState {
  const OrderState();
}

final class OrderPlaced extends OrderState {
  const OrderPlaced();
}

final class OrderShipped extends OrderState {
  const OrderShipped(this.trackingCode);
  final String trackingCode;
}

final class OrderCancelled extends OrderState {
  const OrderCancelled(this.reason);
  final String reason;
}

// No `_` case: adding a subtype makes this switch a compile error.
String statusText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  OrderShipped(:final trackingCode) => 'On the way: $trackingCode',
  OrderCancelled(:final reason) => 'Cancelled: $reason',
};

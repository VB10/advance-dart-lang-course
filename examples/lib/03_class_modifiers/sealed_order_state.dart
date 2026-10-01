// /dartadvance Projemde durumları `_` ya da default ile eşleyen switch'leri bul, `sealed`
// aile + `_`'siz switch ile düzelt, her biri için test yaz.
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

String lazyText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  _ => 'Unknown', // cancelled order: 'Unknown'
};

String statusText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  OrderShipped(:final trackingCode) => 'On the way: $trackingCode',
  OrderCancelled(:final reason) => 'Cancelled: $reason',
};

// Düzelt: /dartadvance Projemde durumu `_`/default'lu switch ya da if-else zinciriyle
//    ayıran yerleri bul, `sealed` aile + `_`'siz switch ile düzelt, test yaz.
// Üret: /dartadvance Bana ödeme sonucunu (başarılı, reddedildi, beklemede) ekran metnine
//    çeviren bir fonksiyon yaz.

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

// ✗ kopyalama: `_` yeni durumu sessizce yutar
String lazyText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  _ => 'Unknown', // cancelled order: 'Unknown'
};

String statusText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  OrderShipped(:final trackingCode) => 'On the way: $trackingCode',
  OrderCancelled(:final reason) => 'Cancelled: $reason',
};

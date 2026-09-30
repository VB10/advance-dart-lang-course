sealed class PaymentMethod {
  const PaymentMethod();
}

final class CardPayment extends PaymentMethod {
  const CardPayment(this.last4);
  final String last4;
}

final class CashPayment extends PaymentMethod {
  const CashPayment();
}

final class WalletPayment extends PaymentMethod {
  const WalletPayment(this.provider);
  final String provider;
}

int feeMinor(PaymentMethod method, int amountMinor) => switch (method) {
  CardPayment() => amountMinor * 2 ~/ 100,
  CashPayment() => 0,
  WalletPayment(provider: 'promo') => 0,
  WalletPayment() => 50,
};

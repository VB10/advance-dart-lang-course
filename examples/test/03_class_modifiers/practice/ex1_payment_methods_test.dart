import 'package:dartadvance_examples/03_class_modifiers/practice/ex1_payment_methods.dart';
import 'package:test/test.dart';

void main() {
  test('every payment method has a fee without a default case', () {
    expect(feeMinor(const CardPayment('4242'), 10000), 200);
    expect(feeMinor(const CashPayment(), 10000), 0);
    expect(feeMinor(const WalletPayment('acme'), 10000), 50);
  });

  test('a more specific pattern wins before the general wallet case', () {
    expect(feeMinor(const WalletPayment('promo'), 10000), 0);
    expect(const WalletPayment('promo'), isA<PaymentMethod>());
  });
}

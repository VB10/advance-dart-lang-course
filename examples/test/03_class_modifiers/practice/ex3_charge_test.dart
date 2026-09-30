import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/03_class_modifiers/practice/ex1_payment_methods.dart';
import 'package:dartadvance_examples/03_class_modifiers/practice/ex3_charge.dart';
import 'package:test/test.dart';

void main() {
  test('valid JSON becomes a Charge with the method fee', () {
    final result = decodeCharge({'type': 'card', 'last4': '4242', 'amount_minor': 1999});
    expect(result, isA<Ok<Charge>>());
    final charge = (result as Ok<Charge>).value;
    expect(charge.method, isA<CardPayment>());
    expect(charge.totalMinor, 1999 + 39);
    expect(chargeLabel({'type': 'cash', 'amount_minor': 505}), '5,05');
  });

  test('a double amount or an unknown type is an Err', () {
    expect(decodeCharge({'type': 'cash', 'amount_minor': 19.99}), isA<Err<Charge>>());
    expect(decodeCharge({'type': 'crypto', 'amount_minor': 100}), isA<Err<Charge>>());
    expect(
      decodeCharge({'type': 'card', 'last4': '42', 'amount_minor': 100}),
      isA<Err<Charge>>(),
    );
    expect(chargeLabel({'type': 'cash'}), 'Unexpected error');
  });

  test('wallet fee is added to the label', () {
    expect(chargeLabel({'type': 'wallet', 'provider': 'acme', 'amount_minor': 1000}), '10,50');
  });
}

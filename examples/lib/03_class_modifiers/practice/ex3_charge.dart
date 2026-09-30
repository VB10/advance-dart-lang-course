import '../../00_architecture/result.dart';
import '../../02_typedefs/json_alias.dart';
import 'ex1_payment_methods.dart';

final class Charge {
  const Charge(this.method, this.amountMinor);
  final PaymentMethod method;
  final int amountMinor;

  int get totalMinor => amountMinor + feeMinor(method, amountMinor);
}

PaymentMethod? _method(Json json) => switch (json) {
  {'type': 'card', 'last4': String last4} when last4.length == 4 => CardPayment(last4),
  {'type': 'cash'} => const CashPayment(),
  {'type': 'wallet', 'provider': String provider} => WalletPayment(provider),
  _ => null,
};

Result<Charge> decodeCharge(Json json) {
  final method = _method(json);
  final amountMinor = switch (json['amount_minor']) {
    int value when value >= 0 => value,
    _ => null,
  };
  if (method == null || amountMinor == null) {
    return Err(UnexpectedFailure(FormatException('Bad charge: $json'), StackTrace.current));
  }
  return Ok(Charge(method, amountMinor));
}

String _formatMinor(int minor) => '${minor ~/ 100},${(minor % 100).toString().padLeft(2, '0')}';

String chargeLabel(Json json) => switch (decodeCharge(json)) {
  Ok(value: Charge(:final totalMinor)) => _formatMinor(totalMinor),
  Err(:final failure) => failure.message,
};

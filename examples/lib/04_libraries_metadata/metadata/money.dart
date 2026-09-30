import 'package:meta/meta.dart';

@immutable
final class Money {
  const Money(this.cents, this.currency);
  final int cents;
  final String currency;

  /// Returns a new value: `total.add(fee);` alone is reported.
  @useResult
  Money add(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(other.currency, 'other', 'Currency mismatch');
    }
    return Money(cents + other.cents, currency);
  }
}

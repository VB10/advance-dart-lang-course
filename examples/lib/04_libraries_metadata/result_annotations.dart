// /dartadvance Projemde değer nesnesi sınıfları ve sonucu atılabilen metotları bul,
// `@immutable` ve `@useResult` ekle, her biri için test yaz.
import 'package:meta/meta.dart';

// The analyzer warns if a field here is not final.
@immutable
final class Money {
  const Money(this.cents, this.currency);
  final int cents;
  final String currency;

  // `total.add(fee);` alone is reported: the result is dropped.
  @useResult
  Money add(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(other.currency, 'other', 'Currency mismatch');
    }
    return Money(cents + other.cents, currency);
  }
}

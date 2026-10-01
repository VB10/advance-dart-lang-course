// Düzelt: /dartadvance Projemde değer nesnesi sınıfları ve sonucu atılabilen metotları bul,
//    `@immutable` ve `@useResult` ekle, her biri için test yaz.
// Üret: /dartadvance Bana tutar ve birimi tutan, iki fiyatı toplayıp yeni fiyat döndüren
//    bir Price sınıfı yaz.
import 'package:meta/meta.dart';

// ✗ int cents;  // analyzer: must_be_immutable, a non-final field in an @immutable class

@immutable
final class Money {
  const Money(this.cents, this.currency);
  final int cents;
  final String currency;

  // ✗ total.add(fee);  // analyzer: unused_result, the new Money is dropped, total is unchanged
  @useResult
  Money add(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(other.currency, 'other', 'Currency mismatch');
    }
    return Money(cents + other.cents, currency);
  }
}

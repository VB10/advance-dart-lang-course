// Düzelt: /dartadvance Projemde alt tiplenmemesi gereken değer sınıflarını bul, `final
//    class` + `==`/`hashCode` ile düzelt, test yaz.
// Üret: /dartadvance Bana faturadaki bir kalemi (ürün adı, adet, birim fiyat) tutan,
//    eşitlik karşılaştırılabilen sınıf yaz.

// `final`: others can construct it; `extends`/`implements` is an analyzer error.
final class Money {
  const Money(this.cents, this.currency);

  final int cents;
  final String currency;

  Money operator +(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return Money(cents + other.cents, currency); // 100 + 250 TRY: 350
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.cents == cents && other.currency == currency;

  @override
  int get hashCode => Object.hash(cents, currency);
}

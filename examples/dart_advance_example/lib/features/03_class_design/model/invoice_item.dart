/// Faturadaki bir kalemi (ürün adı, adet, birim fiyat) tutan değer sınıfı.
final class InvoiceItem {
  InvoiceItem(this.productName, this.quantity, this.unitCents);

  final String productName;
  final int quantity;
  final int unitCents;

  // Olumsuz: `identical` referansa bakar (== override'sız hali); aynı değerli kalemler → false.
  bool sameAsWrong(InvoiceItem other) => identical(this, other);

  // Olumlu: `==`/`hashCode` değere bakar; `final` olduğu için alt sınıf bunu bozamaz → true.
  bool sameAs(InvoiceItem other) => this == other;

  @override
  bool operator ==(Object other) =>
      other is InvoiceItem &&
      other.productName == productName &&
      other.quantity == quantity &&
      other.unitCents == unitCents;

  @override
  int get hashCode => Object.hash(productName, quantity, unitCents);
}

typedef LineWrong = (String, int, int, int);

/// Sepet ekranında bir satırın toplamını hesaplayan model.
final class CartLine {
  const CartLine({
    required this.name,
    required this.qty,
    required this.cents,
    required this.discount,
  });

  final String name;
  final int qty;
  final int cents;
  final int discount;

  // Olumlu: alanlar isimli; toplam 3 × 450 − 50 = 1300 kuruş.
  int get total => qty * cents - discount;

  // Olumsuz: (ad, adet, kuruş, indirim) record'unda `$4` indirimi adetle çarpar → 150 kuruş.
  static int totalWrong(LineWrong line) => line.$2 * line.$4;
}

// Düzelt: /dartadvance Projemde 3'ten fazla alanlı ya da aynı türden alanları olan record
//    alias'larını bul, sınıfa çevir, alanları isimlendir, test yaz.
// Üret: /dartadvance Bana sepet satırını (ad, adet, kuruş, indirim) tutan ve satır toplamını
//    hesaplayan bir sınıf yaz.
typedef LineWrong = (String, int, int, int); // name, qty, cents, discount: three ints in a row

LineWrong wrongLine() => ('Kalem', 3, 450, 50);
int totalWrong(LineWrong line) => line.$2 * line.$4; // qty * discount: 150, not 1300

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

  int get total => qty * cents - discount; // 3 * 450 - 50 = 1300
}

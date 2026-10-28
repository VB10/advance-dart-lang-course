// Düzelt: /dartadvance Projemde fiyatı double tutan ya da ekrana $price, toString veya
//    toStringAsFixed ile yazan yerleri bul. Kuruş int'e çevir, ~/ 100, % 100 ve binlik nokta ile
//    yazdır, 2499990 girdisiyle test yaz.
// Üret: /dartadvance Bana ürün kartı için fiyat etiketi yaz: kuruş int alsın, 24.999,90 ₺
//    biçiminde yazsın, eski fiyatı da göstersin.

/// Product card: sale price and the struck-through old price.
final class ProductPrice {
  // ✗ double.toString is not for screens: '24999.9 ₺', '29999.0 ₺'.
  String labelWrong(double price) => '$price ₺';

  String label(int cents) {
    final lira = '${cents ~/ 100}'.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+$)'),
      (_) => '.',
    );
    return '$lira,${(cents % 100).toString().padLeft(2, '0')} ₺'; // '24.999,90 ₺'
  }
}

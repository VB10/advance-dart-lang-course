/// Ürün kartında satış fiyatı ve üstü çizili eski fiyat.
final class ProductPrice {
  // Olumsuz: double'ın toString'i → '1250000.0 ₺', '1499.9 ₺'.
  String labelWrong(double price) => '$price ₺';

  // Olumlu: fiyat kuruş int; `~/ 100` lira, `% 100` kuruş, binlik nokta → '1.250.000,00 ₺'.
  String label(int cents) {
    final lira = '${cents ~/ 100}'.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+$)'),
      (_) => '.',
    );
    return '$lira,${(cents % 100).toString().padLeft(2, '0')} ₺';
  }
}

// Düzelt: /dartadvance Projemde sort karşılaştırıcısında çıkarma (a - b), toInt ya da round
//    kullanan yerleri ve kaynağı yerinde sıralayan sort çağrılarını bul. sortedBy / compareTo
//    ile düzelt, yakın fiyatlarla test yaz.
// Üret: /dartadvance Bana ürün listesini fiyata göre artan ve azalan sıralayan, kaynak listeyi
//    değiştirmeyen bir sınıf yaz.
import 'package:collection/collection.dart';

/// A product with its price.
final class Product {
  const Product(this.name, this.price);

  final String name;
  final double price;
}

/// "Fiyat: artan" sort on the product list.
final class PriceSort {
  // ✗ toInt turns 19.90 - 19.50 into 0: two prices count as equal, the order is wrong.
  List<Product> ascendingWrong(List<Product> products) =>
      [...products]..sort((a, b) => (a.price - b.price).toInt());

  List<Product> ascending(List<Product> products) =>
      products.sortedBy<num>((product) => product.price); // source untouched
}

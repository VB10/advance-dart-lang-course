import 'package:collection/collection.dart';

/// "Fiyata göre artan" sıralaması.
final class Product {
  const Product(this.name, this.price);

  final String name;
  final double price;
}

final class PriceSort {
  // Olumsuz: fark toInt ile int'e çevrilir; 19,90 ile 19,50 arası 0 olur → eşit sayılır, sıra bozuk.
  List<Product> ascendingWrong(List<Product> products) =>
      [...products]..sort((a, b) => (a.price - b.price).toInt());

  // Olumlu: sortedBy anahtarı compareTo ile karşılaştırır, kaynağa dokunmaz.
  List<Product> ascending(List<Product> products) =>
      products.sortedBy<num>((product) => product.price);
}

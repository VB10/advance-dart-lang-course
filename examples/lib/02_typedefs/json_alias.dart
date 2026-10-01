// /dartadvance Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı yerlerini
// bul, `typedef` alias ile düzelt, her biri için test yaz.
typedef Json = Map<String, Object?>;
typedef JsonList = List<Json>;
typedef Cache<T> = Map<String, List<T>>; // Cache<int> == Map<String, List<int>>

class Product {
  const Product(this.name, this.price);
  final String name;
  final double price;
}

Product productFromJson(Json json) =>
    Product(json['name']! as String, (json['price']! as num).toDouble()); // 4 -> 4.0

List<Product> productsFromJson(JsonList rows) => [
  for (final row in rows) productFromJson(row),
];

Json productToJson(Product product) => {
  'name': product.name,
  'price': product.price,
};

Cache<Product> groupByFirstLetter(List<Product> products) {
  final cache = <String, List<Product>>{};
  for (final product in products) {
    (cache[product.name[0]] ??= []).add(product);
  }
  return cache;
}

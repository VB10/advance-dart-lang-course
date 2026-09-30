import '../00_architecture/result.dart';

final class Product {
  const Product({required this.id, required this.name, required this.price});
  final int id;
  final String name;
  final double price;
}

abstract interface class ProductRepository {
  Future<Result<List<Product>>> getProducts();
}

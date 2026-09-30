import '../00_architecture/result.dart';

final class Product {
  const Product({required this.id, required this.name});
  final int id;
  final String name;
}

abstract interface class ProductRepository {
  Future<Result<List<Product>>> search(String query);
}

final class SearchProducts {
  const SearchProducts(this._repository);
  final ProductRepository _repository;

  Future<Result<List<Product>>> call(String query) => _repository.search(query);
}

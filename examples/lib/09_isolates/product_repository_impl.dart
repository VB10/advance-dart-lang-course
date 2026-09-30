import '../00_architecture/result.dart';
import 'decode_products.dart';
import 'product_domain.dart';

abstract interface class ProductRemoteDataSource {
  Future<String> fetchProductsBody();
}

final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote, {this.isolateThreshold = 50 * 1024});
  final ProductRemoteDataSource _remote;
  final int isolateThreshold;

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final body = await _remote.fetchProductsBody();
      return Ok(await decodeProducts(body, isolateThreshold: isolateThreshold));
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

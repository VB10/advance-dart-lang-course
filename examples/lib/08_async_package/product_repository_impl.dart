import 'package:async/async.dart' hide Result;

import '../00_architecture/result.dart';
import 'product_domain.dart';

typedef Json = Map<String, Object?>;

abstract interface class ProductLocalDataSource {
  Future<void> openIndex();
  Future<List<Json>> query(String text);
}

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._local);
  final ProductLocalDataSource _local;
  final _indexReady = AsyncMemoizer<void>();

  @override
  Future<Result<List<Product>>> search(String query) async {
    try {
      await _indexReady.runOnce(_local.openIndex);
      final rows = await _local.query(query);
      return Ok(rows.map(_toProduct).nonNulls.toList());
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }

  static Product? _toProduct(Json row) => switch (row) {
    {'id': final int id, 'name': final String name} => Product(id: id, name: name),
    _ => null,
  };
}

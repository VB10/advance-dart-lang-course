import '../../../../../00_architecture/result.dart';
import '../domain.dart';

final class InMemoryCartRepository implements CartRepository {
  InMemoryCartRepository(this._catalog);
  final Set<String> _catalog;
  final Map<String, int> _quantities = {};

  @override
  Future<Result<int>> add(CartItem item) async {
    if (!_catalog.contains(item.sku)) return const Err(ServerFailure(404));
    _quantities.update(item.sku, (total) => total + item.quantity, ifAbsent: () => item.quantity);
    return Ok(_quantities.values.fold(0, (sum, quantity) => sum + quantity));
  }
}

import 'package:collection/collection.dart';

import '../00_architecture/result.dart';
import 'order_entity.dart';

abstract interface class OrderRepository {
  Result<Order> findById(String id);
}

final class InMemoryOrderRepository implements OrderRepository {
  InMemoryOrderRepository(this._orders);
  final List<Order> _orders;

  @override
  Result<Order> findById(String id) => switch (_orders.firstWhereOrNull((o) => o.id == id)) {
    final order? => Ok(order),
    null => const Err(ServerFailure(404)),
  };
}

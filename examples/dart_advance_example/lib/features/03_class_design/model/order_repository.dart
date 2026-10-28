abstract interface class OrderRepository {
  String? findCustomer(String orderId);
}

abstract base class CachedOrderRepository implements OrderRepository {
  final Map<String, String> _cache = {};

  // Olumsuz: önbelleği kullanmaz; aynı sipariş her aramada yeniden getirilir → 3 arama, 3 çağrı.
  String? findCustomerWrong(String orderId) => fetch(orderId);

  // Olumlu: ortak taban önbellekler (`base`, alt sınıf `extends`); 3 arama → 1 çağrı.
  @override
  String? findCustomer(String orderId) {
    final cached = _cache[orderId];
    if (cached != null) return cached;
    final fetched = fetch(orderId);
    if (fetched != null) _cache[orderId] = fetched;
    return fetched;
  }

  String? fetch(String orderId);
}

/// Sipariş detay ekranında müşteri adını API'den getiren repository.
final class ApiOrderRepository extends CachedOrderRepository {
  int fetches = 0;

  @override
  String? fetch(String orderId) {
    fetches++;
    return 'Ayşe Yılmaz';
  }
}

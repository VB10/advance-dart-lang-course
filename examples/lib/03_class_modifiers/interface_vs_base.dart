// Pure contract: outside code can only `implements` it (e.g. a test fake).
abstract interface class ProductRepository {
  Future<String?> findName(String productId);
}

// Shared logic: outside code can `extends` it but never `implements` it.
abstract base class CachedProductRepository implements ProductRepository {
  final Map<String, String> _cache = {};

  @override
  Future<String?> findName(String productId) async {
    final cached = _cache[productId];
    if (cached != null) return cached;
    final fetched = await fetchName(productId);
    if (fetched != null) _cache[productId] = fetched;
    return fetched;
  }

  Future<String?> fetchName(String productId);
}

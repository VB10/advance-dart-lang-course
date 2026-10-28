// Düzelt: /dartadvance Projemde repository sözleşmelerini ve ortak mantıklı tabanları bul,
//    `abstract interface class` / `abstract base class` ile ayır, test yaz.
// Üret: /dartadvance Bana siparişleri getiren bir repository sözleşmesi ve sonuçları
//    önbellekleyen ortak bir taban yaz.

// ✗ class Bad extends ProductRepository {}  // analyzer: interface can't be extended
// Pure contract: outside code can only `implements` it (e.g. a test fake).
abstract interface class ProductRepository {
  Future<String?> findName(String productId);
}

// ✗ class Fake implements CachedProductRepository {}  // analyzer: base can't be implemented
// Shared logic: outside code can only `extends` it (as `base`/`final`).
abstract base class CachedProductRepository implements ProductRepository {
  final Map<String, String> _cache = {};

  @override
  Future<String?> findName(String productId) async {
    final cached = _cache[productId];
    if (cached != null) return cached; // 2nd call: no fetch
    final fetched = await fetchName(productId);
    if (fetched != null) _cache[productId] = fetched;
    return fetched;
  }

  Future<String?> fetchName(String productId);
}

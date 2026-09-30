import 'dart:isolate';

import 'parse_products.dart';
import 'product_domain.dart';

/// Parses inline below [isolateThreshold]; the closure captures only `body`.
Future<List<Product>> decodeProducts(String body, {int isolateThreshold = 50 * 1024}) async {
  if (body.length < isolateThreshold) return parseProducts(body);
  return Isolate.run(() => parseProducts(body), debugName: 'parseProducts');
}

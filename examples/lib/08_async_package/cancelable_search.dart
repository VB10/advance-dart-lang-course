import 'package:async/async.dart' hide Result;

/// Search-as-you-type: only the latest query may deliver results.
final class ProductSearch {
  ProductSearch(this._fetch);
  final Future<List<String>> Function(String query) _fetch;
  CancelableOperation<List<String>>? _running;

  Future<List<String>?> search(String query) {
    _running?.cancel();
    final operation = CancelableOperation.fromFuture(_fetch(query));
    _running = operation;
    // null means this query was replaced by a newer one.
    return operation.valueOrCancellation();
  }
}

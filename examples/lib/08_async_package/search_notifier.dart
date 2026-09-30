import 'package:async/async.dart' hide Result;

import '../00_architecture/result.dart';
import 'product_domain.dart';
import 'search_state.dart';

/// Every new query cancels the previous one: a stale response never lands.
final class SearchNotifier {
  SearchNotifier(this._searchProducts);
  final SearchProducts _searchProducts;

  CancelableOperation<Result<List<Product>>>? _pending;
  SearchState state = const SearchIdle();

  Future<void> onQueryChanged(String query) async {
    final previous = _pending;
    // Swapped before the first `await`, so a second call sees this one.
    final operation = _pending = CancelableOperation.fromFuture(_searchProducts(query));
    state = SearchLoading(query);
    await previous?.cancel();

    final result = await operation.valueOrCancellation();
    if (result == null) return;
    state = switch (result) {
      Ok(:final value) => SearchLoaded(query, value),
      Err(:final failure) => SearchFailed(failure),
    };
  }

  Future<void> dispose() async {
    await _pending?.cancel();
  }
}

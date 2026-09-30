import 'dart:async';

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/08_async_package/product_domain.dart';
import 'package:dartadvance_examples/08_async_package/search_notifier.dart';
import 'package:dartadvance_examples/08_async_package/search_state.dart';
import 'package:test/test.dart';

final class _ControlledRepository implements ProductRepository {
  final _pending = <String, Completer<Result<List<Product>>>>{};

  @override
  Future<Result<List<Product>>> search(String query) =>
      (_pending[query] = Completer<Result<List<Product>>>()).future;

  void complete(String query, Result<List<Product>> result) => _pending[query]!.complete(result);
}

void main() {
  test('only the latest query lands and the stale response is discarded', () async {
    final repository = _ControlledRepository();
    final notifier = SearchNotifier(SearchProducts(repository));

    final first = notifier.onQueryChanged('ph');
    final second = notifier.onQueryChanged('phone');
    await pumpEventQueue();
    expect(notifier.state, isA<SearchLoading>().having((state) => state.query, 'query', 'phone'));

    repository.complete('phone', const Ok([Product(id: 2, name: 'Phone')]));
    await second;
    repository.complete('ph', const Ok([Product(id: 1, name: 'Photo')]));
    await first;
    await pumpEventQueue();

    expect(
      notifier.state,
      isA<SearchLoaded>()
          .having((state) => state.query, 'query', 'phone')
          .having((state) => state.products.single.name, 'name', 'Phone'),
    );
    await notifier.dispose();
  });

  test('an Err result becomes SearchFailed', () async {
    final repository = _ControlledRepository();
    final notifier = SearchNotifier(SearchProducts(repository));
    final done = notifier.onQueryChanged('x');
    await pumpEventQueue();
    repository.complete('x', const Err(NetworkFailure()));
    await done;
    expect(notifier.state, isA<SearchFailed>());
  });
}

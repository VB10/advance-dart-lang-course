import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/08_async_package/product_domain.dart';
import 'package:dartadvance_examples/08_async_package/product_repository_impl.dart';
import 'package:test/test.dart';

final class _FakeLocal implements ProductLocalDataSource {
  _FakeLocal({this.failQuery = false});
  final bool failQuery;
  int openCalls = 0;
  final queries = <String>[];

  @override
  Future<void> openIndex() async {
    openCalls++;
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<List<Json>> query(String text) async {
    if (failQuery) throw StateError('index corrupt');
    queries.add(text);
    return [
      {'id': 1, 'name': text},
      {'bad': true},
    ];
  }
}

void main() {
  test('the repository opens the index once, even for concurrent searches', () async {
    final local = _FakeLocal();
    final repository = ProductRepositoryImpl(local);

    final results = await Future.wait([repository.search('a'), repository.search('b')]);
    await repository.search('c');

    expect(local.openCalls, 1);
    expect(results.first, isA<Ok<List<Product>>>());
    expect(local.queries, ['a', 'b', 'c']);
  });

  test('the repository maps a data source error to Err', () async {
    final repository = ProductRepositoryImpl(_FakeLocal(failQuery: true));
    expect(await repository.search('x'), isA<Err<List<Product>>>());
  });
}

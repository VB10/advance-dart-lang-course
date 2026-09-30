import 'dart:convert';

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/09_isolates/product_domain.dart';
import 'package:dartadvance_examples/09_isolates/product_repository_impl.dart';
import 'package:test/test.dart';

final class _FakeRemote implements ProductRemoteDataSource {
  const _FakeRemote(this.body);
  final String body;

  @override
  Future<String> fetchProductsBody() async => body;
}

String _productsJson(int count) => jsonEncode([
  for (var i = 0; i < count; i++) {'id': i, 'name': 'Product $i', 'price': i * 1.5},
]);

void main() {
  test('a large payload is parsed on another isolate and returns Ok', () async {
    final repository = ProductRepositoryImpl(_FakeRemote(_productsJson(2000)), isolateThreshold: 1);
    final result = await repository.getProducts();
    expect(result, isA<Ok<List<Product>>>());
    expect((result as Ok<List<Product>>).value, hasLength(2000));
  });

  test('a FormatException from the isolate becomes Err(UnexpectedFailure)', () async {
    final repository = ProductRepositoryImpl(const _FakeRemote('[{"id":1}]'), isolateThreshold: 1);
    expect(
      await repository.getProducts(),
      isA<Err<List<Product>>>().having(
        (err) => err.failure,
        'failure',
        isA<UnexpectedFailure>().having((failure) => failure.error, 'error', isFormatException),
      ),
    );
  });

  test('a small payload stays on the current isolate with the same result', () async {
    final repository = ProductRepositoryImpl(_FakeRemote(_productsJson(3)));
    expect(await repository.getProducts(), isA<Ok<List<Product>>>());
  });
}

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/04_libraries_metadata/practice/ex2_feature_cart/cart.dart';
import 'package:test/test.dart';

final class _RecordingCartRepository implements CartRepository {
  final List<CartItem> added = [];

  @override
  Future<Result<int>> add(CartItem item) async {
    added.add(item);
    return Ok(added.length);
  }
}

Matcher _okWith(int total) => isA<Ok<int>>().having((ok) => ok.value, 'value', total);

void main() {
  test('the composition function wires the hidden data implementation', () async {
    final addToCart = createAddToCart(catalog: {'apple', 'pear'});

    expect(await addToCart('apple', quantity: 2), _okWith(2));
    expect(await addToCart('pear'), _okWith(3));
    expect(
      await addToCart('kiwi'),
      isA<Err<int>>().having((err) => err.failure, 'failure', isA<ServerFailure>()),
    );
  });

  test('a consumer can build the use case with its own repository', () async {
    final repository = _RecordingCartRepository();
    await AddToCart(repository)('apple', quantity: 4);

    expect((repository.added.single.sku, repository.added.single.quantity), ('apple', 4));
  });
}

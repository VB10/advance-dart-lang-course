import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/05_collection/order_entity.dart';
import 'package:dartadvance_examples/05_collection/order_repository.dart';
import 'package:test/test.dart';

void main() {
  test('firstWhereOrNull lookup maps to Ok or Err(ServerFailure)', () {
    final repository = InMemoryOrderRepository([
      Order(id: '1', skus: ['x']),
    ]);
    expect(repository.findById('1'), isA<Ok<Order>>());
    expect(
      repository.findById('9'),
      isA<Err<Order>>().having((err) => err.failure, 'failure', isA<ServerFailure>()),
    );
  });
}

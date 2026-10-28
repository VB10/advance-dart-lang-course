import 'package:dart_advance_example/features/03_class_design/model/order_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements OrderRepository {
  @override
  String? findCustomer(String orderId) => 'Fake';
}

void main() {
  test('base caches, uncached lookup fetches every time', () {
    final wrong = ApiOrderRepository();
    final right = ApiOrderRepository();
    for (var i = 0; i < 3; i++) {
      wrong.findCustomerWrong('A1');
      right.findCustomer('A1');
    }
    expect(wrong.fetches, 3);
    expect(right.fetches, 1);
  });

  test('interface can be faked with implements', () {
    expect(_FakeRepository().findCustomer('A1'), 'Fake');
  });
}

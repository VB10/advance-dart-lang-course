import 'package:dartadvance_examples/03_class_modifiers/final_money.dart';
import 'package:dartadvance_examples/03_class_modifiers/interface_vs_base.dart';
import 'package:dartadvance_examples/03_class_modifiers/mixin_class.dart';
import 'package:dartadvance_examples/03_class_modifiers/sealed_order_state.dart';
import 'package:test/test.dart';

// This test file is another library: `implements` and `extends` are checked here.
final class _FakeRepository implements ProductRepository {
  @override
  Future<String?> findName(String productId) async => 'Fake $productId';
}

// Base transitivity: a subtype of a `base` class must itself be base/final/sealed.
final class _CountingRepository extends CachedProductRepository {
  int fetchCount = 0;

  @override
  Future<String?> fetchName(String productId) async {
    fetchCount++;
    return productId == 'p1' ? 'Mug' : null;
  }
}

class _Checkout with Auditable {}

class _Shipment extends Auditable {}

void main() {
  group('sealed_order_state', () {
    test('every subtype maps to its own status text', () {
      expect(statusText(const OrderPlaced()), 'Preparing your order');
      expect(statusText(const OrderShipped('TR1')), 'On the way: TR1');
      expect(
        statusText(const OrderCancelled('no stock')),
        'Cancelled: no stock',
      );
    });

    test('a `_` fallback hides new states behind a generic text', () {
      expect(lazyText(const OrderCancelled('no stock')), 'Unknown');
      expect(lazyText(const OrderPlaced()), 'Preparing your order');
    });

    test('subtypes are usable as the sealed root type', () {
      const OrderState state = OrderPlaced();
      expect(state, isA<OrderState>());
    });
  });

  group('final_money', () {
    test('another library can construct a final class', () {
      expect(const Money(500, 'TRY').cents, 500);
    });

    test('equal amounts in the same currency are equal', () {
      expect(const Money(500, 'TRY'), const Money(500, 'TRY'));
      expect(
        const Money(500, 'TRY').hashCode,
        const Money(500, 'TRY').hashCode,
      );
    });

    test('adding different currencies throws', () {
      expect(
        () => const Money(1, 'TRY') + const Money(1, 'USD'),
        throwsArgumentError,
      );
    });

    test('adding the same currency sums the cents', () {
      expect(
        const Money(100, 'TRY') + const Money(250, 'TRY'),
        const Money(350, 'TRY'),
      );
    });
  });

  group('interface_vs_base', () {
    test('an interface can be implemented from another library', () async {
      final ProductRepository repository = _FakeRepository();
      expect(await repository.findName('p9'), 'Fake p9');
    });

    test('a base class can be extended from another library', () async {
      final repository = _CountingRepository();
      expect(await repository.findName('p1'), 'Mug');
    });

    test('the base class keeps its shared cache logic', () async {
      final repository = _CountingRepository();
      await repository.findName('p1');
      await repository.findName('p1');
      expect(repository.fetchCount, 1);
    });

    test('missing products are not cached', () async {
      final repository = _CountingRepository();
      await repository.findName('nope');
      await repository.findName('nope');
      expect(repository.fetchCount, 2);
    });
  });

  group('mixin_class', () {
    test('it can be mixed in with `with`', () {
      final checkout = _Checkout()..audit('paid');
      expect(checkout.auditLog, ['paid']);
    });

    test('it can be used as a superclass with `extends`', () {
      final shipment = _Shipment()..audit('shipped');
      expect(shipment.auditLog, ['shipped']);
    });

    test('it can be constructed on its own', () {
      expect(Auditable().auditLog, isEmpty);
    });

    test('the returned log cannot be modified from outside', () {
      final log = (Auditable()..audit('a')).auditLog;
      expect(() => log.add('b'), throwsUnsupportedError);
    });
  });
}

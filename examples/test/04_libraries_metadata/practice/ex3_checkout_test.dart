import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/04_libraries_metadata/practice/ex3_checkout_state.dart';
import 'package:dartadvance_examples/04_libraries_metadata/practice/ex3_checkout_store.dart';
import 'package:test/test.dart';

void main() {
  test('pay emits Submitting then Paid and the label switch is exhaustive', () async {
    final store = CheckoutStore((cents) async => Ok('R-$cents'));
    final seen = <String>[];
    store.listen((state) => seen.add(checkoutLabel(state)));

    expect(checkoutLabel(store.state), 'Pay');
    await store.pay(1500);
    expect(seen, ['Paying...', 'Paid: R-1500']);
    expect(store.state, isA<CheckoutPaid>());
  });

  test('a failure becomes CheckoutFailed and dispose clears listeners', () async {
    final store = CheckoutStore((_) async => const Err(NetworkFailure()))..listen((_) {});

    await store.pay(100);
    expect(checkoutLabel(store.state), 'Retry (No connection)');
    expect(store.listenerCount, 1);
    store.dispose();
    expect(store.listenerCount, 0);
  });

  test('a result arriving after dispose is dropped', () async {
    late void Function() release;
    final store = CheckoutStore((cents) async {
      await Future<void>(() => release());
      return Ok('R-$cents');
    });
    release = store.dispose;

    await store.pay(1);
    expect(store.state, isA<CheckoutSubmitting>());
    expect(checkoutLabel(store.state), 'Paying...');
  });
}

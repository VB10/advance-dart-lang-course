import 'package:dartadvance_examples/04_libraries_metadata/library_privacy.dart';
import 'package:dartadvance_examples/04_libraries_metadata/part_files/order_builder.dart';
import 'package:dartadvance_examples/04_libraries_metadata/protected_members.dart';
import 'package:dartadvance_examples/04_libraries_metadata/result_annotations.dart';
import 'package:test/test.dart';

final class _QuantityStore extends CartStore<int> {
  _QuantityStore() : super(0);

  int disposeCalls = 0;

  void increment() => emit(state + 1);

  @override
  void dispose() {
    disposeCalls++;
    super.dispose();
  }
}

void main() {
  group('library_privacy', () {
    test('another class in the same library reads and writes a private field', () {
      final wallet = Wallet(100)..spend(250);
      const auditor = WalletAuditor();

      expect(auditor.isOverdrawn(wallet), isTrue);
      auditor.writeOff(wallet);
      expect(wallet.balanceCents, 0);
      expect(auditor.isOverdrawn(wallet), isFalse);
    });
  });

  group('part_files', () {
    test('a part file shares private members and imports with its library', () {
      final order = OrderBuilder()
        ..add('apple', quantity: 3)
        ..add('pear');

      expect(order.skus, ['apple', 'pear']);
      expect(order.totalQuantity, 4);
    });
  });

  group('result_annotations', () {
    test('@immutable const instances are canonicalized', () {
      expect(identical(const Money(100, 'TRY'), const Money(100, 'TRY')), isTrue);
    });

    test('@useResult add returns a new value and leaves the original unchanged', () {
      const total = Money(100, 'TRY');
      final withFee = total.add(const Money(25, 'TRY'));

      expect(withFee.cents, 125);
      expect(total.cents, 100);
    });

    test('adding different currencies throws', () {
      expect(() => const Money(1, 'TRY').add(const Money(1, 'EUR')), throwsArgumentError);
    });
  });

  group('protected_members', () {
    test('a subclass emits state and listeners are notified', () {
      final seen = <int>[];
      final store = _QuantityStore()
        ..listen(seen.add)
        ..increment()
        ..increment();

      expect(seen, [1, 2]);
      expect(store.state, 2);
    });

    test('a @mustCallSuper override still clears listeners through the base dispose', () {
      final seen = <int>[];
      final store = _QuantityStore()
        ..listen(seen.add)
        ..dispose()
        ..increment();

      expect(store.disposeCalls, 1);
      expect(seen, isEmpty);
    });
  });
}

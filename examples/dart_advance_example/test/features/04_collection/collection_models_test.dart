import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:dart_advance_example/features/04_collection/model/address_book.dart';
import 'package:dart_advance_example/features/04_collection/model/cart_history.dart';
import 'package:dart_advance_example/features/04_collection/model/filter_draft.dart';
import 'package:dart_advance_example/features/04_collection/model/order_history.dart';
import 'package:dart_advance_example/features/04_collection/model/price_sort.dart';
import 'package:dart_advance_example/features/04_collection/model/product_grid.dart';
import 'package:dart_advance_example/features/04_collection/model/upload_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressBook', () {
    const addresses = [Address('İş'), Address('Annemler')];
    test('firstWhere throws when there is no default', () {
      expect(
        () => AddressBook().defaultAddressWrong(addresses),
        throwsStateError,
      );
    });
    test('firstWhereOrNull returns null', () {
      expect(AddressBook().defaultAddress(addresses), isNull);
      expect(
        AddressBook().defaultAddress([
          ...addresses,
          const Address('Ev', isDefault: true),
        ])?.title,
        'Ev',
      );
    });
  });

  group('OrderHistory', () {
    const orders = [
      Order('1', 'Ekim'),
      Order('2', 'Eylül'),
      Order('3', 'Ekim'),
    ];
    test('consecutive headers repeat a month', () {
      expect(OrderHistory().sectionsWrong(orders).map((s) => s.$1), [
        'Ekim',
        'Eylül',
        'Ekim',
      ]);
    });
    test('groupBy shows each month once', () {
      final sections = OrderHistory().sections(orders);
      expect(sections.map((s) => s.$1), ['Ekim', 'Eylül']);
      expect(sections.first.$2.map((o) => o.no), ['1', '3']);
    });
  });

  group('FilterDraft', () {
    test('!= on sets compares identity', () {
      expect(FilterDraft().canApplyWrong({'a', 'b'}, {'b', 'a'}), isTrue);
    });
    test('SetEquality compares content', () {
      expect(FilterDraft().canApply({'a', 'b'}, {'b', 'a'}), isFalse);
      expect(FilterDraft().canApply({'a'}, {'a', 'b'}), isTrue);
    });
  });

  group('ProductGrid', () {
    final products = List.generate(7, (i) => '$i');
    test('sublist overruns the last row', () {
      expect(() => ProductGrid().rowsWrong(products), throwsRangeError);
    });
    test('slices keeps the remainder', () {
      expect(ProductGrid().rows(products).map((r) => r.length), [3, 3, 1]);
    });
  });

  group('PriceSort', () {
    const products = [
      Product('Kupa', 19.9),
      Product('Defter', 19.5),
      Product('Kalem', 12),
    ];
    test('toInt comparator treats 19.9 and 19.5 as equal', () {
      expect(PriceSort().ascendingWrong(products).map((p) => p.name), [
        'Kalem',
        'Kupa',
        'Defter',
      ]);
    });
    test('sortedBy orders by price and leaves the source alone', () {
      expect(PriceSort().ascending(products).map((p) => p.name), [
        'Kalem',
        'Defter',
        'Kupa',
      ]);
      expect(products.first.name, 'Kupa');
    });
  });

  group('UploadQueue', () {
    const uploads = [
      Upload('a', priority: 2),
      Upload('b', priority: 2),
      Upload('kimlik', priority: 0),
    ];
    test('a List keeps insertion order', () {
      expect(UploadQueue().orderWrong(uploads).first, 'a');
    });
    test('PriorityQueue puts the ID first', () {
      expect(UploadQueue().order(uploads).first, 'kimlik');
    });
  });

  group('CartHistory', () {
    test('List.add changes the previous state too', () {
      final (before, after) = CartHistory().addWrong(['Kahve'], 'Termos');
      expect(before, ['Kahve', 'Termos']);
      expect(identical(before, after), isTrue);
    });
    test('IList.add keeps the previous state', () {
      final (before, after) = CartHistory().add(['Kahve'].lock, 'Termos');
      expect(before, ['Kahve'].lock);
      expect(after, ['Kahve', 'Termos'].lock);
    });
  });
}

import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/content_equality.dart';
import 'package:dartadvance_examples/05_collection/first_or_null.dart';
import 'package:dartadvance_examples/05_collection/group_and_sort.dart';
import 'package:dartadvance_examples/05_collection/immutable_state.dart';
import 'package:dartadvance_examples/05_collection/task_scheduler.dart';
import 'package:test/test.dart';

const _orders = <Order>[
  (city: 'IST', sku: 'a', amount: 30),
  (city: 'ANK', sku: 'b', amount: 10),
  (city: 'IST', sku: 'c', amount: 20),
];

void main() {
  group('first_or_null', () {
    const products = [(name: 'pen', stock: 0), (name: 'ink', stock: 4)];

    test('firstOrNull returns null on an empty list instead of throwing', () {
      expect(cheapest(const []), isNull);
      expect(cheapest(products), (name: 'pen', stock: 0));
    });

    test('firstWhereOrNull returns the first match or null', () {
      expect(firstInStock(products)?.name, 'ink');
      expect(firstInStock([products.first]), isNull);
    });

    test('singleOrNull is null for zero and for two or more elements', () {
      expect(onlyProduct(const []), isNull);
      expect(onlyProduct(products), isNull);
      expect(onlyProduct([products.first]), products.first);
    });
  });

  group('group_and_sort', () {
    test('groupListsBy keeps first-seen key order and item order', () {
      final grouped = ordersByCity(_orders);
      expect(grouped.keys, ['IST', 'ANK']);
      expect(grouped['IST']!.map((order) => order.sku), ['a', 'c']);
    });

    test('sorting helpers return a new list and leave the source alone', () {
      expect(biggestFirst(_orders).map((order) => order.amount), [30, 20, 10]);
      expect(_orders.first.amount, 30);
    });

    test('mapIndexed numbers the lines from one', () {
      expect(numberedLines(_orders), ['1. a', '2. b', '3. c']);
    });

    test('compareNatural puts v2 before v10 while plain sort does not', () {
      expect(versionsInOrder(['v10', 'v2', 'v1']), ['v1', 'v2', 'v10']);
      expect(['v10', 'v2', 'v1']..sort(), ['v1', 'v10', 'v2']);
    });
  });

  group('content_equality', () {
    Profile profile() => Profile('ada', {
      'tags': ['a', 'b'],
    });

    test('plain collections compare by identity', () {
      expect([1, 2] == [1, 2], isFalse);
    });

    test('a class using DeepCollectionEquality compares nested contents', () {
      expect(profile(), profile());
      expect(profile().hashCode, profile().hashCode);
    });

    test('ListEquality without deep support compares nested lists by identity', () {
      expect(
        const ListEquality<List<int>>().equals(
          [
            [1],
          ],
          [
            [1],
          ],
        ),
        isFalse,
      );
    });

    test('the unordered variant ignores list order', () {
      expect(
        sameQuery(
          {
            'q': ['1', '2'],
          },
          {
            'q': ['2', '1'],
          },
        ),
        isTrue,
      );
      expect(const DeepCollectionEquality().equals([1, 2], [2, 1]), isFalse);
    });
  });

  group('immutable_state', () {
    test('the state copy does not follow the caller list', () {
      final source = ['a'];
      final state = CartState(source);
      source.add('b');
      expect(state.skus, ['a']);
    });

    test('the state copy rejects changes', () {
      expect(() => CartState(['a']).skus.add('b'), throwsUnsupportedError);
    });

    test('add builds a new state and keeps the old one', () {
      final before = CartState(['a']);
      expect(before.add('b').skus, ['a', 'b']);
      expect(before.skus, ['a']);
    });

    test('the view rejects changes but follows the owner', () {
      final model = CartViewModel();
      final view = model.skus;
      model.add('a');
      expect(view, ['a']);
      expect(() => view.add('b'), throwsUnsupportedError);
    });
  });

  group('task_scheduler', () {
    test('runs the highest priority first and FIFO within a priority', () {
      final scheduler = TaskScheduler()
        ..schedule('sync', priority: 1)
        ..schedule('render', priority: 5)
        ..schedule('log', priority: 1)
        ..schedule('input', priority: 5);
      expect(scheduler.drain(), ['render', 'input', 'sync', 'log']);
    });

    test('drain empties the queue', () {
      final scheduler = TaskScheduler()..schedule('sync', priority: 1);
      scheduler.drain();
      expect(scheduler.drain(), isEmpty);
    });
  });
}

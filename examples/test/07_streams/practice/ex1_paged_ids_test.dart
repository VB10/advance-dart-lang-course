import 'package:dartadvance_examples/07_streams/practice/ex1_paged_ids.dart';
import 'package:test/test.dart';

void main() {
  test('pagedIds reads every page until an empty one', () async {
    final pages = [
      [1, 2],
      [3],
      <int>[],
    ];
    var released = 0;
    final ids = await pagedIds((page) async => pages[page], onReleased: () => released++).toList();
    expect(ids, [1, 2, 3]);
    expect(released, 1);
  });

  test('an early stop fetches no further page and runs finally once', () async {
    final requested = <int>[];
    var released = 0;
    Future<List<int>> fetch(int page) async {
      requested.add(page);
      return [page * 10, page * 10 + 1];
    }

    final firstThree = await pagedIds(fetch, onReleased: () => released++).take(3).toList();
    await pumpEventQueue();

    expect(firstThree, [0, 1, 10]);
    expect(requested, [0, 1], reason: 'page 2 is never fetched after cancel');
    expect(released, 1);
  });
}

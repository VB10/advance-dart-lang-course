import 'package:dartadvance_examples/04_libraries_metadata/metadata/counter_store.dart';
import 'package:test/test.dart';

void main() {
  test('@protected emit is reached through the subclass API', () {
    final seen = <int>[];
    final store = CounterStore()
      ..listen(seen.add)
      ..increment()
      ..increment();

    expect(seen, [1, 2]);
    expect(store.state, 2);
  });

  test('a @mustCallSuper override still runs the base dispose', () {
    final store = CounterStore()..listen((_) {});
    expect(store.listenerCount, 1); // @visibleForTesting: allowed in test/

    store.dispose();
    expect(store.disposeCalls, 1);
    expect(store.listenerCount, 0);
  });
}

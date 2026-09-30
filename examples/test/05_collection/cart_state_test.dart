import 'package:dartadvance_examples/05_collection/cart_state.dart';
import 'package:test/test.dart';

void main() {
  test('state exposes a read-only UnmodifiableListView that follows add()', () {
    final state = CartState()..add('x');
    expect(state.items, ['x']);
    expect(() => state.items.add('y'), throwsUnsupportedError);
    state.add('y');
    expect(state.items, ['x', 'y']);
  });
}

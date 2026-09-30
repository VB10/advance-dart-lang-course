import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/03_class_modifiers/practice/ex2_cart_notifier.dart';
import 'package:dartadvance_examples/03_class_modifiers/practice/ex2_cart_state.dart';
import 'package:test/test.dart';

// Another library: `implements` is exactly what an interface class allows.
final class _FakeCartRepository implements CartRepository {
  _FakeCartRepository(this._responses);
  final List<Result<int>> _responses;

  @override
  Future<Result<int>> addItem(String sku) async => _responses.removeAt(0);
}

void main() {
  test('adding an item emits Adding, then Idle with the new count', () async {
    final notifier = CartNotifier(_FakeCartRepository([const Ok(1)]));
    final seen = <String>[];
    notifier.addListener((s) => seen.add(cartBadge(s)));
    expect(cartBadge(notifier.state), 'Empty');
    await notifier.add('sku-1');
    expect(seen, ['Adding...', '1 item(s)']);
  });

  test('each failure maps to its own badge', () async {
    final notifier = CartNotifier(
      _FakeCartRepository([const Err(NetworkFailure()), const Err(ServerFailure(503))]),
    );
    await notifier.add('a');
    expect(cartBadge(notifier.state), 'Offline');
    await notifier.add('b');
    expect(notifier.state, isA<CartFailed>());
    expect(cartBadge(notifier.state), 'Error 503');
  });

  test('an unexpected failure gets a retry badge', () {
    expect(
      cartBadge(CartFailed(UnexpectedFailure(StateError('x'), StackTrace.empty))),
      'Try again',
    );
  });
}

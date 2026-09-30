import 'package:dartadvance_examples/06_event_loop_future/future_wait.dart';
import 'package:test/test.dart';

Future<T> _after<T>(int milliseconds, T value) =>
    Future.delayed(Duration(milliseconds: milliseconds), () => value);

void main() {
  test('Future.wait keeps the input order, not the completion order', () async {
    expect(await fetchAllCounts([_after(20, 1), _after(1, 2), _after(10, 3)]), [1, 2, 3]);
  });

  test('Future.wait fails with the first error', () {
    expect(
      fetchAllCounts([_after(1, 1), Future<int>.error(StateError('boom'))]),
      throwsA(isA<StateError>()),
    );
  });
}

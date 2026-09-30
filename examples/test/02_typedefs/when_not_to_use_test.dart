import 'package:dartadvance_examples/02_typedefs/alias_not_new_type.dart';
import 'package:dartadvance_examples/02_typedefs/inline_function_type.dart';
import 'package:test/test.dart';

void main() {
  test('an inline function type field works without a typedef', () {
    final fired = <String>[];
    Debouncer(fired.add).fire('q');
    expect(fired, ['q']);
  });

  test('a typedef alias accepts any int, so it adds no type safety', () {
    const int anyInt = 41;
    expect(nextOrder(anyInt), 42);
    expect(OrderIdAlias, int);
  });
}

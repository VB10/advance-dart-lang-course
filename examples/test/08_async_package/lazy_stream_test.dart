import 'package:dartadvance_examples/08_async_package/lazy_stream.dart';
import 'package:test/test.dart';

void main() {
  test('LazyStream calls the factory only on listen', () async {
    var opened = 0;
    final stream = lazyLogLines(() {
      opened++;
      return Stream.fromIterable(['a', 'b']);
    });
    expect(opened, 0);
    expect(await stream.toList(), ['a', 'b']);
    expect(opened, 1);
  });
}

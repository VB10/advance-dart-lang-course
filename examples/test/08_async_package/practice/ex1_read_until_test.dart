import 'dart:async';

import 'package:dartadvance_examples/08_async_package/practice/ex1_read_until.dart';
import 'package:test/test.dart';

void main() {
  test('readUntil stops at the terminator and releases the source', () async {
    var cancelled = false;
    final controller = StreamController<String>(onCancel: () => cancelled = true);
    controller
      ..add('a')
      ..add('b')
      ..add('END')
      ..add('c');
    unawaited(controller.close());

    expect(await readUntil(controller.stream, 'END'), ['a', 'b']);
    expect(cancelled, isTrue, reason: 'queue.cancel() cancels the source subscription');
  });

  test('a stream without terminator returns everything without StateError', () async {
    expect(await readUntil(Stream.fromIterable(['x', 'y']), 'END'), ['x', 'y']);
    expect(await readUntil(const Stream<String>.empty(), 'END'), isEmpty);
  });
}

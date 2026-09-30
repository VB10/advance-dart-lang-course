import 'dart:async';

import 'package:dartadvance_examples/08_async_package/stream_completer.dart';
import 'package:test/test.dart';

void main() {
  test('the stream is usable immediately and a failed future becomes an error event', () async {
    final connect = Completer<Stream<int>>();
    final collected = ticksAfterConnect(connect.future).toList();
    connect.complete(Stream.fromIterable([1, 2]));
    expect(await collected, [1, 2]);

    final failing = ticksAfterConnect(Future.error(StateError('refused')));
    await expectLater(failing, emitsError(isStateError));
  });
}

import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/stream_group_merge.dart';
import 'package:test/test.dart';

void main() {
  test('StreamGroup.merge forwards both sources and closes after both closed', () async {
    final server = StreamController<String>();
    final device = StreamController<String>();
    final queue = StreamQueue(allAlerts(server.stream, device.stream));

    server.add('s1');
    expect(await queue.next, 's1');
    device.add('d1');
    expect(await queue.next, 'd1');

    // Not awaited: the queue pauses the source, so done waits for a request.
    unawaited(server.close());
    device.add('d2');
    expect(await queue.next, 'd2', reason: 'still open: device has not closed');
    unawaited(device.close());
    expect(await queue.hasNext, isFalse);
  });
}

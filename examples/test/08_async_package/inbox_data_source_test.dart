import 'dart:async';

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/inbox_data_source.dart';
import 'package:test/test.dart';

void main() {
  test('merged events are read one by one and cancel reaches both sources', () async {
    var pushCancelled = false;
    var localCancelled = false;
    final push = StreamController<Map<String, Object?>>(onCancel: () => pushCancelled = true);
    final local = StreamController<Map<String, Object?>>(onCancel: () => localCancelled = true);
    final source = InboxDataSource(push: push.stream, localEdits: local.stream);

    final events = StreamQueue(source.watch());
    push.add({'id': 1, 'from': 'server'});
    expect(await events.next, {'id': 1, 'from': 'server'});
    local.add({'id': 2, 'from': 'local'});
    expect(await events.next, {'id': 2, 'from': 'local'});

    await events.cancel();
    expect(pushCancelled, isTrue);
    expect(localCancelled, isTrue);
  });
}

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/stream_splitter.dart';
import 'package:test/test.dart';

void main() {
  test('every branch of the splitter sees every event', () async {
    expect(await countAndSum(Stream.fromIterable([1, 2, 3, 4])), (4, 10));
  });

  test('the splitter replays to a late branch but asBroadcastStream does not', () async {
    final splitter = StreamSplitter(Stream.fromIterable([1, 2, 3]));
    final early = await splitter.split().toList();
    final late = await splitter.split().toList();
    await splitter.close();
    expect(early, [1, 2, 3]);
    expect(late, [1, 2, 3]);

    final broadcast = Stream.fromIterable([1, 2, 3]).asBroadcastStream();
    final earlyBroadcast = await broadcast.toList();
    final lateBroadcast = await broadcast.toList();
    expect(earlyBroadcast, [1, 2, 3]);
    expect(lateBroadcast, isEmpty);
  });
}

import 'package:async/async.dart' hide Result;
import 'package:dartadvance_examples/08_async_package/stream_queue.dart';
import 'package:test/test.dart';

void main() {
  test('readMessage pulls a header and then exactly that many items', () async {
    final lines = Stream.fromIterable(['ORDER 2', 'apple', 'pear', 'NEXT 0']);
    final message = await readMessage(lines);
    expect(message.title, 'ORDER');
    expect(message.items, ['apple', 'pear']);
  });

  test('peek does not consume and rest closes the queue', () async {
    final queue = StreamQueue(Stream.fromIterable([1, 2, 3, 4, 5]));
    expect(await queue.peek, 1);
    expect(await queue.next, 1);
    expect(await queue.take(2), [2, 3]);
    expect(await queue.hasNext, isTrue);
    expect(await queue.rest.toList(), [4, 5]);
    expect(() => queue.next, throwsStateError);
  });

  test('next fails with StateError when the stream ends first', () async {
    final queue = StreamQueue(const Stream<int>.empty());
    expect(await queue.hasNext, isFalse);
    await expectLater(queue.next, throwsStateError);
  });
}

import 'package:dartadvance_examples/07_streams/generators.dart';
import 'package:dartadvance_examples/07_streams/split_lines.dart';
import 'package:dartadvance_examples/07_streams/sum_stream.dart';
import 'package:dartadvance_examples/07_streams/sum_stream_with_catch.dart';
import 'package:dartadvance_examples/07_streams/timed_counter.dart';
import 'package:test/test.dart';

void main() {
  test('await for sums every value of an async* stream', () async {
    expect(await sumStream(countStream(10)), 55);
  });

  test('an error ends await for and try/catch handles it', () async {
    Stream<int> failing() async* {
      yield 1;
      throw Exception('Intentional exception');
    }

    expect(await sumStreamWithCatch(failing()), -1);
  });

  test('async* yields in order and yield* forwards data and errors', () async {
    await expectLater(asynchronousNaturalsTo(3), emitsInOrder([0, 1, 2, emitsDone]));
    await expectLater(optionalMap(Stream.fromIterable([1, 2])), emitsInOrder([1, 2, emitsDone]));
    await expectLater(
      optionalMap(Stream.fromIterable([1, 2]), (x) => x * 10),
      emitsInOrder([10, 20, emitsDone]),
    );
    await expectLater(
      optionalMap(Stream<int>.error(StateError('boom'))),
      emitsError(isStateError),
    );
  });

  test('lines re-chunks a stream of strings into lines', () async {
    final chunks = Stream.fromIterable(['a\nb', 'c\n', 'd']);
    expect(await lines(chunks).toList(), ['a', 'bc', 'd']);
  });

  test('timedCounter emits 1 to maxCount and then closes', () async {
    final counter = timedCounter(const Duration(milliseconds: 1), 3);
    await expectLater(counter, emitsInOrder([1, 2, 3, emitsDone]));
  });
}

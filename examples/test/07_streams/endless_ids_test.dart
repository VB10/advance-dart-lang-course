import 'package:dartadvance_examples/07_streams/endless_ids.dart';
import 'package:test/test.dart';

void main() {
  test('async* stops producing after cancel and runs finally', () async {
    final produced = <int>[];
    var finallyRan = false;
    final stream = endlessIds(onProduce: produced.add, onFinally: () => finallyRan = true);

    final firstThree = await stream.take(3).toList();
    await pumpEventQueue();
    final producedAfterCancel = produced.length;
    await pumpEventQueue();

    expect(firstThree, [1, 2, 3]);
    expect(finallyRan, isTrue);
    expect(produced.length, producedAfterCancel, reason: 'no values after cancel');
  });
}

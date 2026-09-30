import 'package:dartadvance_examples/05_collection/queue_list.dart';
import 'package:test/test.dart';

void main() {
  test('QueueList supports both addFirst and index access', () {
    final list = history();
    expect(list, ['a', 'b', 'c']);
    expect(list[1], 'b');
    expect(list.removeFirst(), 'a');
  });
}

import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/task_scheduler.dart';
import 'package:test/test.dart';

void main() {
  test('HeapPriorityQueue promises no order among equal priorities', () {
    final queue = HeapPriorityQueue<(int, String)>((a, b) => a.$1.compareTo(b.$1))
      ..addAll([(2, 'b'), (1, 'a'), (2, 'c'), (1, 'd'), (2, 'e')]);
    final order = queue.toList();
    expect(order.map((entry) => entry.$1), [1, 1, 2, 2, 2]);
    expect(order.map((entry) => entry.$2), isNot(['a', 'd', 'b', 'c', 'e'])); // not FIFO
  });

  test('the scheduler runs the highest priority first and FIFO within a priority', () {
    final scheduler = TaskScheduler()
      ..schedule('sync', priority: 1)
      ..schedule('render', priority: 5)
      ..schedule('log', priority: 1)
      ..schedule('input', priority: 5)
      ..schedule('upload', priority: 1);
    expect(scheduler.drain(), ['render', 'input', 'sync', 'log', 'upload']);
  });
}

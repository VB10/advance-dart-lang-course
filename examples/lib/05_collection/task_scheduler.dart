import 'package:collection/collection.dart';

typedef _Task = ({int priority, int sequence, String name});

int _highestFirstThenFifo(_Task a, _Task b) => switch (b.priority.compareTo(a.priority)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class TaskScheduler {
  int _sequence = 0;
  final _queue = HeapPriorityQueue<_Task>(_highestFirstThenFifo);

  void schedule(String name, {required int priority}) =>
      _queue.add((priority: priority, sequence: _sequence++, name: name));

  List<String> drain() {
    final names = <String>[];
    while (_queue.isNotEmpty) {
      names.add(_queue.removeFirst().name);
    }
    return names;
  }
}

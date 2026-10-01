// Skill'e ver: "Projemde öncelikli işi `sort()` ya da tek ölçütlü karşılaştırıcıyla
// sıralayan yerleri bul, `HeapPriorityQueue` + sıra numarası ile düzelt, test yaz."
import 'package:collection/collection.dart';

typedef _Task = ({int priority, int sequence, String name});

int _byPriorityOnly(_Task a, _Task b) => b.priority.compareTo(a.priority);

int _highestFirstThenFifo(_Task a, _Task b) => switch (_byPriorityOnly(a, b)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class TaskScheduler {
  TaskScheduler() : _queue = HeapPriorityQueue(_highestFirstThenFifo);

  TaskScheduler.priorityOnly() : _queue = HeapPriorityQueue(_byPriorityOnly); // ties: not FIFO

  int _sequence = 0;
  final HeapPriorityQueue<_Task> _queue;

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

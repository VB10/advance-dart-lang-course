import 'package:collection/collection.dart';

import 'ex2_support_ticket.dart';

typedef _Entry = ({int priority, int sequence, SupportTicket ticket});

int _mostSevereFirstThenFifo(_Entry a, _Entry b) => switch (b.priority.compareTo(a.priority)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class InboxState {
  int _sequence = 0;
  final List<SupportTicket> _handled = [];
  final _queue = HeapPriorityQueue<_Entry>(_mostSevereFirstThenFifo);

  void receive(SupportTicket ticket) =>
      _queue.add((priority: ticket.severity.index, sequence: _sequence++, ticket: ticket));

  SupportTicket? handleNext() {
    if (_queue.isEmpty) return null;
    final ticket = _queue.removeFirst().ticket;
    _handled.add(ticket);
    return ticket;
  }

  /// A live, read-only view.
  UnmodifiableListView<SupportTicket> get handled => UnmodifiableListView(_handled);

  /// A read-only copy of this moment.
  List<SupportTicket> handledSnapshot() => List.unmodifiable(_handled);
}

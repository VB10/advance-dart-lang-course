import 'package:collection/collection.dart';

import '../../00_architecture/result.dart';

enum Severity { low, normal, urgent }

final class SupportTicket {
  const SupportTicket({required this.id, required this.severity});
  final String id;
  final Severity severity;
}

abstract interface class TicketRepository {
  Result<SupportTicket> findById(String id);
}

final class InMemoryTicketRepository implements TicketRepository {
  InMemoryTicketRepository(this._tickets);
  final List<SupportTicket> _tickets;

  @override
  Result<SupportTicket> findById(String id) {
    final ticket = _tickets.firstWhereOrNull((ticket) => ticket.id == id);
    return ticket == null ? const Err(ServerFailure(404)) : Ok(ticket);
  }
}

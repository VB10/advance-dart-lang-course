final class Ticket {
  Ticket(this.code);
  final String code;
  bool _redeemed = false;

  bool get isRedeemed => _redeemed;
}

final class TicketGate {
  const TicketGate();

  /// Same library as [Ticket], so it may write `_redeemed`.
  bool admit(Ticket ticket) {
    if (ticket._redeemed) return false;
    ticket._redeemed = true;
    return true;
  }
}

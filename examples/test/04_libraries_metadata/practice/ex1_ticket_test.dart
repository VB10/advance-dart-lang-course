import 'package:dartadvance_examples/04_libraries_metadata/practice/ex1_ticket.dart';
import 'package:test/test.dart';

void main() {
  test('the gate in the same library flips the private flag exactly once', () {
    final ticket = Ticket('A-1');
    const gate = TicketGate();

    expect(ticket.isRedeemed, isFalse);
    expect(gate.admit(ticket), isTrue);
    expect(ticket.isRedeemed, isTrue);
    expect(gate.admit(ticket), isFalse);
  });
}

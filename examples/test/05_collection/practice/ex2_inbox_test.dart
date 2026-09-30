import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/05_collection/practice/ex2_inbox_state.dart';
import 'package:dartadvance_examples/05_collection/practice/ex2_support_ticket.dart';
import 'package:test/test.dart';

SupportTicket _ticket(String id, Severity severity) => SupportTicket(id: id, severity: severity);

void main() {
  test('a missing id is Err(ServerFailure(404)), not a StateError', () {
    final repository = InMemoryTicketRepository([_ticket('t1', Severity.low)]);

    expect(repository.findById('t1'), isA<Ok<SupportTicket>>());
    final failure = (repository.findById('nope') as Err<SupportTicket>).failure;
    expect(failure, isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 404));
  });

  test('highest severity first, FIFO within the same severity', () {
    final inbox = InboxState()
      ..receive(_ticket('n1', Severity.normal))
      ..receive(_ticket('u1', Severity.urgent))
      ..receive(_ticket('n2', Severity.normal))
      ..receive(_ticket('n3', Severity.normal))
      ..receive(_ticket('u2', Severity.urgent));

    final order = [for (var t = inbox.handleNext(); t != null; t = inbox.handleNext()) t.id];
    expect(order, ['u1', 'u2', 'n1', 'n2', 'n3']);
    expect(inbox.handleNext(), isNull);
  });

  test('handled is a live view, handledSnapshot is a copy, neither is writable', () {
    final inbox = InboxState()
      ..receive(_ticket('a', Severity.low))
      ..receive(_ticket('b', Severity.low));
    inbox.handleNext();
    final view = inbox.handled;
    final snapshot = inbox.handledSnapshot();
    inbox.handleNext();

    expect(view.map((t) => t.id), ['a', 'b']);
    expect(snapshot.map((t) => t.id), ['a']);
    expect(() => view.add(_ticket('x', Severity.low)), throwsUnsupportedError);
    expect(() => snapshot.clear(), throwsUnsupportedError);
  });
}

import 'package:dartadvance_examples/06_event_loop_future/record_wait.dart';
import 'package:test/test.dart';

void main() {
  test('record .wait returns a record where each field keeps its type', () async {
    expect(await loadDashboard(Future.value(3), Future.value('Ada')), 'Ada has 3 unread');
  });

  test('ParallelWaitError still carries the successful values', () async {
    expect(
      await loadDashboard(Future<int>.error(StateError('offline')), Future.value('Ada')),
      'partial: name=Ada count=null countError=Bad state: offline',
    );
  });
}

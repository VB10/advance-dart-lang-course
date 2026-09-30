import 'package:dartadvance_examples/06_event_loop_future/future_chain.dart';
import 'package:dartadvance_examples/06_event_loop_future/future_chain_await.dart';
import 'package:test/test.dart';

void main() {
  test('an error skips the remaining then() callbacks until catchError', () async {
    final log = <String>[];
    expect(await longChain(log), 'The value is 42');
    expect(log, ['Got error: error from two']);
  });

  test('await with try/catch gives the same result as the chain', () async {
    final log = <String>[];
    expect(await longChainAwait(log), 'The value is 42');
    expect(log, ['Got error: error from two']);
  });
}

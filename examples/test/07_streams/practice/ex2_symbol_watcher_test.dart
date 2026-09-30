import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/07_streams/practice/ex2_symbol_watcher.dart';
import 'package:dartadvance_examples/07_streams/price_domain.dart';
import 'package:dartadvance_examples/07_streams/price_repository_impl.dart';
import 'package:dartadvance_examples/07_streams/price_socket.dart';
import 'package:test/test.dart';

void main() {
  test('switching symbol ignores the old one and dispose disconnects the socket', () async {
    final socket = InMemoryPriceSocket();
    final watcher = SymbolWatcher(WatchPrices(PriceRepositoryImpl(socket)));

    await watcher.watch('BTC');
    socket.push('{"symbol":"BTC","price":1}');
    await pumpEventQueue();
    expect(watcher.latestPrice, 1);

    await watcher.watch('ETH');
    expect(socket.isConnected, isTrue, reason: 'broadcast: listen again after cancel');
    socket
      ..push('{"symbol":"BTC","price":2}')
      ..push('oops');
    await pumpEventQueue();
    expect(watcher.latestPrice, isNull);
    expect(watcher.lastFailure, isA<UnexpectedFailure>());

    socket.push('{"symbol":"ETH","price":3}');
    await pumpEventQueue();
    expect(watcher.latestPrice, 3);

    await watcher.dispose();
    expect(socket.isConnected, isFalse);
    socket.push('{"symbol":"ETH","price":4}');
    await pumpEventQueue();
    expect(watcher.latestPrice, 3);
    await socket.close();
  });
}

import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/07_streams/price_domain.dart';
import 'package:dartadvance_examples/07_streams/price_repository_impl.dart';
import 'package:dartadvance_examples/07_streams/price_socket.dart';
import 'package:dartadvance_examples/07_streams/price_ticker_notifier.dart';
import 'package:test/test.dart';

void main() {
  test('the socket connects on first listen and disconnects when the notifier disposes', () async {
    final socket = InMemoryPriceSocket();
    final notifier = PriceTickerNotifier(WatchPrices(PriceRepositoryImpl(socket)));
    expect(socket.isConnected, isFalse);

    notifier.start('BTC');
    expect(socket.isConnected, isTrue);
    expect(notifier.isActive, isTrue);

    socket
      ..push('{"symbol":"BTC","price":42000.5}')
      ..push('{"symbol":"ETH","price":1}')
      ..push('not json');
    await pumpEventQueue();
    expect(notifier.latestPrice, 42000.5);
    expect(notifier.lastFailure, isA<UnexpectedFailure>());

    socket.push('{"symbol":"BTC","price":43000}');
    await pumpEventQueue();
    expect(notifier.latestPrice, 43000);
    expect(notifier.lastFailure, isNull);

    await notifier.dispose();
    expect(notifier.isActive, isFalse);
    expect(socket.isConnected, isFalse, reason: 'onCancel closed the connection');

    socket.push('{"symbol":"BTC","price":1}');
    await pumpEventQueue();
    expect(notifier.latestPrice, 43000);
    await socket.close();
  });

  test(
    'the repository maps frames to Result events in order without ending on a bad frame',
    () async {
      final socket = InMemoryPriceSocket();
      final results = PriceRepositoryImpl(socket).watchPrices('BTC');
      final expectation = expectLater(
        results.map(
          (result) => switch (result) {
            Ok(value: PriceTick(:final price)) => price,
            Err() => 'err',
          },
        ),
        emitsInOrder([1.0, 'err', 2.0, emitsDone]),
      );
      await pumpEventQueue();
      socket
        ..push('{"symbol":"BTC","price":1}')
        ..push('{"symbol":"BTC"}')
        ..push('{"symbol":"BTC","price":2}');
      await socket.close();
      await expectation;
    },
  );
}

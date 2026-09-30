import 'dart:convert';

import '../00_architecture/result.dart';
import 'price_domain.dart';
import 'price_socket.dart';

final class PriceRepositoryImpl implements PriceRepository {
  const PriceRepositoryImpl(this._socket);
  final InMemoryPriceSocket _socket;

  @override
  Stream<Result<PriceTick>> watchPrices(String symbol) =>
      _socket.frames.map(_decode).where((result) => _belongsTo(result, symbol));

  static bool _belongsTo(Result<PriceTick> result, String symbol) => switch (result) {
    Ok(:final value) => value.symbol == symbol,
    Err() => true,
  };

  static Result<PriceTick> _decode(String frame) {
    try {
      return _parse(jsonDecode(frame));
    } on FormatException catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }

  static Result<PriceTick> _parse(Object? json) => switch (json) {
    {'symbol': final String symbol, 'price': final num price} => Ok(
      PriceTick(symbol: symbol, price: price.toDouble()),
    ),
    _ => Err(UnexpectedFailure(FormatException('Bad price frame: $json'), StackTrace.current)),
  };
}

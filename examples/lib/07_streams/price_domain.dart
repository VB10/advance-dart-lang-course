import '../00_architecture/result.dart';

final class PriceTick {
  const PriceTick({required this.symbol, required this.price});
  final String symbol;
  final double price;
}

abstract interface class PriceRepository {
  /// A bad frame is an `Err` event, not the end of the stream.
  Stream<Result<PriceTick>> watchPrices(String symbol);
}

final class WatchPrices {
  const WatchPrices(this._repository);
  final PriceRepository _repository;

  Stream<Result<PriceTick>> call(String symbol) => _repository.watchPrices(symbol);
}

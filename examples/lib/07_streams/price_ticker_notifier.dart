import 'dart:async';

import '../00_architecture/result.dart';
import 'price_domain.dart';

final class PriceTickerNotifier {
  PriceTickerNotifier(this._watchPrices);
  final WatchPrices _watchPrices;

  StreamSubscription<Result<PriceTick>>? _subscription;

  double? latestPrice;
  Failure? lastFailure;

  bool get isActive => _subscription != null;

  void start(String symbol) {
    _subscription ??= _watchPrices(symbol).listen(_onResult);
  }

  void _onResult(Result<PriceTick> result) => switch (result) {
    Ok(:final value) => _showPrice(value.price),
    Err(:final failure) => _showFailure(failure),
  };

  void _showPrice(double price) {
    latestPrice = price;
    lastFailure = null;
  }

  void _showFailure(Failure failure) {
    lastFailure = failure;
  }

  /// Awaiting `cancel()` waits until the source has finished its cleanup.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

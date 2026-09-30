import 'dart:async';

final class PriceWatcher {
  PriceWatcher(this._prices);
  final Stream<double> _prices;

  StreamSubscription<double>? _subscription;
  double? latestPrice;

  void start() {
    _subscription ??= _prices.listen((price) => latestPrice = price);
  }

  /// Awaiting `cancel()` waits until the source has finished its cleanup.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

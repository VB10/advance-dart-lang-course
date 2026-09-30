import 'dart:async';

import '../../00_architecture/result.dart';
import '../price_domain.dart';

final class SymbolWatcher {
  SymbolWatcher(this._watchPrices);
  final WatchPrices _watchPrices;

  StreamSubscription<Result<PriceTick>>? _subscription;

  String? symbol;
  double? latestPrice;
  Failure? lastFailure;

  /// Cancels the previous subscription first: old frames cannot leak in.
  Future<void> watch(String newSymbol) async {
    await _subscription?.cancel();
    symbol = newSymbol;
    latestPrice = null;
    lastFailure = null;
    _subscription = _watchPrices(newSymbol).listen(_onResult);
  }

  void _onResult(Result<PriceTick> result) => switch (result) {
    Ok(:final value) => _showPrice(value.price),
    Err(:final failure) => _showFailure(failure),
  };

  void _showPrice(double price) {
    latestPrice = price;
  }

  void _showFailure(Failure failure) {
    lastFailure = failure;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

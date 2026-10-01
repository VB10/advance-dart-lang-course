// Skill'e ver: "Projemde stream dinleyip dispose'da cancel etmeyen state'leri bul,
// subscription'ı alanda tutup `await cancel()` ile düzelt, her biri için test yaz."
import 'dart:async';

final class PriceWatcher {
  PriceWatcher(this._prices);
  final Stream<double> _prices;

  StreamSubscription<double>? _subscription;
  double? latestPrice;

  void start() {
    _subscription ??= _prices.listen((price) => latestPrice = price); // start twice: one listener
  }

  Future<void> dispose() async {
    await _subscription?.cancel(); // after this, source onCancel ran
    _subscription = null;
  }
}

import 'package:async/async.dart' hide Result;

final class Debouncer {
  Debouncer(Duration wait, void Function() action) : _timer = RestartableTimer(wait, action) {
    _timer.cancel(); // idle until the first `ping`
  }
  final RestartableTimer _timer;

  /// Restarts the full countdown, even after the timer fired.
  void ping() => _timer.reset();

  void dispose() => _timer.cancel();
}

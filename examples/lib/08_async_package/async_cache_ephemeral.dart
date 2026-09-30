import 'package:async/async.dart' hide Result;

/// Shares only in-flight calls; the next call after completion fetches again.
final class TokenRefresher {
  TokenRefresher(this._refresh);
  final Future<String> Function() _refresh;
  final _inFlight = AsyncCache<String>.ephemeral();

  Future<String> refresh() => _inFlight.fetch(_refresh);
}

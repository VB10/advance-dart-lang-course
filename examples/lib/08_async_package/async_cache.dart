import 'package:async/async.dart' hide Result;

/// Fresh for [ttl] after the fetch completes; a failed fetch is cached too.
final class RatesCache {
  RatesCache(this._fetch, {required Duration ttl}) : _cache = AsyncCache(ttl);
  final Future<double> Function() _fetch;
  final AsyncCache<double> _cache;

  Future<double> get rate => _cache.fetch(_fetch);

  void refresh() => _cache.invalidate();
}

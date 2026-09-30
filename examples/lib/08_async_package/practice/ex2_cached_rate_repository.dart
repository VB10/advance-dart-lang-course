import 'package:async/async.dart' hide Result;

import '../../00_architecture/result.dart';

abstract interface class RateRepository {
  Future<Result<double>> usdTo(String currency);
}

abstract interface class RateRemoteDataSource {
  Future<double> fetchRate(String currency);
}

final class CachedRateRepository implements RateRepository {
  CachedRateRepository(this._remote, {required this.ttl});
  final RateRemoteDataSource _remote;
  final Duration ttl;
  final _caches = <String, AsyncCache<double>>{};

  @override
  Future<Result<double>> usdTo(String currency) async {
    final cache = _caches[currency] ??= AsyncCache(ttl);
    try {
      return Ok(await cache.fetch(() => _remote.fetchRate(currency)));
    } catch (error, stackTrace) {
      // AsyncCache stores the failed future: drop it so the next call retries.
      cache.invalidate();
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

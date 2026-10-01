// Düzelt: /dartadvance Projemde kur/fiyat/stok gibi veriyi her okumada çeken yerleri bul,
//    AsyncCache (package:async) ile TTL'li önbelleğe al, her biri için test yaz.
// Üret: /dartadvance Bana sipariş kargo ücretini 30 saniye boyunca tekrar istemeden
//    hatırlayan bir servis yaz.
import 'package:async/async.dart' hide Result;

final class RatesCache {
  RatesCache(this._fetch, {required Duration ttl}) : _cache = AsyncCache(ttl);
  final Future<double> Function() _fetch;
  final AsyncCache<double> _cache;

  Future<double> get rateNaive => _fetch(); // 2 reads: 2 fetches

  Future<double> get rate => _cache.fetch(_fetch); // 2 reads: 1 fetch

  void refresh() => _cache.invalidate(); // a failed fetch is cached for the TTL too
}

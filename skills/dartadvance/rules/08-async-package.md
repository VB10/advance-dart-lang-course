# 08 · package:async
> Kaynak: https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries · https://dart.dev/language/libraries#importing-only-part-of-a-library · https://dart.dev/language/libraries#specifying-a-library-prefix · Min. sürüm: package:async 2.13 (Dart 3.4+)

`dart:async`'in çözmediği işler (iptal, tek-seferlik/TTL'li önbellek, sıralı stream okuma, stream birleştirme) için; Data katmanında (repository/data source) ve state sınıfında yaşar, Domain sözleşmesine (`Future<Result<T>>`) sızmaz.

**İsim çakışması:** `package:async/async.dart` kendi `Result` sınıfını export eder. Domain `Result<T>` ile birlikte import edilirse analyzer `ambiguous_import` ile reddeder. Kural: `import 'package:async/async.dart' hide Result;` (gerekirse `as async_pkg show Result`).

## 1. CancelableOperation (2.x)
**Ne:** Bir `Future`'ı iptal edilebilir sarar; iptalde sonuç atılır, `valueOrCancellation()` `null` döner. **Ne zaman:** search-as-you-type, son sorgu kazansın. **Gerekmez:** sadece süre sınırı (`Future.timeout`).
<!-- snippet: 08_async_package/cancelable_search -->
```dart
import 'package:async/async.dart' hide Result;

/// Search-as-you-type: only the latest query may deliver results.
final class ProductSearch {
  ProductSearch(this._fetch);
  final Future<List<String>> Function(String query) _fetch;
  CancelableOperation<List<String>>? _running;

  Future<List<String>?> search(String query) {
    _running?.cancel();
    final operation = CancelableOperation.fromFuture(_fetch(query));
    _running = operation;
    // null means this query was replaced by a newer one.
    return operation.valueOrCancellation();
  }
}
```
**Tuzak:** İptal alttaki isteği durdurmaz, yalnızca sonucunu yok sayar; tamamlanmış işte `cancel()` bir şey yapmaz (testte kanıtlı).
**Skill'e ver:** > "Bir profil ekranında kullanıcı adı müsaitlik kontrolü yaz: her tuş vuruşunda yeni istek atılsın, yalnızca son yazılanın sonucu `bool?` olarak dönsün, eskiler `null` dönsün."
**Kabul:** Eski çağrı `null`, yeni çağrı değer döner; `hide Result` kullanılır; `dart analyze` temiz.

## 2. AsyncMemoizer (2.x)
**Ne:** Async işi bir kez çalıştırır, sonraki/eşzamanlı çağıranlar aynı future'ı alır. **Ne zaman:** pahalı init (config, veritabanı açma). **Gerekmez:** hata sonrası yeniden deneme gerekiyorsa.
<!-- snippet: 08_async_package/async_memoizer -->
```dart
import 'package:async/async.dart' hide Result;

/// Runs [_load] once; a failure is memoized too, forever.
final class ConfigLoader {
  ConfigLoader(this._load);
  final Future<Map<String, String>> Function() _load;
  final _memo = AsyncMemoizer<Map<String, String>>();

  Future<Map<String, String>> get config => _memo.runOnce(_load);

  bool get hasLoaded => _memo.hasRun;
}
```
**Tuzak:** Hata da sonsuza kadar saklanır, tekrar denenmez (testte kanıtlı).
**Skill'e ver:** > "Sepet servisi için kampanya listesini uygulama açılışında bir kez yükleyen `CampaignLoader` yaz; aynı anda üç ekran isterse tek istek atılsın."
**Kabul:** Yükleyici fonksiyon sayacı 1 kalır (eşzamanlı ve sonraki çağrılarda); `hasRun` doğrulanır.

## 3. AsyncCache (2.x)
**Ne:** Sonucu süre boyunca taze tutar; `invalidate()` ile sıfırlanır. **Ne zaman:** kur, fiyat, ayar gibi kısa ömürlü veri. **Gerekmez:** anahtarlı/çok girdili önbellek (tek değer tutar).
<!-- snippet: 08_async_package/async_cache -->
```dart
import 'package:async/async.dart' hide Result;

/// Fresh for [ttl] after the fetch completes; a failed fetch is cached too.
final class RatesCache {
  RatesCache(this._fetch, {required Duration ttl}) : _cache = AsyncCache(ttl);
  final Future<double> Function() _fetch;
  final AsyncCache<double> _cache;

  Future<double> get rate => _cache.fetch(_fetch);

  void refresh() => _cache.invalidate();
}
```
**Tuzak:** Başarısız istek de TTL boyunca önbellekte kalır (testte kanıtlı).
**Skill'e ver:** > "Ürün stok durumu için 30 saniye TTL'li bir `StockCache` yaz; `refresh()` çağrısı bir sonraki okumada yeniden istek attırsın."
**Kabul:** TTL içinde tek fetch; `invalidate` sonrası ikinci fetch; `Duration.zero` ile her seferinde yenilenir.

## 4. StreamQueue (2.x)
**Ne:** Stream'i pull-based okutur: `next`, `take(n)`, `peek`, `hasNext`, `rest`. **Ne zaman:** protokol/başlık+gövde parse, testlerde olayları tek tek okumak. **Gerekmez:** her olay aynı işleniyorsa (`await for`).
<!-- snippet: 08_async_package/stream_queue -->
```dart
import 'package:async/async.dart' hide Result;

/// Reads a header line such as `ORDER 2`, then exactly that many item lines.
Future<({String title, List<String> items})> readMessage(Stream<String> lines) async {
  final queue = StreamQueue(lines);
  try {
    final header = await queue.next;
    final [title, count] = header.split(' ');
    final items = await queue.take(int.parse(count));
    return (title: title, items: items);
  } finally {
    await queue.cancel();
  }
}
```
**Tuzak:** Stream biterse `next` `StateError` fırlatır; önce `hasNext` sor, işin bitince `cancel()` et (testte kanıtlı).
**Skill'e ver:** > "Bir kargo takip stream'inden önce `STATUS 3` başlığını, sonra tam 3 adım satırını okuyan fonksiyon yaz."
**Kabul:** Başlıktaki sayı kadar öğe döner; `finally` içinde `queue.cancel()` vardır.

## 5. StreamGroup ve StreamSplitter (2.x)
**Ne:** `StreamGroup.merge` birçok kaynağı tek stream yapar; `StreamSplitter` tek-abonelikli stream'i birden çok tüketiciye tüm olaylarla verir. **Ne zaman:** iki canlı kaynak (sunucu + cihaz), bir stream'den hem sayaç hem toplam. **Gerekmez:** kaynak tek, ya da geç gelen dinleyici eski olayı görmeyecekse (`asBroadcastStream`).
<!-- snippet: 08_async_package/stream_group -->
```dart
import 'package:async/async.dart' hide Result;

/// Two live sources, one stream; closes after both have closed.
Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]);

/// Every branch sees every event, even a single-subscription stream.
Future<(int count, int total)> countAndTotal(Stream<int> prices) async {
  final [forCount, forTotal] = StreamSplitter.splitFrom(prices);
  return (forCount.length, forTotal.fold(0, (sum, price) => sum + price)).wait;
}
```
**Tuzak:** `asBroadcastStream` geç dinleyiciye eski olayları vermez, splitter verir (testte kanıtlı); merge ancak tüm kaynaklar kapanınca kapanır.
**Skill'e ver:** > "Mesajlaşma ekranı için iki WebSocket benzeri `Stream<String>` kaynağını birleştir; ayrıca gelen mesaj akışından hem okunmamış sayısı hem son mesajı üret."
**Kabul:** Merge iki kaynaktan da olay iletir, ikisi kapanınca biter; splitter'ın her kolu tüm olayları görür.

## Flutter'da kanıt
Flutter 3.47.5 `packages/flutter/lib` içinde package:async kullanmaz; aynı fikirler elle yazılmıştır (bu yüzden bağımlılık politikası, API uyarısı değil):
- Son çağrı kazanır: [`_RawAutocompleteState._onChangedCallId`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/autocomplete.dart#L498) (`CancelableOperation` fikri).
- Sonucu yok say: [`_FutureBuilderState._activeCallbackIdentity`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L642) (`fromFuture`).
- Uçuştaki işi paylaş: [`ImageCache.putIfAbsent`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_cache.dart#L330) (`AsyncCache.ephemeral` fikri).
- Birleştirme: [`Listenable.merge`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L495) (`StreamGroup.merge` karşılığı).

## Kontrol listesi
- [ ] `package:async` her zaman `hide Result` (veya prefix) ile import edilir.
- [ ] Domain sözleşmesi `Future<Result<T>>` kalır, package:async tipleri sızmaz.
- [ ] İptal "sonucu yok say" demektir; iş gerçekten durmalıysa `CancelableCompleter(onCancel:)`.
- [ ] Hata tekrar denenecekse `AsyncMemoizer` değil; `AsyncCache` hatayı da TTL boyunca tutar.
- [ ] `StreamQueue` işi bitince `cancel()` edilir.
- [ ] Geç dinleyici eski olayı görmeli mi? Evet: `StreamSplitter`, hayır: `asBroadcastStream`.

## Pekiştirme
- **Kolay:** `ProductSearch`'ü `List<String>` yerine `List<Product>` dönecek şekilde genelle; eski çağrı yine `null` dönmeli (mevcut testler yeşil).
- **Zor:** `AsyncCache`'in hata sonucunu saklamamasını sağla (hata olunca `invalidate()`); hata sonrası ikinci okumanın yeniden fetch yaptığını testle göster.

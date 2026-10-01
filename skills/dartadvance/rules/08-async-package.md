# 08 · package:async
> Kaynak: https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries · https://dart.dev/language/libraries#importing-only-part-of-a-library · https://dart.dev/language/libraries#specifying-a-library-prefix · Min. sürüm: package:async 2.13 (Dart 3.4+)
Neden bu konu: Arama kutusu, config yükleme ve stream okuma kodları sessizce eski yanıtı gösterir ya da aynı işi tekrar tekrar yapar; `package:async` bunları tek satırda çözer.

`dart:async`'in çözmediği işler (iptal, tek-seferlik/TTL'li önbellek, sıralı stream okuma, stream birleştirme) için; Data katmanında (repository/data source) ve state sınıfında yaşar; dışarıya `package:async` tipi sızdırılmaz.

**İsim çakışması:** `package:async/async.dart` kendi `Result` sınıfını export eder. Projen kendi `Result` sınıfını tanımlıyorsa ikisi birlikte import edilince analyzer `ambiguous_import` ile reddeder. Kural: `import 'package:async/async.dart' hide Result;` (gerekirse `as async_pkg show Result`).

## 1. CancelableOperation (2.x)
**Ne:** Bir `Future`'ı iptal edilebilir sarar; iptalde sonuç atılır, `valueOrCancellation()` `null` döner. **Ne zaman:** search-as-you-type, son sorgu kazansın. **Gerekmez:** sadece süre sınırı (`Future.timeout`).
<!-- snippet: 08_async_package/cancelable_search -->
```dart
// Düzelt: /dartadvance Projemde her tuş vuruşunda istek atan arama yerlerini bul,
//    CancelableOperation (package:async) ile son sorgu kazansın, her biri için test yaz.
// Üret: /dartadvance Bana kullanıcı yazdıkça şehir önerisi getiren, eski sorgunun geç gelen
//    cevabını yok sayan bir sınıf yaz.
import 'package:async/async.dart' hide Result;

final class ProductSearch {
  ProductSearch(this._fetch);
  final Future<List<String>> Function(String query) _fetch;
  CancelableOperation<List<String>>? _running;

  /// Naive: every reply is delivered, so a slow old reply can land last.
  Future<List<String>> searchNaive(String query) => _fetch(query); // stale: delivered

  Future<List<String>?> search(String query) {
    _running?.cancel();
    final operation = CancelableOperation.fromFuture(_fetch(query));
    _running = operation;
    return operation.valueOrCancellation(); // replaced query: null
  }
}
```
**Tuzak:** Naif sürümde yavaş eski cevap en son gelip ekranı ezer. İptal alttaki isteği durdurmaz, yalnızca sonucunu yok sayar; tamamlanmış işte `cancel()` bir şey yapmaz (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde her tuş vuruşunda istek atan arama yerlerini bul, CancelableOperation (package:async) ile son sorgu kazansın, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana kullanıcı yazdıkça şehir önerisi getiren, eski sorgunun geç gelen cevabını yok sayan bir sınıf yaz."
**Kabul:** Eski çağrı `null`, yeni çağrı değer döner; eski cevabın geç gelmesi sonucu ezmez; `hide Result` kullanılır; `dart analyze` temiz.

## 2. AsyncMemoizer (2.x)
**Ne:** Async işi bir kez çalıştırır, sonraki/eşzamanlı çağıranlar aynı future'ı alır. **Ne zaman:** pahalı init (config, veritabanı açma). **Gerekmez:** hata sonrası yeniden deneme gerekiyorsa.
<!-- snippet: 08_async_package/async_memoizer -->
```dart
// Düzelt: /dartadvance Projemde tekrar tekrar yüklenen config/liste yerlerini bul,
//    AsyncMemoizer (package:async) ile tek seferlik yap, her biri için test yaz.
// Üret: /dartadvance Bana ödeme ayarlarını ağdan yalnız bir kez yükleyip eşzamanlı
//    çağıranlarla paylaşan bir sınıf yaz.
import 'package:async/async.dart' hide Result;

final class ConfigLoader {
  ConfigLoader(this._load);
  final Future<Map<String, String>> Function() _load;
  final _memo = AsyncMemoizer<Map<String, String>>();

  Future<Map<String, String>> get configNaive => _load(); // 3 callers: 3 loads

  Future<Map<String, String>> get config => _memo.runOnce(_load); // 3 callers: 1 load

  bool get hasLoaded => _memo.hasRun; // a failure is memoized too, forever
}
```
**Tuzak:** Hata da sonsuza kadar saklanır, tekrar denenmez (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde tekrar tekrar yüklenen config/liste yerlerini bul, AsyncMemoizer (package:async) ile tek seferlik yap, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ödeme ayarlarını ağdan yalnız bir kez yükleyip eşzamanlı çağıranlarla paylaşan bir sınıf yaz."
**Kabul:** Eşzamanlı ve sonraki çağrılarda yükleyici sayacı 1 kalır; `hasRun` doğrulanır.

## 3. AsyncCache (2.x)
**Ne:** Sonucu süre boyunca taze tutar; `invalidate()` ile sıfırlanır. **Ne zaman:** kur, fiyat, ayar gibi kısa ömürlü veri. **Gerekmez:** anahtarlı/çok girdili önbellek (tek değer tutar).
<!-- snippet: 08_async_package/async_cache -->
```dart
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
```
**Tuzak:** Başarısız istek de TTL boyunca önbellekte kalır (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde kur/fiyat/stok gibi veriyi her okumada çeken yerleri bul, AsyncCache (package:async) ile TTL'li önbelleğe al, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş kargo ücretini 30 saniye boyunca tekrar istemeden hatırlayan bir servis yaz."
**Kabul:** TTL içinde tek fetch; `invalidate` sonrası ikinci fetch; `Duration.zero` ile her okumada yenilenir (süre dolumu zamanlayıcıyla olur; testte ardışık okumaların arasına `await Future<void>.delayed(Duration.zero)` koy).

## 4. StreamQueue (2.x)
**Ne:** Stream'i pull-based okutur: `next`, `take(n)`, `peek`, `hasNext`, `rest`. **Ne zaman:** protokol/başlık+gövde parse, testlerde olayları tek tek okumak. **Gerekmez:** her olay aynı işleniyorsa (`await for`).
<!-- snippet: 08_async_package/stream_queue -->
```dart
// Düzelt: /dartadvance Projemde başlık+gövde sırayla okunan stream parse yerlerini bul,
//    StreamQueue (package:async) ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana ilk satırı 'FATURA 3' gibi kalem sayısı, sonra o kadar satırı
//    okuyan bir fatura parser'ı yaz.
import 'package:async/async.dart' hide Result;

Future<List<String>> readItemsNaive(Stream<String> lines) async {
  await lines.first;
  return lines.take(2).toList(); // StateError: stream already listened to
}

Future<({String title, List<String> items})> readMessage(Stream<String> lines) async {
  final queue = StreamQueue(lines);
  try {
    final header = await queue.next;
    final [title, count] = header.split(' ');
    final items = await queue.take(int.parse(count));
    return (title: title, items: items); // 'ORDER 2' -> 2 items
  } finally {
    await queue.cancel();
  }
}
```
**Tuzak:** Stream biterse `next` `StateError` fırlatır; önce `hasNext` sor, işin bitince `cancel()` et (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde başlık+gövde sırayla okunan stream parse yerlerini bul, StreamQueue (package:async) ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ilk satırı 'FATURA 3' gibi kalem sayısı, sonra o kadar satırı okuyan bir fatura parser'ı yaz."
**Kabul:** Başlıktaki sayı kadar öğe döner; `finally` içinde `queue.cancel()` vardır; tek-abonelikli stream'e ikinci `listen` yoktur.

## 5. StreamGroup ve StreamSplitter (2.x)
**Ne:** `StreamGroup.merge` birçok kaynağı tek stream yapar; `StreamSplitter` tek-abonelikli stream'i birden çok tüketiciye tüm olaylarla verir. **Ne zaman:** iki canlı kaynak (sunucu + cihaz), bir stream'den hem sayaç hem toplam. **Gerekmez:** kaynak tek, ya da geç gelen dinleyici eski olayı görmeyecekse (`asBroadcastStream`).
<!-- snippet: 08_async_package/stream_group -->
```dart
// Düzelt: /dartadvance Projemde aynı stream'i iki kez dinleyen yerleri bul, StreamSplitter
//    ve StreamGroup (package:async) ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana çalma listesi stream'inden şarkı sayısını ve toplam süreyi tek
//    geçişte hesaplayan fonksiyon yaz.
import 'package:async/async.dart' hide Result;

Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]); // closes after both have closed

Future<(int, int)> countAndTotalNaive(Stream<int> prices) async =>
    (prices.length, prices.fold(0, (sum, price) => sum + price)).wait; // StateError

Future<(int count, int total)> countAndTotal(Stream<int> prices) async {
  final [forCount, forTotal] = StreamSplitter.splitFrom(prices);
  return (forCount.length, forTotal.fold(0, (sum, price) => sum + price)).wait;
}
```
**Tuzak:** `asBroadcastStream` geç dinleyiciye eski olayları vermez, splitter verir (testte kanıtlı); merge ancak tüm kaynaklar kapanınca kapanır.
**Düzelt (mevcut proje):** > "/dartadvance Projemde aynı stream'i iki kez dinleyen yerleri bul, StreamSplitter ve StreamGroup (package:async) ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana çalma listesi stream'inden şarkı sayısını ve toplam süreyi tek geçişte hesaplayan fonksiyon yaz."
**Kabul:** Splitter'ın her kolu tüm olayları görür (naif çift dinleme `StateError` verirdi); merge iki kaynaktan da olay iletir, ikisi kapanınca biter.

## Flutter'da kanıt
Flutter 3.47.5 `packages/flutter/lib` içinde package:async kullanmaz; aynı fikirler elle yazılmıştır (bu yüzden bağımlılık politikası, API uyarısı değil):
- Son çağrı kazanır: [`_RawAutocompleteState._onChangedCallId`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/autocomplete.dart#L498) (`CancelableOperation` fikri).
- Sonucu yok say: [`_FutureBuilderState._activeCallbackIdentity`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L642) (`fromFuture`).
- Uçuştaki işi paylaş: [`ImageCache.putIfAbsent`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_cache.dart#L330) (`AsyncCache.ephemeral` fikri).
- Birleştirme: [`Listenable.merge`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L495) (`StreamGroup.merge` karşılığı).

## Kontrol listesi
- [ ] `package:async` her zaman `hide Result` (veya prefix) ile import edilir.
- [ ] package:async tipleri (`CancelableOperation`, `StreamQueue`…) public API'ye sızmaz.
- [ ] İptal "sonucu yok say" demektir; iş gerçekten durmalıysa `CancelableCompleter(onCancel:)`.
- [ ] Hata tekrar denenecekse `AsyncMemoizer` değil; `AsyncCache` hatayı da TTL boyunca tutar.
- [ ] `StreamQueue` işi bitince `cancel()` edilir.
- [ ] Geç dinleyici eski olayı görmeli mi? Evet: `StreamSplitter`, hayır: `asBroadcastStream`.

## Pekiştirme
- **Kolay:** `ProductSearch`'ü `List<String>` yerine `List<Product>` dönecek şekilde genelle; eski çağrı yine `null` dönmeli (mevcut testler yeşil).
- **Zor:** `AsyncCache`'in hata sonucunu saklamamasını sağla (hata olunca `invalidate()`); hata sonrası ikinci okumanın yeniden fetch yaptığını testle göster.

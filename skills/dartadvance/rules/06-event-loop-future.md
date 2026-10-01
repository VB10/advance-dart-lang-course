# 06 · Event loop ve Future
> Kaynak: https://dart.dev/language/concurrency#event-loop · https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await · https://dart.dev/libraries/dart-async#waiting-for-multiple-futures · https://dart.dev/libraries/dart-async#handling-errors-for-multiple-futures · https://api.dart.dev/stable/dart-async/unawaited.html · Min. sürüm: Dart 3.0 (record `.wait`)

Neden bu konu: Sıralı `await` ve sessizce yutulan ateşle-unut hatalar Flutter'da yavaş ekran ve görünmeyen hata olarak karşına çıkar.

Her isolate tek bir event loop ile çalışır; `Future` bu döngünün üstündeki sözdür. Data katmanında paralel istek/timeout/callback sarmalamayı, State katmanında ateşle-unut başlatmayı doğru yazmak için gerekir.

## 1. Event loop sırası (her sürüm)
**Ne:** Önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu (`Timer.run`, `Future()`) çalışır. **Ne zaman:** "Bu satır neden sonra çalıştı?" sorusunu açıklarken. **Gerekmez:** Uygulama kodunda sırayı `scheduleMicrotask` ile "düzeltmek"; `await` kullan.
<!-- snippet: 06_event_loop_future/event_loop_order -->
```dart
// Düzelt: /dartadvance Projemde `scheduleMicrotask`, `Timer.run` veya `Future(...)` ile
//   sıra varsayan yerleri bul, event loop sırasına göre düzelt, test yaz.
// Üret: /dartadvance Bana sipariş onaylanınca önce ekran durumunu güncelleyip, işlem
//   bittikten sonra analitik olayını gönderen bir fonksiyon yaz.
import 'dart:async';

/// Sync code first, then every microtask, then event-queue callbacks.
Future<List<String>> orderOfExecution() {
  final log = <String>[];
  final finished = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()'))); // log[4]: last
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask')); // log[1]
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function'); // log[0]: first, though written last

  Timer.run(() => finished.complete(log));
  return finished.future;
}

/// An async function runs synchronously until its first await.
Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null;
  log.add('greet: after await');
}
```
**Tuzak:** `async` fonksiyon ilk `await`'e kadar senkron çalışır; çağıran, `await` etmese bile o kısmı hemen görür.
**Düzelt (mevcut proje):** > "/dartadvance Projemde `scheduleMicrotask`, `Timer.run` veya `Future(...)` ile sıra varsayan yerleri bul, event loop sırasına göre düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş onaylanınca önce ekran durumunu güncelleyip, işlem bittikten sonra analitik olayını gönderen bir fonksiyon yaz."
**Kabul:** Test sırayı `sync → microtask → event` olarak doğrular; sıra varsayımı `await` ile açık hale gelmiş; `dart analyze` temiz.

## 2. Future.wait ve record `.wait` (3.0)
**Ne:** Bağımsız istekleri aynı anda başlatıp bekler; record `.wait` her alanın tipini korur. **Ne zaman:** RepositoryImpl'de iki-üç bağımsız çağrı. **Gerekmez:** İkinci istek birincinin sonucuna bağlıysa; sıralı `await`.
<!-- snippet: 06_event_loop_future/parallel_wait -->
```dart
// Düzelt: /dartadvance Projemde birbirine bağlı olmayan `await`'leri art arda yazan
//   repository yerlerini bul, record `.wait` ile paralel yap, test yaz.
// Üret: /dartadvance Bana bir ürün sayfası için ürün detayını, yorumları ve stok bilgisini
//   getiren bir fonksiyon yaz.
import 'dart:async';

Future<String> loadSequential(Future<int> Function() unread, Future<String> Function() name) async {
  final count = await unread(); // name() starts only after this finishes
  return '${await name()} has $count unread';
}

Future<String> loadParallel(Future<int> Function() unread, Future<String> Function() name) async {
  try {
    final (count, userName) = await (unread(), name()).wait; // both start together
    return '$userName has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    final (count, userName) = error.values; // successes survive, failures are null
    return 'partial: name=$userName count=$count';
  }
}

/// Same-typed requests: results keep input order, only the first error is reported.
Future<List<int>> loadPrices(List<Future<int>> requests) => Future.wait(requests);
```
**Tuzak:** `Future.wait` sonuçları verilen sırayla döner ve yalnız ilk hatayı bildirir; başarılı değerlere `ParallelWaitError.values` ile ulaşılır.
**Düzelt (mevcut proje):** > "/dartadvance Projemde birbirine bağlı olmayan `await`'leri art arda yazan repository yerlerini bul, record `.wait` ile paralel yap, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana bir ürün sayfası için ürün detayını, yorumları ve stok bilgisini getiren bir fonksiyon yaz."
**Kabul:** Test bağımsız çağrıların birlikte başladığını (başlangıç sırası) ve kısmi başarıyı (`values`) kapsar; `dart analyze` temiz.

## 3. timeout ve Completer (her sürüm)
**Ne:** `Completer` callback API'sini `Future`'a çevirir; `.timeout` bekleme süresini sınırlar. **Ne zaman:** Eski SDK sarmalama, ağ/IO sınırı. **Gerekmez:** Zaten `Future` dönen bir şeyi sarmak için `Completer`.
<!-- snippet: 06_event_loop_future/timeout_completer -->
```dart
// Düzelt: /dartadvance Projemde callback tabanlı eski API'leri, süresiz bekleyen çağrıları
//   bul, `Completer` ile Future'a çevir, `timeout` ile sınırla, test yaz.
// Üret: /dartadvance Bana callback ile sonuç veren eski bir ödeme SDK'sını saran, 10 sn'de
//   cevap gelmezse hata veren bir fonksiyon yaz.
import 'dart:async';

abstract interface class LegacyLocationClient {
  void requestCity(void Function(String? city, Object? error) onDone);
}

/// Wraps a callback API into a Future; a Completer completes only once.
Future<String> currentCity(LegacyLocationClient client) {
  final completer = Completer<String>();
  client.requestCity((city, error) {
    if (completer.isCompleted) return;
    if (error != null) return completer.completeError(error);
    completer.complete(city ?? 'unknown');
  });
  return completer.future;
}

/// No limit: a silent client leaves the caller waiting forever.
Future<String> cityForever(LegacyLocationClient client) => currentCity(client); // pending

Future<String> cityOrThrow(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit); // silent client: TimeoutException

Future<String> cityOrDefault(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit, onTimeout: () => 'Istanbul'); // silent: Istanbul
```
**Tuzak:** `timeout` kaynak future'ı iptal etmez; geç gelen sonuç yok sayılır, `Completer` ikinci kez tamamlanırsa `StateError` atar (`isCompleted` ile koru).
**Düzelt (mevcut proje):** > "/dartadvance Projemde callback tabanlı eski API'leri, süresiz bekleyen çağrıları bul, `Completer` ile Future'a çevir, `timeout` ile sınırla, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana callback ile sonuç veren eski bir ödeme SDK'sını saran, 10 sn'de cevap gelmezse hata veren bir fonksiyon yaz."
**Kabul:** Test sessiz SDK'de `TimeoutException`'ı, çift callback'te yalnız ilk sonucu doğrular; süresiz bekleyen çağrı kalmaz.

## 4. unawaited, ignore ve ateşle-unut hatalar (unawaited 2.15, ignore 2.14)
**Ne:** `unawaited` "bilerek beklemiyorum" der; `ignore()` hatayı da yutar. **Ne zaman:** `initState` gibi senkron yerden analitik/önbellek ısıtma. **Gerekmez:** Sonucu veya hatası önemliyse; `await` et.
<!-- snippet: 06_event_loop_future/fire_and_forget -->
```dart
// Düzelt: /dartadvance Projemde beklenmeden çağrılan Future'ları (`unawaited`) bul,
//   hatasını `catchError` ile ele alacak şekilde düzelt, test yaz.
// Üret: /dartadvance Bana fatura ekranı açılırken sonucu beklemeden önbelleği ısıtan,
//   hatayı kaybetmeyen bir fonksiyon yaz.
import 'dart:async';

final class AnalyticsClient {
  Future<void> send(String event) async => throw StateError('offline: $event');
}

/// unawaited only silences the lint; a failure is still an unhandled error.
void trackScreenOpenedLoud(AnalyticsClient analytics) {
  unawaited(analytics.send('screen_opened')); // error: unhandled
}

/// ignore() also marks the error as handled, so nothing is reported.
void trackScreenOpenedQuiet(AnalyticsClient analytics) {
  analytics.send('screen_opened').ignore(); // error: swallowed silently
}

/// Safest: handle the failure yourself, then fire and forget.
void trackScreenOpenedSafe(AnalyticsClient analytics, void Function(Object) report) {
  unawaited(analytics.send('screen_opened').catchError(report)); // error: reported
}
```
**Tuzak:** `unawaited` hatayı yutmaz; hata yine işlenmemiş (unhandled) olur, `ignore()` ise sessizce yutar.
**Düzelt (mevcut proje):** > "/dartadvance Projemde beklenmeden çağrılan Future'ları (`unawaited`) bul, hatasını `catchError` ile ele alacak şekilde düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana fatura ekranı açılırken sonucu beklemeden önbelleği ısıtan, hatayı kaybetmeyen bir fonksiyon yaz."
**Kabul:** Test hatanın zone'a sızmadığını ve `catchError` ile raporlandığını doğrular; `dart analyze` temiz.

## Flutter'da kanıt
- `SchedulerBinding.endOfFrame`: `Completer<void>` ile callback'i Future'a çevirir — [binding.dart#L852](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L852)
- `precacheImage`: `if (!completer.isCompleted)` koruması — [image.dart#L128](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/image.dart#L128)
- `FocusManager._markNeedsUpdate`: aynı turdaki değişiklikleri `scheduleMicrotask` ile bir kez işler — [focus_manager.dart#L1947](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/focus_manager.dart#L1947)
- `unawaited(_forceRepaint())`: yanıtı bloklamadan döner — [rendering/binding.dart#L91](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/binding.dart#L91)

## Kontrol listesi
- [ ] Bağımsız istekler sıralı `await` yerine birlikte başlatılıp `.wait` ile mi bekleniyor?
- [ ] Kısmi sonuç gerekiyorsa `ParallelWaitError.values` kullanıldı mı?
- [ ] Ağ/IO çağrısında `.timeout()` var ve `TimeoutException` bir hataya çevriliyor mu?
- [ ] `Completer` yalnız callback API'lerinde, `isCompleted` korumasıyla mı?
- [ ] `unawaited` yalnız hatası zaten ele alınmış Future'da mı?

## Pekiştirme
- Kolay: `Timer.run`, `scheduleMicrotask` ve `Future()` ile 3 log yaz, çıktı sırasını önceden tahmin et; "bitti" = tahmin testle eşleşir.
- Zor: Üç bağımsız çağrıyı (`(a, b, c).wait`) 2 sn timeout ile birleştir, biri düşerse kalanları göster; "bitti" = tam ve kısmi başarı ile timeout için üç test yeşil.

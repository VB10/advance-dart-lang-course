# 06 · Event loop ve Future
> Kaynak: https://dart.dev/language/concurrency#event-loop · https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await · https://dart.dev/libraries/dart-async#waiting-for-multiple-futures · https://dart.dev/libraries/dart-async#handling-errors-for-multiple-futures · https://api.dart.dev/stable/dart-async/unawaited.html · Min. sürüm: Dart 3.0 (record `.wait`)

Her isolate tek bir event loop ile çalışır; `Future` bu döngünün üstündeki sözdür. Data katmanında paralel istek/timeout/callback sarmalamayı, State katmanında ateşle-unut başlatmayı doğru yazmak için gerekir.

## 1. Event loop sırası (her sürüm)
**Ne:** Önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu (`Timer.run`, `Future()`) çalışır. **Ne zaman:** "Bu satır neden sonra çalıştı?" sorusunu açıklarken. **Gerekmez:** Uygulama kodunda sırayı `scheduleMicrotask` ile "düzeltmek"; `await` kullan.
<!-- snippet: 06_event_loop_future/event_loop_order -->
```dart
import 'dart:async';

/// Records the order in which each kind of callback runs.
Future<List<String>> orderOfExecution() {
  final log = <String>[];
  final finished = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()')));
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask'));
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function');

  Timer.run(() => finished.complete(log));
  return finished.future;
}

/// An async function runs synchronously until its first await.
Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null; // the rest continues in a microtask
  log.add('greet: after await');
}
```
**Tuzak:** `async` fonksiyon ilk `await`'e kadar senkron çalışır; çağıran, `await` etmese bile o kısmı hemen görür.
**Skill'e ver:** > "Bir sipariş takip ekranı için: senkron log, microtask ve Timer.run ile iki bildirimin hangi sırada çalıştığını kaydeden `orderOfNotifications()` yaz."
**Kabul:** Test sırayı `sync → microtask → event` olarak doğrular; `dart analyze` temiz.

## 2. Future.wait ve record `.wait` (3.0)
**Ne:** Bağımsız istekleri aynı anda başlatıp bekler; record `.wait` her alanın tipini korur. **Ne zaman:** RepositoryImpl'de iki-üç bağımsız çağrı. **Gerekmez:** İkinci istek birincinin sonucuna bağlıysa; sıralı `await`.
<!-- snippet: 06_event_loop_future/parallel_wait -->
```dart
import 'dart:async';

/// Both requests start together; each field keeps its own type.
Future<String> loadDashboard(Future<int> unreadCount, Future<String> userName) async {
  try {
    final (count, name) = await (unreadCount, userName).wait;
    return '$name has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    // Successful results are still available; failed ones are null.
    final (count, name) = error.values;
    final (countError, _) = error.errors;
    return 'partial: name=$name count=$count countError=${countError?.error}';
  }
}

/// Same-typed requests: results keep input order, only the first error is reported.
Future<List<int>> loadPrices(List<Future<int>> requests) => Future.wait(requests);
```
**Tuzak:** `Future.wait` sonuçları verilen sırayla döner ve yalnız ilk hatayı bildirir; başarılı değerlere `ParallelWaitError.values` ile ulaşılır.
**Skill'e ver:** > "Ürün detay ekranı için `(Future<Product>, Future<int>) stock` çiftini record `.wait` ile bekleyen ve stok hata verirse ürünü yine gösteren `loadProductPage` yaz."
**Kabul:** Test hem tam başarıyı hem kısmi başarıyı (`values`) kapsar; istekler `try`'dan önce başlatılır.

## 3. timeout ve Completer (her sürüm)
**Ne:** `Completer` callback API'sini `Future`'a çevirir; `.timeout` bekleme süresini sınırlar. **Ne zaman:** Eski SDK sarmalama, ağ/IO sınırı. **Gerekmez:** Zaten `Future` dönen bir şeyi sarmak için `Completer`.
<!-- snippet: 06_event_loop_future/timeout_completer -->
```dart
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

/// Throws [TimeoutException] when [limit] passes first.
Future<String> cityOrThrow(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit);

/// The source future is not cancelled; its late result is ignored.
Future<String> cityOrDefault(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit, onTimeout: () => 'Istanbul');
```
**Tuzak:** `timeout` kaynak future'ı iptal etmez; geç gelen sonuç yok sayılır, `Completer` ikinci kez tamamlanırsa `StateError` atar (`isCompleted` ile koru).
**Skill'e ver:** > "Callback tabanlı bir `PaymentSdk.charge(onDone)` API'sini `Future<Receipt>`'e çeviren ve 5 saniyede `TimeoutException` fırlatan `chargeOrThrow` yaz."
**Kabul:** Test sessiz SDK'de `TimeoutException`'ı, çift callback'te yalnız ilk sonucu doğrular.

## 4. unawaited, ignore ve ateşle-unut hatalar (unawaited 2.15, ignore 2.14)
**Ne:** `unawaited` "bilerek beklemiyorum" der; `ignore()` hatayı da yutar. **Ne zaman:** `initState` gibi senkron yerden analitik/önbellek ısıtma. **Gerekmez:** Sonucu veya hatası önemliyse; `await` et.
<!-- snippet: 06_event_loop_future/fire_and_forget -->
```dart
import 'dart:async';

final class AnalyticsClient {
  Future<void> send(String event) async => throw StateError('offline: $event');
}

/// unawaited only silences the lint; a failure is still an unhandled error.
void trackScreenOpenedLoud(AnalyticsClient analytics) {
  unawaited(analytics.send('screen_opened'));
}

/// ignore() also marks the error as handled, so nothing is reported.
void trackScreenOpenedQuiet(AnalyticsClient analytics) {
  analytics.send('screen_opened').ignore();
}

/// Safest: handle the failure yourself, then fire and forget.
void trackScreenOpenedSafe(AnalyticsClient analytics, void Function(Object) report) {
  unawaited(analytics.send('screen_opened').catchError(report));
}
```
**Tuzak:** `unawaited` hatayı yutmaz; hata yine işlenmemiş (unhandled) olur, `ignore()` ise sessizce yutar.
**Skill'e ver:** > "Sepet ekranı açılınca `CartSync.push()` çağrısını ateşle-unut yapan `onCartOpened` yaz; hata olursa `logError`'a düşsün, uygulama çökmesin."
**Kabul:** Test hatanın zone'a sızmadığını ve `logError`'a ulaştığını doğrular.

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

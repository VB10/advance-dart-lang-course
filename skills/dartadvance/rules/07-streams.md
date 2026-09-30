# 07 · Streams
> Kaynak: https://dart.dev/libraries/async/using-streams#two-kinds-of-streams · https://dart.dev/libraries/async/creating-streams#using-a-streamcontroller · https://dart.dev/libraries/async/creating-streams#honoring-the-pause-state · https://dart.dev/language/async#handling-streams · https://dart.dev/language/functions#generators · Min. sürüm: Dart 3.0

`Future` tek sonuçtur, `Stream` zaman içinde gelen olayların dizisidir; Data katmanı kaynağı (socket, sensör) açar, State katmanı `listen` edip `dispose`'da bırakır, UI sonucu gösterir.

## 1. Single-subscription ve broadcast (2.x)
**Ne:** Varsayılan stream tek dinleyici kabul eder; `StreamController.broadcast()` çok dinleyici kabul eder ve dinleyicisiz olayları düşürür.
**Ne zaman:** Sıralı, eksiksiz veri (dosya, geçmiş) için single; UI olayları ve durum değişimi için broadcast. **Gerekmez:** Tek değer için `Future` yeter.
<!-- snippet: 07_streams/stream_kinds -->
```dart
import 'dart:async';

final class OrderStatusFeed {
  final _controller = StreamController<String>.broadcast();

  // Broadcast: many listeners, events nobody hears are dropped.
  Stream<String> get statusChanges => _controller.stream;

  void publish(String status) => _controller.add(status);

  Future<void> close() => _controller.close();
}

// Single-subscription (the default): one listener for the stream's whole life.
Stream<String> orderHistory(List<String> statuses) async* {
  for (final status in statuses) {
    yield status;
  }
}

// A single-subscription stream becomes shareable with asBroadcastStream.
Stream<String> shareable(Stream<String> source) => source.asBroadcastStream();
```
**Tuzak:** Single-subscription'a ikinci `listen` `StateError` atar, ilk abonelik cancel edilse bile (test kanıtlıyor).
**Skill'e ver:** > "Kargo takibinde konum güncellemelerini birden çok ekrana dağıtan bir `ShipmentLocationFeed` yaz; kimse dinlemezken gelen konum düşsün."
**Kabul:** `isBroadcast` true; iki dinleyici aynı olayı aldı; dinleyicisiz olay kayboldu.

## 2. `async*` generator (2.x)
**Ne:** `async*` + `yield` ile tembel stream üretir; dinleyici durunca `finally` çalışır ve sonraki sayfa istenmez.
**Ne zaman:** Olaylar başka kaynaktan (sayfa, stream) türetiliyorsa. **Gerekmez:** Olaylar kodun farklı yerlerinden geliyorsa `StreamController`. `sync*` aynı fikrin senkron hali: `Iterable` döner, stream değildir.
<!-- snippet: 07_streams/async_generator -->
```dart
/// Pages are fetched lazily; an early stop (`take`, `cancel`) asks for no more.
Stream<int> orderIds(
  Future<List<int>> Function(int page) fetchPage, {
  required void Function() onReleased,
}) async* {
  try {
    for (var page = 0; ; page++) {
      final ids = await fetchPage(page);
      if (ids.isEmpty) return;
      yield* Stream.fromIterable(ids);
    }
  } finally {
    onReleased();
  }
}
```
**Tuzak:** `take(3)` gibi erken durma sonraki sayfayı çağırmaz ve `finally` bir kez çalışır (test kanıtlıyor).
**Skill'e ver:** > "Ürün kataloğunu sayfa sayfa çeken `Stream<Product> products(fetchPage)` yaz; boş sayfada bitsin, erken iptalde temizlik callback'i çalışsın."
**Kabul:** Sayfalar sırayla geldi; `take(n)` sonrası fazladan sayfa istenmedi; `onReleased` bir kez çağrıldı.

## 3. StreamController callback'leri (2.x)
**Ne:** `onListen`, `onPause`, `onResume`, `onCancel` ile kaynak yalnız birisi dinlerken çalışır.
**Ne zaman:** Zamanlayıcı, bağlantı, sensör gibi pahalı kaynak. **Gerekmez:** Kaynak zaten stream ise `async*` veya `map` yeter.
<!-- snippet: 07_streams/controller_callbacks -->
```dart
import 'dart:async';

/// Tracking starts on listen, stops on pause/cancel, resumes on resume.
Stream<int> courierPositions({required void Function(String event) log}) {
  late final StreamController<int> controller;
  Timer? timer;
  var position = 0;

  void start(String event) {
    log(event);
    timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => controller.add(++position),
    );
  }

  void stop(String event) {
    log(event);
    timer?.cancel();
  }

  controller = StreamController<int>(
    onListen: () => start('onListen'),
    onPause: () => stop('onPause'),
    onResume: () => start('onResume'),
    onCancel: () => stop('onCancel'),
  );
  return controller.stream;
}
```
**Tuzak:** Dinleyici gelene kadar `onListen` çalışmaz; kaynak kapalı kalır (test kanıtlıyor).
**Skill'e ver:** > "Her saniye pil yüzdesi yayan bir `Stream<int> batteryLevels` yaz; dinleyici gelince ölçüm başlasın, pause ve cancel'da dursun."
**Kabul:** Log sırası `onListen`, `onPause`, `onResume`, `onCancel`; cancel sonrası yeni olay gelmedi.

## 4. `StreamTransformer` (2.x)
**Ne:** `transform()` ile stream'i yeniden biçimlendirir; `fromHandlers` olay başına sink'e 0..n çıktı yazar.
**Ne zaman:** Olayı süzüp dönüştürmek gerekiyorsa. **Gerekmez:** Olay başına tek çıktı için `map()`.
<!-- snippet: 07_streams/message_transformer -->
```dart
import 'dart:async';

/// Trims each chat message and drops the empty ones.
final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed);
  },
);
```
**Tuzak:** Sink'e eklemediğin olay sessizce düşer; kırpılan boş mesaj çıktıda yoktur (test kanıtlıyor).
**Skill'e ver:** > "Sipariş notlarını küçük harfe çevirip 3 karakterden kısa olanları atan bir `StreamTransformer<String, String>` yaz."
**Kabul:** `transform` sonrası beklenen olaylar sırayla geldi, kısa not düştü.

## 5. Dinleyen state sınıfı ve dispose (2.x)
**Ne:** Subscription alanda tutulur, `dispose()`'da `await cancel()` ve `null` yapılır; düz Dart, kütüphane yok.
**Ne zaman:** Bir state sınıfı stream'i ömrü boyunca dinliyorsa. **Gerekmez:** Tek seferlik okuma için `await for` / `first`.
<!-- snippet: 07_streams/price_watcher -->
```dart
import 'dart:async';

final class PriceWatcher {
  PriceWatcher(this._prices);
  final Stream<double> _prices;

  StreamSubscription<double>? _subscription;
  double? latestPrice;

  void start() {
    _subscription ??= _prices.listen((price) => latestPrice = price);
  }

  /// Awaiting `cancel()` waits until the source has finished its cleanup.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
```
**Tuzak:** `dispose` sonrası gelen olay state'i değiştirmez; `start` iki kez çağrılsa tek abonelik olur (`??=`) (test kanıtlıyor).
**Skill'e ver:** > "Profil çevrimiçi durumunu dinleyen `PresenceWatcher` state sınıfı yaz; `start`, `dispose` ve son durumu tutsun."
**Kabul:** `dispose` sonrası kaynağın `onCancel`'ı çalıştı; geç gelen olay değeri değiştirmedi.

## Flutter'da kanıt
- `StreamBuilder` state'inde subscription alan olarak tutulur, `dispose()`'da `cancel()`: [widgets/async.dart#L100](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L100)
- `EventChannel.receiveBroadcastStream` `StreamController.broadcast(onListen, onCancel)` kullanır: [services/platform_channel.dart#L696](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/platform_channel.dart#L696)
- `MultiFrameImageStreamCompleter` dispose'da `cancel()` + `null`: [painting/image_stream.dart#L1037](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_stream.dart#L1037)
- `LicenseRegistry.licenses` pahalı işi `onListen`'e kadar başlatmaz: [foundation/licenses.dart#L319](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/licenses.dart#L319)

## Kontrol listesi
- [ ] Tek değer için `Future`, çok değer için `Stream` seçildi.
- [ ] Çok dinleyici gerekiyorsa broadcast, sıralı veri için single-subscription.
- [ ] Sonsuz stream'de `await for` yerine `listen` ve saklanan subscription.
- [ ] Pahalı kaynak `onListen`'de açılıyor, `onCancel`'da kapanıyor.
- [ ] Her `listen` için `dispose`'da `await cancel()` var.
- [ ] Controller işi bitince `close()` edildi.

## Pekiştirme
- **Kolay:** `Stream<int> countdown(int from)` `async*` ile yaz; `take(2)` sonrası `finally` çalışsın. Bitti: test `finally`'nin bir kez çalıştığını gösterir.
- **Zor:** `ChatWatcher` yaz: mesajları `trim`leyen transformer'ı kullanıp dinlesin, `pause`/`resume` ve `dispose` desteklesin. Bitti: dispose sonrası kaynağın `onCancel`'ı çalışır ve yeni mesaj listeyi değiştirmez.

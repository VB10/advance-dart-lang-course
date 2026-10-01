# 07 · Streams
> Kaynak: https://dart.dev/libraries/async/using-streams#two-kinds-of-streams · https://dart.dev/libraries/async/creating-streams#using-a-streamcontroller · https://dart.dev/libraries/async/creating-streams#honoring-the-pause-state · https://dart.dev/language/async#handling-streams · https://dart.dev/language/functions#generators · Min. sürüm: Dart 3.0
Neden bu konu: Flutter'da sızan `listen`, ikinci dinleyicide `StateError` ve dinlenmeden açılan kaynak en sık görülen stream hatalarıdır; bu beş desen hepsini kapatır.

`Future` tek sonuçtur, `Stream` zaman içinde gelen olayların dizisidir; Data katmanı kaynağı (socket, sensör) açar, State katmanı `listen` edip `dispose`'da bırakır, UI sonucu gösterir.

## 1. Single-subscription ve broadcast (2.x)
**Ne:** Varsayılan stream tek dinleyici kabul eder; `StreamController.broadcast()` çok dinleyici kabul eder ve dinleyicisiz olayları düşürür.
**Ne zaman:** Sıralı, eksiksiz veri (dosya, geçmiş) için single; UI olayları ve durum değişimi için broadcast. **Gerekmez:** Tek değer için `Future` yeter.
<!-- snippet: 07_streams/stream_kinds -->
```dart
// Düzelt: /dartadvance Projemde aynı stream'i birden çok yerde dinleyen yerleri bul,
//    single-subscription/broadcast ayrımıyla düzelt, test yaz.
// Üret: /dartadvance Bana stok değişimlerini hem ekrana hem log'a aynı anda ileten
//    bir sınıf yaz.
import 'dart:async';

Stream<String> orderHistory(List<String> statuses) async* {
  for (final status in statuses) {
    yield status;
  }
} // single-subscription: a 2nd listen throws StateError

Stream<String> shareable(Stream<String> source) => source.asBroadcastStream(); // 2 listeners: ok

final class OrderStatusFeed {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get statusChanges => _controller.stream;

  void publish(String status) => _controller.add(status); // no listener: event dropped

  Future<void> close() => _controller.close();
}
```
**Tuzak:** Single-subscription'a ikinci `listen` `StateError` atar, ilk abonelik cancel edilse bile (test kanıtlıyor).
**Düzelt (mevcut proje):** > "/dartadvance Projemde aynı stream'i birden çok yerde dinleyen yerleri bul, single-subscription/broadcast ayrımıyla düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana stok değişimlerini hem ekrana hem log'a aynı anda ileten bir sınıf yaz."
**Kabul:** Çoklu dinlenen akış `isBroadcast`; iki dinleyici aynı olayı aldı; ikinci `listen` `StateError` atmıyor; mevcut testler ve `dart analyze` yeşil.

## 2. `async*` generator (2.x)
**Ne:** `async*` + `yield` ile tembel stream üretir; dinleyici durunca `finally` çalışır ve sonraki sayfa istenmez.
**Ne zaman:** Olaylar başka kaynaktan (sayfa, stream) türetiliyorsa. **Gerekmez:** Olaylar kodun farklı yerlerinden geliyorsa `StreamController`. `sync*` aynı fikrin senkron hali: `Iterable` döner, stream değildir.
<!-- snippet: 07_streams/async_generator -->
```dart
// Düzelt: /dartadvance Projemde sayfaları hepsini çekip listeye dönen yerleri bul,
//    `async*` ile tembel Stream'e çevir, erken iptali de kapsayan test yaz.
// Üret: /dartadvance Bana sayfa sayfa gelen ürün yorumlarını akıtan, ilk 5'te bırakılınca
//    bağlantıyı kapatan bir fonksiyon yaz.

Future<List<int>> naiveOrderIds(Future<List<int>> Function(int page) fetchPage) async {
  final all = <int>[];
  for (var page = 0; ; page++) {
    final ids = await fetchPage(page);
    if (ids.isEmpty) return all;
    all.addAll(ids); // eager: caller wants 3 ids, every page is still fetched
  }
}

Stream<int> orderIds(
  Future<List<int>> Function(int page) fetchPage, {
  required void Function() onReleased,
}) async* {
  try {
    for (var page = 0; ; page++) {
      final ids = await fetchPage(page);
      if (ids.isEmpty) return;
      yield* Stream.fromIterable(ids); // take(3) over 2-id pages: only pages 0, 1 fetched
    }
  } finally {
    onReleased(); // runs once, even on early stop
  }
}
```
**Tuzak:** `take(3)` gibi erken durma sonraki sayfayı çağırmaz ve `finally` bir kez çalışır (test kanıtlıyor).
**Düzelt (mevcut proje):** > "/dartadvance Projemde sayfaları hepsini çekip listeye dönen yerleri bul, `async*` ile tembel Stream'e çevir, erken iptali de kapsayan test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sayfa sayfa gelen ürün yorumlarını akıtan, ilk 5'te bırakılınca bağlantıyı kapatan bir fonksiyon yaz."
**Kabul:** Dönüştürülen her yerde sayfalar sırayla geldi; `take(n)` sonrası fazladan sayfa istenmedi; temizlik bir kez çalıştı; analyze temiz.

## 3. StreamController callback'leri (2.x)
**Ne:** `onListen`, `onPause`, `onResume`, `onCancel` ile kaynak yalnız birisi dinlerken çalışır.
**Ne zaman:** Zamanlayıcı, bağlantı, sensör gibi pahalı kaynak. **Gerekmez:** Kaynak zaten stream ise `async*` veya `map` yeter.
<!-- snippet: 07_streams/controller_callbacks -->
```dart
// Düzelt: /dartadvance Projemde Timer, soket veya sensörü dinlenmeden başlatan yerleri
//    bul, `StreamController` onListen/onCancel ile düzelt, test yaz.
// Üret: /dartadvance Bana sıcaklık sensörünü yalnız biri dinlerken okuyan, dinleyen
//    kalmayınca durduran bir akış yaz.
import 'dart:async';

Stream<int> naiveCourierPositions({required void Function(String event) log}) {
  final controller = StreamController<int>();
  Timer.periodic(const Duration(milliseconds: 10), (_) {
    log('read'); // no listener yet: the sensor is read anyway
    controller.add(1);
  }); // never cancelled: keeps reading after the last listener leaves
  return controller.stream;
}

Stream<int> courierPositions({required void Function(String event) log}) {
  late final StreamController<int> controller;
  Timer? timer;
  var position = 0;

  void start(String event) {
    log(event); // nobody listening: log stays empty, no timer
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) => controller.add(++position));
  }

  void stop(String event) {
    log(event); // pause and cancel both stop the source
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
**Tuzak:** `onListen`/`onCancel` olmadan Timer dinleyicisiz de okur ve iptal sonrası sürer; callback'li akışta kaynak kapalı kalır (test kanıtlıyor).
**Düzelt (mevcut proje):** > "/dartadvance Projemde Timer, soket veya sensörü dinlenmeden başlatan yerleri bul, `StreamController` onListen/onCancel ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sıcaklık sensörünü yalnız biri dinlerken okuyan, dinleyen kalmayınca durduran bir akış yaz."
**Kabul:** Dinleyici yokken kaynak okunmadı (sayaç/log boş); ilk `listen` sonrası kaynak başladı; `cancel` sonrası `onCancel` çalıştı ve sayaç artmayı bıraktı; testler ve `dart analyze` yeşil.

## 4. `StreamTransformer` (2.x)
**Ne:** `transform()` ile stream'i yeniden biçimlendirir; `fromHandlers` olay başına sink'e 0..n çıktı yazar.
**Ne zaman:** Olayı süzüp dönüştürmek gerekiyorsa. **Gerekmez:** Olay başına tek çıktı için `map()`.
<!-- snippet: 07_streams/message_transformer -->
```dart
// Düzelt: /dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul,
//    `StreamTransformer.fromHandlers` ile dönüştür, test yaz.
// Üret: /dartadvance Bana fatura satırı metinlerini kırpıp boşları atan, kalanları büyük
//    harfe çeviren bir stream dönüştürücü yaz.
import 'dart:async';

Future<List<String>> naiveTrim(Stream<String> source) async {
  final result = <String>[];
  await for (final message in source) {
    if (message.trim().isNotEmpty) result.add(message.trim());
  }
  return result; // open stream: completes only when the source closes
}

final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed); // ['  hi ', '   ', 'yo'] -> ['hi', 'yo']
  },
);
```
**Tuzak:** Sink'e eklemediğin olay sessizce düşer; kırpılan boş mesaj çıktıda yoktur (test kanıtlıyor).
**Düzelt (mevcut proje):** > "/dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul, `StreamTransformer.fromHandlers` ile dönüştür, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana fatura satırı metinlerini kırpıp boşları atan, kalanları büyük harfe çeviren bir stream dönüştürücü yaz."
**Kabul:** Dönüşen her akışta davranış aynı: beklenen olaylar sırayla geldi, süzülenler düştü; testler yeşil.

## 5. Dinleyen state sınıfı ve dispose (2.x)
**Ne:** Subscription alanda tutulur, `dispose()`'da `await cancel()` ve `null` yapılır; düz Dart, kütüphane yok.
**Ne zaman:** Bir state sınıfı stream'i ömrü boyunca dinliyorsa. **Gerekmez:** Tek seferlik okuma için `await for` / `first`.
<!-- snippet: 07_streams/price_watcher -->
```dart
// Düzelt: /dartadvance Projemde stream dinleyip dispose'da cancel etmeyen state'leri bul,
//    subscription'ı alanda tutup `await cancel()` ile düzelt, test yaz.
// Üret: /dartadvance Bana çalma listesindeki şarkı değişimlerini dinleyip son şarkıyı
//    tutan, kapatılınca dinlemeyi bırakan bir sınıf yaz.
import 'dart:async';

final class LeakyPriceWatcher {
  LeakyPriceWatcher(this._prices);
  final Stream<double> _prices;

  double? latestPrice;

  void start() => _prices.listen((price) => latestPrice = price); // start twice: two listeners

  void dispose() {} // nothing cancelled: events still change state after dispose
}

final class PriceWatcher {
  PriceWatcher(this._prices);
  final Stream<double> _prices;

  StreamSubscription<double>? _subscription;
  double? latestPrice;

  void start() {
    _subscription ??= _prices.listen((price) => latestPrice = price); // start twice: one listener
  }

  Future<void> dispose() async {
    await _subscription?.cancel(); // after this, source onCancel ran
    _subscription = null;
  }
}
```
**Tuzak:** `dispose` sonrası gelen olay state'i değiştirmez; `start` iki kez çağrılsa tek abonelik olur (`??=`) (test kanıtlıyor).
**Düzelt (mevcut proje):** > "/dartadvance Projemde stream dinleyip dispose'da cancel etmeyen state'leri bul, subscription'ı alanda tutup `await cancel()` ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana çalma listesindeki şarkı değişimlerini dinleyip son şarkıyı tutan, kapatılınca dinlemeyi bırakan bir sınıf yaz."
**Kabul:** Bulunan her state sınıfında `dispose` sonrası kaynağın `onCancel`'ı çalıştı; geç gelen olay state'i değiştirmedi; kaynak birden çok dinleyiciye gidiyorsa ayrıca `isBroadcast` ve iki dinleyici testi var.

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

# 09 · Isolates
> Kaynak: https://dart.dev/language/concurrency#isolates · https://dart.dev/language/isolates · https://dart.dev/language/isolates#robust-ports-example · https://dart.dev/language/concurrency#isolates-arent-threads · https://dart.dev/language/concurrency#message-types · Min. sürüm: Dart 2.19 (`Isolate.run`), 3.0 (record kullanan worker)
Neden bu konu: Flutter'da JSON/parse işi frame kaçırtır; `compute` ve `Isolate.run` closure'ın ne yakaladığına bakmadan yazılınca sessizce yavaşlar ya da patlar.

Isolate, ana isolate'i bloklayan ağır CPU işini ayrı bir belleğe taşır; Data katmanında (RepositoryImpl/parser/servis) yaşar, Domain ve UI isolate bilmez. Isolate thread değildir: paylaşılan durum yok, tek yol mesajdır. Web'de `dart:isolate` yoktur; Flutter `compute` native'de `Isolate.run` ile aynıdır, web'de aynı event loop'ta çalışır (paralellik yok). Bu kural dosyası Dart VM hedefi içindir.

## 1. Eşikli ağır parse: `Isolate.run` (2.19)
**Ne:** Büyük gövde `Isolate.run` ile çözülür, küçük gövde inline kalır. **Ne zaman:** frame kaçıracak senkron CPU işi (büyük JSON, sıkıştırma, büyük liste filtresi). **Gerekmez:** I/O beklemek (düz `await` yeter) ve küçük payload; Flutter `loadString` de 50 KB altını inline çözer.
<!-- snippet: 09_isolates/decode_orders -->
```dart
// Düzelt: /dartadvance Projemde ana isolate'te büyük JSON/CSV/GPX çözen yerleri bul,
//    eşikli `Isolate.run` ile taşı, her biri için test yaz.
// Üret: /dartadvance Bana 3 MB'lık ürün kataloğu JSON'unu Product listesine çeviren bir
//    fonksiyon yaz.
import 'dart:convert';
import 'dart:isolate';

final class Order {
  const Order({required this.id, required this.total});
  final int id;
  final double total;
}

// Naive: pays an isolate spawn even for a 2-row body (same result, wasted cost).
Future<List<Order>> naiveDecodeOrders(String body) => Isolate.run(() => parseOrders(body));

/// Small bodies parse inline; the closure captures only `body`.
Future<List<Order>> decodeOrders(String body, {int isolateThreshold = 50 * 1024}) async {
  if (body.length < isolateThreshold) return parseOrders(body);
  return Isolate.run(() => parseOrders(body), debugName: 'parseOrders');
}

/// Pure and top-level: safe to run on any isolate.
List<Order> parseOrders(String body) {
  final rows = jsonDecode(body) as List<Object?>;
  return [
    for (final row in rows.cast<Map<String, Object?>>())
      Order(id: row['id']! as int, total: (row['total']! as num).toDouble()),
  ];
}
```
**Tuzak:** `Isolate.run` içinde fırlayan hata aynı tipte ana isolate'e gelir (`FormatException` testte tipiyle yakalanır); `Result`'a çevirmeyi RepositoryImpl yapar. Parse fonksiyonu top-level ve saf olmalı. Dosyada `naiveDecodeOrders` (her çağrıda isolate açar) eşikli `decodeOrders` ile yan yana durur.
**Düzelt (mevcut proje):** > "/dartadvance Projemde ana isolate'te büyük JSON/CSV/GPX çözen yerleri bul, eşikli `Isolate.run` ile taşı, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana 3 MB'lık ürün kataloğu JSON'unu Product listesine çeviren bir fonksiyon yaz."
**Kabul:** Her bulunan yerde eşik 1 ve büyük eşik aynı sonucu verir; bozuk girdide `FormatException` tipiyle fırlar; parse fonksiyonu top-level ve saf; `dart analyze` temiz.

## 2. Ne gönderilir, closure ne yakalar (2.19)
**Ne:** Mesajlar kopyalanır, global değişken isolate'te ayrı kopyadır, bazı nesneler hiç gönderilemez. **Ne zaman:** `Isolate.run`/`Isolate.spawn` closure'ı yazarken. **Gerekmez:** paylaşılan mutable durum bekleme; isolate bunu veremez, sonucu mesaj olarak döndür.
<!-- snippet: 09_isolates/capture_rules -->
```dart
// Düzelt: /dartadvance Projemde `Isolate.run`/`compute` closure'larını bul,
//    ne yakaladıklarını ve global durumu kurallarıyla düzelt, her biri için test yaz.
// Üret: /dartadvance Bana fatura listesini arka planda sıralayıp KDV toplamını hesaplayan
//    bir fonksiyon yaz.
import 'dart:isolate';

int loadedOrderCount = 0;

// The list is copied into the isolate: the caller's list stays unsorted.
Future<List<int>> sortedTotals(List<int> totals) => Isolate.run(() => totals..sort());

// A global is a separate variable in the new isolate.
Future<int> countInIsolate() => Isolate.run(() => ++loadedOrderCount); // 1, main stays 0

Future<int> captureReceivePort() async {
  final port = ReceivePort();
  try {
    return await Isolate.run(() => port.hashCode); // ArgumentError: unsendable
  } finally {
    port.close();
  }
}
```
**Tuzak:** `ReceivePort`, `Socket`, `Pointer`, `Finalizer` gibi nesneyi yakalayan closure `ArgumentError` ile patlar (testli). API dokümanı (dartbug 36983): closure gerekenden fazla durum yakalayabilir; instance metodu içinde closure yazmak `this`'i taşıyabilir. Çözüm: gereken durumu parametre alan ayrı bir fonksiyonda closure kur (testi yok, API notudur).
**Düzelt (mevcut proje):** > "/dartadvance Projemde `Isolate.run`/`compute` closure'larını bul, ne yakaladıklarını ve global durumu kurallarıyla düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana fatura listesini arka planda sıralayıp KDV toplamını hesaplayan bir fonksiyon yaz."
**Kabul:** Her closure yalnızca gereken parametreyi yakalar; çağıranın verisi değişmez (testli); global mutable duruma bağımlılık kalmaz; `ReceivePort`/`Socket` yakalayan closure yok.

## 3. Sağlam worker: ports, hata ve çıkış (3.0)
**Ne:** Tekrar eden işi, `onExit` ve ports ile kurulan uzun ömürlü bir isolate'e verir. **Ne zaman:** aynı hesap sürekli tekrarlanıyor (her mesajı parse eden akış). **Gerekmez:** tek seferlik iş; `Isolate.run` yeter, her seferinde spawn maliyeti kabul edilir.
<!-- snippet: 09_isolates/price_worker -->
```dart
// Düzelt: /dartadvance Projemde her mesaj/satır için sürekli isolate açan yerleri bul,
//    ports ve `onExit` ile uzun ömürlü worker'a çevir, her biri için test yaz.
// Üret: /dartadvance Bana sipariş satırları art arda geldikçe indirim hesaplayan, açık
//    kalan bir arka plan hesaplayıcısı yaz.
import 'dart:isolate';

final class PriceWorker {
  PriceWorker._(this._commands, this.exited);
  final SendPort _commands;
  final Future<void> exited;
  static Future<PriceWorker> spawn() async {
    final ready = ReceivePort();
    final exitPort = ReceivePort();
    await Isolate.spawn(_serve, ready.sendPort, onExit: exitPort.sendPort);
    return PriceWorker._(await ready.first as SendPort, exitPort.first);
  }

  Future<int> withTax(int cents) async {
    final reply = ReceivePort();
    _commands.send((cents, reply.sendPort));
    // A dead worker never replies, so the exit signal must win the race.
    final died = exited.then((_) => StateError('Worker exited'));
    final result = await Future.any<Object?>([reply.first, died]);
    reply.close();
    return result is Error ? throw result : result! as int;
  }

  // Naive: no exit race, no error check. Dead worker: never completes; RemoteError: TypeError.
  Future<int> naiveWithTax(int cents) async {
    final reply = ReceivePort();
    _commands.send((cents, reply.sendPort));
    return await reply.first as int;
  }

  void close() => _commands.send(null);
}

void _serve(SendPort ready) {
  final commands = ReceivePort();
  ready.send(commands.sendPort);
  commands.listen((Object? message) {
    if (message == null) return commands.close(); // last port closed: isolate exits
    final (int cents, SendPort replyTo) = message as (int, SendPort);
    replyTo.send(cents < 0 ? RemoteError('Negative price', '') : cents * 120 ~/ 100);
  });
}
```
**Tuzak:** Ölü worker asla yanıt vermez; isteği `exited` ile yarıştırmazsan çağıran sonsuza kadar bekler. Worker'daki hata `RemoteError` değeri olarak döner; `close()` sonrası istek `StateError` verir (üçü de testli). Dosyada `naiveWithTax` yan yana: ölü worker'da takılır, `RemoteError`'u `TypeError`'a çevirir (testli).
**Düzelt (mevcut proje):** > "/dartadvance Projemde her mesaj/satır için sürekli isolate açan yerleri bul, ports ve `onExit` ile uzun ömürlü worker'a çevir, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş satırları art arda geldikçe indirim hesaplayan, açık kalan bir arka plan hesaplayıcısı yaz."
**Kabul:** Her dönüştürülen yerde sıralı ve eşzamanlı istekler doğru cevaplanır; hata `RemoteError` gelir; `close()` sonrası `exited` tamamlanır ve yeni istek `StateError` verir.

## Flutter'da kanıt
- `compute` native'de `Isolate.run` çağırır: [`_isolates_io.dart#L22`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/_isolates_io.dart#L22); web'de `await null; return callback(message);`: [`_isolates_web.dart#L11`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/_isolates_web.dart#L11).
- Eşik deseni: `data.lengthInBytes < 50 * 1024 || kIsWeb` ise inline: [`asset_bundle.dart#L95`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/asset_bundle.dart#L95); büyükse `compute(_utf8decode, ...)`: [`asset_bundle.dart#L100`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/asset_bundle.dart#L100).
- Ağır parse → entity listesi: `compute<String, List<LicenseEntry>>(_parseLicenses, ...)`: [`binding.dart#L219`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/binding.dart#L219).
- id → `Completer` eşlemesi (robust ports fikri): [`_background_isolate_binary_messenger_io.dart#L18`](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/_background_isolate_binary_messenger_io.dart#L18).

## Kontrol listesi
- [ ] İş gerçekten CPU-bound mu? I/O ise düz `await`.
- [ ] Küçük payload için isolate açılmıyor (eşik parametre).
- [ ] Isolate'e giden fonksiyon top-level/static ve saf; closure yalnızca gereken durumu yakalıyor.
- [ ] `ReceivePort`/`Socket`/`Pointer` gibi gönderilemeyen nesne yakalanmıyor.
- [ ] Isolate hatası RepositoryImpl'de `Err(Failure)`'a çevriliyor; UseCase isolate bilmiyor.
- [ ] Worker'da `onExit` izleniyor, istekler ölü worker'a karşı korunuyor, `close()` portu kapatıyor.

## Pekiştirme
- **Kolay:** `Future<int> sumInIsolate(List<int> numbers)` yaz; "bitti" = doğru toplam döner ve boş listede isolate içinde fırlatılan `ArgumentError` çağıranda aynı tipte yakalanır.
- **Zor:** Sayfalı bir ürün listesini CSV'den çözen `ProductRepositoryImpl` yaz (Data'da isolate, Domain'de `Future<Result<...>>`); "bitti" = büyük CSV isolate'te çözülür, bozuk satır `Err` döner ve closure repository'yi yakalamaz.

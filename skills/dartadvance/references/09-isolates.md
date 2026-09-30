# 09 · Isolates ve compute

> Kaynak: https://dart.dev/language/concurrency#isolates ·
> https://dart.dev/language/isolates ·
> API: [`Isolate.run`](https://api.dart.dev/dart-isolate/Isolate/run.html),
> [`Isolate.spawn`](https://api.dart.dev/dart-isolate/Isolate/spawn.html),
> [`SendPort.send`](https://api.dart.dev/dart-isolate/SendPort/send.html),
> [`RawReceivePort`](https://api.dart.dev/dart-isolate/RawReceivePort-class.html) ·
> Flutter: [`compute`](https://api.flutter.dev/flutter/foundation/compute.html)
> Min. dil sürümü: `Isolate.run` **Dart 2.19** (`@Since("2.19")`); `Isolate.spawn`, ports her sürümde.
> Robust ports örneği record kullanır → 3.0. **Web'de isolate yok** (aşağıya bak).

Isolate **thread değildir**: her isolate'in kendi belleği ve kendi event loop'u
vardır, aralarında **paylaşılan durum yoktur**; tek iletişim yolu mesajdır
(`SendPort` → `ReceivePort`). Bütün kararlar bu cümleden çıkar.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| Frame kaçıracak kadar uzun **senkron CPU işi**: büyük JSON parse, sıkıştırma, görüntü/ses işleme, büyük listede arama/filtre ([dart.dev](https://dart.dev/language/concurrency#background-workers)) | **I/O-bound iş** (HTTP, dosya okuma, DB çağrısı bekleme): düz `await` yeter; bekleme sırasında event loop zaten serbesttir (bkz. [06](06-event-loop-future.md)) |
| Tek seferlik hesap → **`Isolate.run`** (dart.dev: "In most cases, `Isolate.run` is the recommended API") | Küçük payload: isolate başlatma + mesaj maliyeti kazançtan büyük. Flutter `loadString` bile < 50 KB'ı inline çözer |
| Aynı hesabı **tekrar tekrar** yapıyorsan → long-lived worker (`Isolate.spawn` + ports) | Web hedefi: `dart:isolate` desteklenmez; Flutter `compute` web'de aynı event loop'ta çalışır — kazanç yok |
| Flutter uygulamasında → `compute(fn, message)` (native'de `Isolate.run` ile aynı) | Paylaşılan mutable durum gerekiyorsa → isolate bunu **veremez**; tasarımı mesaj/sonuç olarak değiştir |

Not: dart.dev isolates sayfası "Performing I/O, such as communicating with a
database" durumunu da olası kullanımlar arasında sayar — bu, I/O'nun kendisinin
isolate gerektirdiği anlamına gelmez; worker'ın I/O **yapabildiğini** söyler.
Kural: ana isolate'i **bloklayan** iş isolate'e gider, **bekleyen** iş gitmez.

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Data / DataSource | Ham gövdeyi getirir (`Future<String>`); I/O olduğu için isolate'siz |
| Data / RepositoryImpl veya parser | Büyük gövdeyi `Isolate.run(() => parseX(body))` ile çözer + entity'ye map'ler; hata → `Err(Failure)` |
| Data / uzun ömürlü servis | Sürekli gelen iş (ör. her mesajı parse eden WebSocket akışı) için tek bir worker isolate, `close()` ile kapatılır |
| Domain / UseCase | **Isolate bilmez**; `Future<Result<T>>` döner. Isolate bir implementasyon detayıdır |
| Presentation | Doğrudan isolate açmaz; Flutter'da gerekirse `compute` kullanılan yer yine Data katmanıdır |

İsolate'e giden fonksiyon **top-level veya static**, **saf** ve **senkron CPU işi**
olmalı; exception'lar isolate sınırını tipiyle geçer, `Result`'a çevirme işini
RepositoryImpl ana isolate'te yapar.

## Doğrulanmış örnekler

Tüm kod `examples/lib/09_isolates/` altında, testleri `examples/test/09_isolates/`
altında (`dart run dartadvance_tool:dartadvance verify 09_isolates`); her kavram ayrı dosyada
(dosya adı = snippet id). Testler
Dart VM'de gerçek isolate açar.

### Resmi örnekler (dart.dev)

[`Isolate.run()`](https://dart.dev/language/concurrency#isolate-run): tek argüman,
yeni isolate'te çalışacak callback. Sonuç her zaman `Future`'dır; hesap mevcut isolate'i
bloklamaz (dart.dev kodundaki satır içi yorum çıkarıldı).

<!-- snippet: 09_isolates/isolate_run -->
```dart
import 'dart:isolate';

int slowFib(int n) => n <= 1 ? 1 : slowFib(n - 1) + slowFib(n - 2);

Future<int> fib(int n) => Isolate.run(() => slowFib(n));
```

`Isolate.run` şu adımları soyutlar ([dart.dev](https://dart.dev/language/isolates#implementing-a-simple-worker-isolate)):
isolate'i başlatır, fonksiyonu çalıştırır, sonucu yakalar, ana isolate'e döner,
isolate'i kapatır, **hata ve exception'ları yakalayıp ana isolate'te yeniden fırlatır**.
Sonuç `Isolate.exit` ile gönderilir → **kopyalanmaz, transfer edilir**.

API dokümanına göre computation fırlatırsa isolate sonlanır ve `Isolate.run`
**aynı hatayı** fırlatır (test: `StateError` tipiyle gelir). Yakalanmamış
**asenkron** hatalar ise `RemoteError` olarak gelir.

<!-- snippet: 09_isolates/isolate_run_error -->
```dart
import 'dart:isolate';

Future<int> failInIsolate() => Isolate.run<int>(() => throw StateError('In a bad state!'));
```

### Paylaşılan bellek yok

dart.dev ([Isolates aren't threads](https://dart.dev/language/concurrency#isolates-arent-threads)):
global mutable değişken spawn edilen isolate'te **ayrı bir değişkendir**; orada
değiştirmek ana isolate'i etkilemez. Test: iki çağrı da `1` döner, ana isolate'te
`requestCount` `0` kalır.

<!-- snippet: 09_isolates/no_shared_memory -->
```dart
import 'dart:isolate';

int requestCount = 0;

Future<int> incrementInIsolate() => Isolate.run(() => ++requestCount);
```

### Neler gönderilebilir, closure'lar

[Message types](https://dart.dev/language/concurrency#message-types) ve
`SendPort.send` API dokümanı: aynı kodu paylaşan isolate'ler arasında (`Isolate.spawn`,
`Isolate.run`) **neredeyse her nesne** gönderilebilir. İstisnalar: native kaynak
taşıyan nesneler (ör. `Socket`), `ReceivePort`, `DynamicLibrary`, `Finalizable`,
`Finalizer`, `NativeFinalizer`, `Pointer`, `UserTag`, `MirrorReference` ve
`@pragma('vm:isolate-unsendable')` ile işaretli sınıfların örnekleri. Immutable
nesneler (ör. `String`) paylaşılır, diğerleri **kopyalanır** (graf boyutunda lineer maliyet).
`Isolate.spawnUri` ile açılan (kodu paylaşmayan) isolate'e yalnızca primitifler,
literal/`List`/`Map`/`Set`, `TransferableTypedData`, `Capability`, `SendPort` gidebilir.

**Closure uyarısı** (API dokümanı, [dartbug 36983](http://dartbug.com/36983)): VM
closure'ların yakaladığı durumu temsil etme biçimi nedeniyle closure **gerekenden
fazla durum** yakalayabilir → performans/bellek maliyeti ya da gönderilemeyen bir
nesne yakalandıysa **çalışma zamanı hatası**. API'nin önerisi: gereken durumu
**parametre olarak alan ayrı bir fonksiyon** yaz, closure'ı onun içinde oluştur.

Gönderilemeyen nesne yakalamak (test: `ArgumentError` —
"Illegal argument in isolate message: object is unsendable"):

<!-- snippet: 09_isolates/unsendable_capture -->
```dart
import 'dart:isolate';

Future<int> captureUnsendable() async {
  final port = ReceivePort();
  try {
    // The closure captures a ReceivePort, which cannot be sent: this fails.
    return await Isolate.run(() => port.hashCode);
  } finally {
    port.close();
  }
}
```

### Data: ağır parse → `Result`

Saf, senkron, top-level parse fonksiyonu. `FormatException` isolate sınırını
tipiyle geçer:

<!-- snippet: 09_isolates/parse_products -->
```dart
import 'dart:convert';

import 'product_domain.dart';

/// Pure, synchronous and top-level: safe to run on any isolate.
List<Product> parseProducts(String body) => switch (jsonDecode(body)) {
  final List<Object?> rows => rows.map(_parseRow).toList(),
  final other => throw FormatException('Expected a JSON list, got ${other.runtimeType}'),
};

Product _parseRow(Object? row) => switch (row) {
  {'id': final int id, 'name': final String name, 'price': final num price} => Product(
    id: id,
    name: name,
    price: price.toDouble(),
  ),
  _ => throw FormatException('Bad product row: $row'),
};
```

Isolate'i açan fonksiyon: closure'ın kapsamında yalnızca `body` var (instance
metodu içinde closure yazıp `this`'i taşıma riskine girmiyoruz). Küçük payload
inline çözülür; isolate başlatmak kazançtan pahalıdır (Flutter `AssetBundle.loadString` ile aynı
50 KB eşiği):

<!-- snippet: 09_isolates/decode_products -->
```dart
import 'dart:isolate';

import 'parse_products.dart';
import 'product_domain.dart';

/// Parses inline below [isolateThreshold]; the closure captures only `body`.
Future<List<Product>> decodeProducts(String body, {int isolateThreshold = 50 * 1024}) async {
  if (body.length < isolateThreshold) return parseProducts(body);
  return Isolate.run(() => parseProducts(body), debugName: 'parseProducts');
}
```

RepositoryImpl: I/O düz `await`, CPU işi isolate'te, hata `Err`'e:

<!-- snippet: 09_isolates/product_repository_impl -->
```dart
import '../00_architecture/result.dart';
import 'decode_products.dart';
import 'product_domain.dart';

abstract interface class ProductRemoteDataSource {
  Future<String> fetchProductsBody();
}

final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote, {this.isolateThreshold = 50 * 1024});
  final ProductRemoteDataSource _remote;
  final int isolateThreshold;

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final body = await _remote.fetchProductsBody();
      return Ok(await decodeProducts(body, isolateThreshold: isolateThreshold));
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}
```

Domain tarafı isolate'ten habersizdir:

<!-- snippet: 09_isolates/product_domain -->
```dart
import '../00_architecture/result.dart';

final class Product {
  const Product({required this.id, required this.name, required this.price});
  final int id;
  final String name;
  final double price;
}

abstract interface class ProductRepository {
  Future<Result<List<Product>>> getProducts();
}
```

### Long-lived worker: robust ports

dart.dev: aynı hesabı tekrar tekrar `Isolate.run` ile yapmak her seferinde isolate
başlatma ve nesne kopyalama maliyeti öder; bunun yerine
[çıkmayan bir isolate](https://dart.dev/language/isolates#sending-multiple-messages-between-isolates-with-ports)
kur. Aşağıdaki kod [Robust ports example](https://dart.dev/language/isolates#robust-ports-example)'ın
uyarlamasıdır; farklar: `dynamic` → `Object?` (strict analiz), `print` yok, kapanışı
gözlemlemek için `Isolate.spawn(onExit:)` ile `exited` future'ı; ekranda okunabilsin diye worker
tarafı (`_startRemoteIsolate`/`_handleCommandsToIsolate`) ayrı dosyada top-level fonksiyonlara
bölündü ve `close()` erken `return` kullanıyor. Davranış aynı.

Handshake: `RawReceivePort` sadece ilk mesajı (worker'ın `SendPort`'u) alır, sonra
`ReceivePort.fromRawReceivePort` ile sarılır. dart.dev gerekçesi: `ReceivePort`
bir (broadcast olmayan) `Stream`'dir, tek listener alır; başlangıç mantığı ile
mesaj işleme mantığı böylece ayrılır. Spawn başarısız olursa port kapatılır:

<!-- snippet: 09_isolates/robust_worker#spawn -->
```dart
static Future<JsonWorker> spawn() async {
  final initPort = RawReceivePort();
  final connection = Completer<(ReceivePort, SendPort)>.sync();
  initPort.handler = (Object? initialMessage) {
    final commandPort = initialMessage! as SendPort;
    connection.complete((ReceivePort.fromRawReceivePort(initPort), commandPort));
  };
  final exited = Completer<void>();
  final onExit = exitPort(exited);

  try {
    await Isolate.spawn(startJsonWorkerIsolate, initPort.sendPort, onExit: onExit.sendPort);
  } on Object {
    initPort.close();
    onExit.close();
    rethrow;
  }

  final (ReceivePort receivePort, SendPort sendPort) = await connection.future;
  return JsonWorker._(receivePort, sendPort, exited.future);
}
```

`onExit` portu küçük bir yardımcıda; `exited` future'ı worker isolate sonlanınca tamamlanır:

<!-- snippet: 09_isolates/exit_port -->
```dart
import 'dart:async';
import 'dart:isolate';

/// Pass its `sendPort` as `onExit`; [exited] completes when the isolate ends.
RawReceivePort exitPort(Completer<void> exited) {
  final port = RawReceivePort();
  port.handler = (Object? _) {
    port.close();
    exited.complete();
  };
  return port;
}
```

Mesaj sıralaması: her istek bir `id` + `Completer` ile eşlenir; yanıtlar
**tamamlanma sırasıyla** gelse bile doğru çağırana döner. Worker'daki hata
`RemoteError` olarak taşınır ve `completeError` edilir:

<!-- snippet: 09_isolates/robust_worker#request -->
```dart
final Map<int, Completer<Object?>> _activeRequests = {};
int _idCounter = 0;
bool _closed = false;

Future<Object?> parseJson(String message) async {
  if (_closed) throw StateError('Closed');
  final completer = Completer<Object?>.sync();
  final id = _idCounter++;
  _activeRequests[id] = completer;
  _commands.send((id, message));
  return await completer.future;
}

void _handleResponsesFromIsolate(Object? message) {
  final (int id, Object? response) = message! as (int, Object?);
  final completer = _activeRequests.remove(id)!;
  if (response is RemoteError) {
    completer.completeError(response);
  } else {
    completer.complete(response);
  }
  if (_closed && _activeRequests.isEmpty) _responses.close();
}
```

Worker tarafı (isolate'in "main"i, `robust_worker_remote.dart`). Isolate'e giden fonksiyon
top-level olduğu için ayrı dosyada durabilir; hatalı JSON `RemoteError` değeri olarak geri yollanır:

<!-- snippet: 09_isolates/robust_worker_remote -->
```dart
import 'dart:convert';
import 'dart:isolate';

void startJsonWorkerIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((Object? message) => _handleCommand(message, receivePort, sendPort));
}

void _handleCommand(Object? message, ReceivePort receivePort, SendPort sendPort) {
  if (message == 'shutdown') {
    receivePort.close(); // the last open port closes, so the isolate exits
    return;
  }
  final (int id, String jsonText) = message! as (int, String);
  sendPort.send((id, _decode(jsonText)));
}

Object? _decode(String jsonText) {
  try {
    return jsonDecode(jsonText);
  } catch (error) {
    return RemoteError(error.toString(), '');
  }
}
```

Kapatma ([Step 6](https://dart.dev/language/isolates#step-6-add-functionality-to-close-the-ports)):
worker kendi `ReceivePort`'unu kapatır → açık portu kalmayan isolate sonlanır;
ana taraf bekleyen istek kalmayınca `_responses`'u kapatır. Test: çoklu ve eşzamanlı
istek, hatalı JSON → `RemoteError`, `close()` sonrası `exited` tamamlanır,
yeni istek `StateError`.

<!-- snippet: 09_isolates/robust_worker#close -->
```dart
void close() {
  if (_closed) return;
  _closed = true;
  _commands.send('shutdown');
  if (_activeRequests.isEmpty) _responses.close();
}
```

### Flutter `compute` (yalnızca metin)

Flutter 3.47.5 kaynağından (`foundation/isolates.dart`, `_isolates_io.dart`,
`_isolates_web.dart`):

- İmza: `Future<R> compute<M, R>(ComputeCallback<M, R> callback, M message, {String? debugLabel})`,
  `typedef ComputeCallback<M, R> = FutureOr<R> Function(M message)`.
- **Native**: `Isolate.run<R>(() => callback(message), debugName: debugLabel)`.
  `debugLabel` verilmezse release'te `'compute'`, değilse `callback.toString()`.
  Doc: "`await compute(fun, message)` is equivalent to `await Isolate.run(() => fun(message))`".
- **Web** (`dart.library.js_interop`): `await null;` ile bir kez yield eder, sonra
  `callback(message)`'ı **aynı event loop'ta** çalıştırır. Paralellik yok; uzun iş
  UI'ı yine bloklar.
- Framework doc'u: birkaç milisaniyeden uzun işler için; ~1 ms'lik işlerde
  `SchedulerBinding.scheduleTask` önerir.

### Performans ve isolate grupları

[dart.dev](https://dart.dev/language/concurrency#performance-and-isolate-groups):
`Isolate.spawn` ile açılan isolate aynı **isolate group**'tadır, kodu paylaşır ve
hemen çalışmaya başlar; `Isolate.exit` yalnızca aynı gruptaki isolate'ler arasında
çalışır. `Isolate.spawnUri` çok daha yavaştır, spawner'ın grubunda değildir ve
gruplar arası mesajlaşma daha yavaştır. `Isolate.spawn` API dokümanı: bir
isolate'in temel bellek maliyeti ~30 KB mertebesindedir.

### Web

[Concurrency on the web](https://dart.dev/language/concurrency#concurrency-on-the-web):
Dart web platformu isolate'leri **desteklemez**; web worker'lar ayrı entrypoint
ve ayrı derleme ister (`spawnUri`'ye benzer), veriyi kopyalar. Çok platformlu
Data katmanında isolate'i doğrudan kullanmak yerine Flutter'da `compute`
(web'de inline fallback) veya conditional import gerekir.

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde `compute` fonksiyonu
**3** yerde tanımlı (facade + io + web) ve **4** yerde çağrılıyor
(`dart run dartadvance_tool:dartadvance flutter-src grep --count '[^a-zA-Z]compute(<[^>]*>)?\('` → 7).
Framework'te `Isolate.run`'ın tek doğrudan kullanımı `compute`'un io implementasyonudur.

| Sembol | Ne gösteriyor | Kaynak |
|---|---|---|
| `ComputeCallback<M, R> = FutureOr<R> Function(M message)` | Isolate'e giden callback tipi; senkron veya async olabilir | [foundation/isolates.dart#L19](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/isolates.dart#L19) |
| `compute<M, R>(...)` | Public facade; conditional import ile io/web implementasyonuna yönlenir | [foundation/isolates.dart#L81](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/isolates.dart#L81) |
| `Isolate.run<R>(() { return callback(message); }, debugName: debugLabel)` | Native'de `compute` = `Isolate.run` | [foundation/_isolates_io.dart#L22](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/_isolates_io.dart#L22) |
| web `compute` → `await null; return callback(message);` | Web'de isolate yok: aynı event loop | [foundation/_isolates_web.dart#L11](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/_isolates_web.dart#L11) |
| `if (data.lengthInBytes < 50 * 1024 \|\| kIsWeb)` | Eşik: küçük veri ve web'de inline decode | [services/asset_bundle.dart#L95](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/asset_bundle.dart#L95) |
| `compute(_utf8decode, data, debugLabel: ...)` | `static` fonksiyon + `debugLabel` ile büyük UTF-8 decode | [services/asset_bundle.dart#L100](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/asset_bundle.dart#L100) |
| `compute<List<int>, List<int>>(gzip.decode, ...)` | Lisans dosyası: gzip → utf8 → parse, üç ardışık `compute` (web'de gzip adımı atlanır) | [services/binding.dart#L208](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/binding.dart#L208) |
| `compute<String, List<LicenseEntry>>(_parseLicenses, ...)` | Ağır parse → entity listesi (bizim `parseProducts` deseninin aynısı) | [services/binding.dart#L219](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/binding.dart#L219) |
| `Map<int, Completer<ByteData?>> _completers` | `BackgroundIsolateBinaryMessenger`: `ReceivePort` + id→`Completer` eşlemesi, robust ports desenindeki `_activeRequests` ile aynı fikir | [services/_background_isolate_binary_messenger_io.dart#L18](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/_background_isolate_binary_messenger_io.dart#L18) |

## Lint'ler

İsolate'e özgü bir lint **yok** (`lints` core/recommended setlerinde de yok). Dolaylı
ilgili, hiçbir sette olmayan opsiyonel kurallar:

| Lint | Set | Neden ilgili |
|---|---|---|
| [unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures) | hiçbiri (opsiyonel) | `async` gövdede `await` edilmeyen `Future`: `Isolate.run(...)` sonucunu unutmak hatayı da kaybettirir |
| [discarded_futures](https://dart.dev/tools/linter-rules/discarded_futures) | hiçbiri (opsiyonel) | Senkron fonksiyonda atanmayan/döndürülmeyen `Future` çağrısı |
| [avoid_dynamic_calls](https://dart.dev/tools/linter-rules/avoid_dynamic_calls) | hiçbiri (opsiyonel) | Port mesajları `Object?`/`dynamic` gelir; pattern veya `as` ile tiple, dinamik çağrı yapma |

## Kontrol listesi

- [ ] İş gerçekten **CPU-bound** mu (frame kaçırtıyor mu)? I/O ise düz `await`.
- [ ] Payload küçükse isolate açma (eşik: Flutter `loadString` 50 KB).
- [ ] Tek seferlik iş → `Isolate.run` (Flutter'da `compute`); tekrar eden iş → long-lived worker.
- [ ] Isolate'e giden fonksiyon top-level/static ve saf; closure yalnızca gereken durumu yakalıyor (ayrı fonksiyon içinde oluşturuldu).
- [ ] Gönderilen/yakalanan değerler sendable (`ReceivePort`, `Socket`, `Pointer`, `Finalizer` yok).
- [ ] Global mutable duruma güvenilmiyor — isolate'in kendi kopyası var.
- [ ] Isolate'ten gelen exception RepositoryImpl'de `Err(Failure)`'a çevriliyor; UseCase isolate bilmiyor.
- [ ] Worker: spawn hatasında port kapatılıyor, istekler id + `Completer` ile eşleniyor, `close()` her iki taraftaki portları kapatıyor.
- [ ] Web hedefi varsa: `dart:isolate` yok → `compute` (inline fallback) veya conditional import.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.
Hepsi Dart VM hedefi içindir; web hedefi varsa önce "Web" bölümüne bak.

### Tarif: Eşikli arka plan parse (`Isolate.run`)
- **Demo promptu:** "Büyük bir GPX rota dosyasını nokta listesine çeviren, küçük dosyada ana isolate'te, büyük dosyada `Isolate.run` ile çalışan bir parse fonksiyonu yaz."
- **Model:** [`examples/lib/09_isolates/decode_products.dart`](../../../examples/lib/09_isolates/decode_products.dart) (saf parse: [`examples/lib/09_isolates/parse_products.dart`](../../../examples/lib/09_isolates/parse_products.dart))
- **Katman:** Data
- **Adımlar:** 1. Saf, senkron, top-level bir parse fonksiyonu yaz; bozuk girdide `FormatException` fırlat. 2. Satır eşlemeyi switch expression'lı private yardımcıya ayır. 3. Isolate'i açan ayrı bir fonksiyon yaz; closure yalnız gövdeyi yakalasın (`this` değil). 4. Eşik altındaki gövdeyi inline çöz, üstündekini `Isolate.run(..., debugName: ...)` ile.
- **Kabul kriteri:** Büyük gövde başka isolate'te çözülüp doğru sayıda entity verdi; küçük gövde aynı sonucu verdi; isolate içindeki `FormatException` çağırana aynı tiple ulaştı.
- **Min. sürüm:** 2.19 (`Isolate.run`); switch pattern için 3.0.

### Tarif: I/O `await` + CPU isolate + `Err` (RepositoryImpl)
- **Demo promptu:** "Muhasebe fişlerini CSV olarak indirip kategori toplamlarını isolate'te hesaplayan, hatayı `Err`'e çeviren bir repository ve use case yaz."
- **Model:** [`examples/lib/09_isolates/product_repository_impl.dart`](../../../examples/lib/09_isolates/product_repository_impl.dart) (domain: [`examples/lib/09_isolates/product_domain.dart`](../../../examples/lib/09_isolates/product_domain.dart))
- **Katman:** Domain / Data
- **Adımlar:** 1. Domain'de entity ve `Future<Result<T>>` dönen repository sözleşmesini yaz; isolate'ten söz etme. 2. DataSource ham gövdeyi düz `await` ile getirsin. 3. RepositoryImpl CPU işini eşikli parse fonksiyonuna versin. 4. Her hatayı `try/catch` ile `Err(UnexpectedFailure(error, stackTrace))` yap.
- **Kabul kriteri:** Isolate içinde fırlayan `FormatException` `Err(UnexpectedFailure)` oldu ve `failure.error` hâlâ `FormatException`; geçerli gövde `Ok` döndü.
- **Min. sürüm:** 3.0 (`sealed` `Result`); `Isolate.run` 2.19.

### Tarif: Uzun ömürlü worker (robust ports)
- **Demo promptu:** "Sürekli gelen log satırlarını ayrıştıran, istekleri id ile eşleyen ve `close()` ile temiz kapanan uzun ömürlü bir worker isolate yaz."
- **Model:** [`examples/lib/09_isolates/robust_worker.dart`](../../../examples/lib/09_isolates/robust_worker.dart) (worker tarafı: [`examples/lib/09_isolates/robust_worker_remote.dart`](../../../examples/lib/09_isolates/robust_worker_remote.dart), çıkış portu: [`examples/lib/09_isolates/exit_port.dart`](../../../examples/lib/09_isolates/exit_port.dart))
- **Katman:** Data (uzun ömürlü servis)
- **Adımlar:** 1. Handshake için `RawReceivePort` aç, ilk mesajdaki `SendPort`'u al, sonra `ReceivePort.fromRawReceivePort` ile sar. 2. `Isolate.spawn(onExit:)` ile başlat; spawn hatasında portları kapatıp `rethrow` et. 3. Her isteğe artan `id` ver, `id → Completer` map'inde tut, record `(id, payload)` gönder. 4. Worker tarafını top-level fonksiyonlarda yaz; hatayı `RemoteError` değeri olarak geri yolla, kapatma mesajında portunu kapat. 5. `close()`: bayrağı kur, kapatma mesajı yolla, bekleyen istek yoksa yanıt portunu kapat.
- **Kabul kriteri:** Sıralı ve eşzamanlı istekler doğru cevabı aldı; worker hatası `RemoteError` olarak geldi; `close()` sonrası `exited` tamamlandı ve yeni istek `StateError` verdi.
- **Min. sürüm:** 3.0 (record).

### Tarif: Worker isolate'ten gelen stream
- **Demo promptu:** "Mandelbrot görüntüsünün satırlarını worker isolate'te hesaplayıp `Stream<Row>` olarak veren, tüketici durunca isolate'i öldüren bir fonksiyon yaz."
- **Model:** [`examples/lib/09_isolates/practice/ex3_primes_in_isolate.dart`](../../../examples/lib/09_isolates/practice/ex3_primes_in_isolate.dart) (worker: [`examples/lib/09_isolates/practice/ex3_prime_worker.dart`](../../../examples/lib/09_isolates/practice/ex3_prime_worker.dart))
- **Katman:** Data
- **Adımlar:** 1. Controller'ı saran küçük bir private sınıf yaz; isolate'i yalnız `onListen`'de `Isolate.spawn` ile aç. 2. Worker her sonucu `SendPort` ile yollasın, bitince `null` göndersin ve sonuçlar arasında event loop'a yield etsin. 3. Mesaj handler'ı veriyi `add` etsin, `null` gelince portu ve controller'ı kapatsın. 4. `onCancel`'da isolate'i `kill` et ve portu kapat; spawn sürerken iptal geldiyse spawn bitince öldür. 5. `exited` future'ını `onExit` portundan ver.
- **Kabul kriteri:** Sonlu iş tüm değerleri verip stream'i kapattı ve `exited` tamamlandı; sonsuz iş `take(n)` sonrası öldürüldü ve `exited` tamamlandı.
- **Min. sürüm:** 3.0 (record, if-case).

## Pekiştirme

### Alıştırma 1 · Kopyalanan liste, tipini koruyan hata (kolay)
`Future<List<int>> sortedInIsolate(List<int> numbers)` yaz: listeyi `Isolate.run` içinde
**yerinde** (`sort()`) sıralayıp döndürür. Beklenen: dönen liste sıralı, çağıranın elindeki
liste **değişmemiş**. Boş listede isolate içinde `ArgumentError` fırlat; çağıran tarafta
aynı tipte (`ArgumentError`) yakalanabilmeli.

**İpucu:** [Isolates aren't threads](https://dart.dev/language/concurrency#isolates-arent-threads) ve "Resmi örnekler" bölümündeki hata notu: mesajlar kopyalanır, `Isolate.run` computation'ın fırlattığı hatayı aynen fırlatır.

<details><summary>Çözüm</summary>

<!-- snippet: 09_isolates/practice/ex1_sorted_in_isolate -->
```dart
import 'dart:isolate';

/// Sorts a copy in place: the caller's list is left untouched.
Future<List<int>> sortedInIsolate(List<int> numbers) =>
    Isolate.run(() => _sortInPlace(numbers), debugName: 'sortedInIsolate');

List<int> _sortInPlace(List<int> numbers) {
  if (numbers.isEmpty) throw ArgumentError.value(numbers, 'numbers', 'must not be empty');
  return numbers..sort();
}
```

</details>

### Alıştırma 2 · Satış toplamları: UseCase isolate bilmez (orta)
Katmanlı bir akış yaz: Domain'de `SalesRepository` (`Future<Result<Map<String, double>>>
totalsByCategory()`) ve callable `LoadSalesTotals`; Data'da CSV'yi getiren
`SalesRemoteDataSource` (düz `await`), saf/top-level `sumByCategory(String csv)`
(`kategori,tutar` satırları, bozuk satırda `FormatException`) ve bunu `Isolate.run` ile
çalıştıran `SalesRepositoryImpl`. Closure yalnızca `csv`'yi yakalamalı (repository'yi değil);
isolate'ten gelen `FormatException` `Err(UnexpectedFailure)` olmalı.

**İpucu:** "Data: ağır parse → `Result`" bölümü: isolate'i açan closure'ı yalnızca gereken durumu parametre alan ayrı bir fonksiyonda oluştur; exception sınırı tipiyle geçer.

<details><summary>Çözüm</summary>

<!-- snippet: 09_isolates/practice/ex2_sales_domain -->
```dart
import '../../00_architecture/result.dart';

abstract interface class SalesRepository {
  Future<Result<Map<String, double>>> totalsByCategory();
}

final class LoadSalesTotals {
  const LoadSalesTotals(this._repository);
  final SalesRepository _repository;

  Future<Result<Map<String, double>>> call() => _repository.totalsByCategory();
}
```

<!-- snippet: 09_isolates/practice/ex2_sum_by_category -->
```dart
/// Pure, synchronous CPU work over `category,amount` lines.
Map<String, double> sumByCategory(String csv) {
  final totals = <String, double>{};
  for (final line in csv.split('\n')) {
    if (line.trim().isEmpty) continue;
    final (category, amount) = _parseLine(line);
    totals[category] = (totals[category] ?? 0) + amount;
  }
  return totals;
}

(String, double) _parseLine(String line) => switch (line.split(',')) {
  [final category, final amount] => (category.trim(), double.parse(amount)),
  _ => throw FormatException('Bad sales line: $line'),
};
```

<!-- snippet: 09_isolates/practice/ex2_sales_repository_impl -->
```dart
import 'dart:isolate';

import '../../00_architecture/result.dart';
import 'ex2_sales_domain.dart';
import 'ex2_sum_by_category.dart';

abstract interface class SalesRemoteDataSource {
  Future<String> fetchCsv();
}

/// Captures only [csv]: the repository is never copied into the isolate.
Future<Map<String, double>> _sumInBackground(String csv) =>
    Isolate.run(() => sumByCategory(csv), debugName: 'sumByCategory');

final class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remote);
  final SalesRemoteDataSource _remote;

  @override
  Future<Result<Map<String, double>>> totalsByCategory() async {
    try {
      final csv = await _remote.fetchCsv();
      return Ok(await _sumInBackground(csv));
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}
```

</details>

### Alıştırma 3 · Worker isolate'ten gelen asal sayı stream'i (zor)
[07](07-streams.md)'deki `StreamController` kurallarını bir worker isolate'e uygula:
`primesInIsolate({int? limit})` bir `({Stream<int> primes, Future<void> exited})` döner.
Isolate `onListen`'de `Isolate.spawn` ile açılır, asalları `SendPort` ile yollar, bitince
`null` gönderir (stream kapanır). `limit` `null` ise worker sonsuzdur: tüketici
`take(4)` ile durunca `onCancel` isolate'i `kill` etmeli ve portu kapatmalı; `exited`
(`onExit` portu) tamamlanmalı. Spawn sürerken iptal gelirse spawn bitince worker yine
öldürülmeli.

**İpucu:** "Long-lived worker: robust ports" bölümü (`onExit` ile `exited`, `ReceivePort` tek dinleyicili bir `Stream`) ve 07'deki "dinleyici yokken iş yok, `onCancel`'da kaynağı kapat" kuralı.

<details><summary>Çözüm</summary>

<!-- snippet: 09_isolates/practice/ex3_primes_in_isolate -->
```dart
import 'dart:async';
import 'dart:isolate';

import '../exit_port.dart';
import 'ex3_prime_worker.dart';

/// Nothing is spawned before `onListen`; cancelling kills the worker.
({Stream<int> primes, Future<void> exited}) primesInIsolate({int? limit}) {
  final source = _PrimeSource(limit);
  return (primes: source.controller.stream, exited: source.exited.future);
}

final class _PrimeSource {
  _PrimeSource(this._limit) {
    controller = StreamController<int>(onListen: () => unawaited(_start()), onCancel: _cancel);
  }
  final int? _limit;
  final exited = Completer<void>();
  late final StreamController<int> controller;
  ReceivePort? _messages;
  Isolate? _isolate;
  var _cancelled = false;

  Future<void> _start() async {
    final messages = _messages = ReceivePort()..listen(_onMessage);
    final onExit = exitPort(exited);
    try {
      _isolate = await _spawn(messages.sendPort, onExit.sendPort);
    } on Object catch (error, stackTrace) {
      messages.close();
      onExit.close();
      controller.addError(error, stackTrace);
      unawaited(controller.close());
      return;
    }
    // Cancelled while spawning: stop the worker right away.
    if (_cancelled) _kill();
  }

  Future<Isolate> _spawn(SendPort results, SendPort onExit) =>
      Isolate.spawn(primeWorker, (_limit, results), onExit: onExit, debugName: 'primes');

  void _onMessage(Object? message) {
    if (message case final int prime) {
      controller.add(prime);
      return;
    }
    _messages?.close();
    unawaited(controller.close());
  }

  void _cancel() {
    _cancelled = true;
    _kill();
    _messages?.close();
  }

  void _kill() => _isolate?.kill(priority: Isolate.immediate);
}
```

<!-- snippet: 09_isolates/practice/ex3_prime_worker -->
```dart
import 'dart:isolate';

/// Worker entry point; yields between primes so a kill can be handled.
Future<void> primeWorker((int?, SendPort) message) async {
  final (limit, results) = message;
  for (var n = 2; limit == null || n <= limit; n++) {
    if (_isPrime(n)) results.send(n);
    await Future<void>.delayed(Duration.zero);
  }
  results.send(null);
}

bool _isPrime(int n) {
  for (var divisor = 2; divisor * divisor <= n; divisor++) {
    if (n % divisor == 0) return false;
  }
  return true;
}
```

</details>

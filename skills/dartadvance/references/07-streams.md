# 07 · Streams

> Kaynak: https://dart.dev/libraries/async/using-streams#two-kinds-of-streams ·
> https://dart.dev/libraries/async/creating-streams#using-a-streamcontroller ·
> https://dart.dev/libraries/async/creating-streams#honoring-the-pause-state ·
> https://dart.dev/language/async#handling-streams ·
> https://dart.dev/language/functions#generators ·
> https://dart.dev/libraries/dart-async#stream
> API: [Stream](https://api.dart.dev/stable/latest/dart-async/Stream-class.html),
> [StreamController](https://api.dart.dev/stable/latest/dart-async/StreamController-class.html),
> [StreamTransformer.fromHandlers](https://api.dart.dev/stable/latest/dart-async/StreamTransformer/StreamTransformer.fromHandlers.html),
> [Stream.asBroadcastStream](https://api.dart.dev/stable/latest/dart-async/Stream/asBroadcastStream.html)
> Min. dil sürümü: `Stream`, `async*`/`yield`/`yield*`, `await for` için dokümanlarda sürüm notu yok
> (Dart 3 SDK alt sınırında hepsi mevcut). Mimari örnekteki `sealed` + switch pattern'leri 3.0 ister.

`Future` **tek** bir asenkron sonuçtur; `Stream` asenkron olayların **dizisidir**
(data, error, done). Stream'i ya `await for` ile ya da `listen()` ile tüketirsin;
`listen()` bir `StreamSubscription` döner ve pause/resume/cancel onun üzerindendir.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| Zaman içinde **birden fazla** değer gelen kaynak: WebSocket, sensör, bağlantı durumu, dosya chunk'ları | Tek asenkron değer (HTTP GET, DB okuma) → **`Future<Result<T>>`** ([06](06-event-loop-future.md)). Tek elemanlı stream gereksiz karmaşa |
| Olaylar programın farklı yerlerinden geliyorsa → **`StreamController`** | Olaylar başka bir stream'den / future dizisinden türetiliyorsa → **`async*`** (pause ve abonelik beklemeyi otomatik yapar) ya da `map`/`where`/`expand`/`take` |
| Birden çok bağımsız dinleyici (UI olayları, bildirim) → **broadcast** | Sıralı, eksiksiz teslim gereken veri (dosya, response gövdesi) → **single-subscription** (varsayılan) |
| Birden fazla girdi olayından tek çıktı (decode, satıra bölme) → `transform()` + `StreamTransformer` | Olay başına tek çıktı → düz `map()` yeter |
| UI olayları, bitmeyen stream'ler → `listen()` + sakladığın subscription | `await for` sonsuz stream'de sonraki satıra hiç geçmez ([dart.dev notu](https://dart.dev/language/async#handling-streams)) |
| — | Senkron, tembel dizi → `sync*` + `Iterable` (ileride: Iterables). `Stream` sınıfını kendin implement etme; bir `StreamController`'ın stream'ini döndür ([final hints](https://dart.dev/libraries/async/creating-streams#final-hints)) |

**İki tür stream** ([dart.dev](https://dart.dev/libraries/async/using-streams#two-kinds-of-streams)):

| | Single-subscription | Broadcast |
|---|---|---|
| Dinleyici sayısı | Ömür boyu **bir**; ikinci `listen` → `StateError` (ilki cancel edilmiş olsa bile) | İstenen kadar; cancel sonrası tekrar dinlenebilir |
| Dinleyici yokken | Controller olayları **buffer**'lar (dinleyici hiç gelmezse bellek sızıntısı) | Olaylar **düşer**, buffer yok |
| Pause | Kaynak `onPause` ile haberdar edilir | Controller hiçbir zaman paused sayılmaz; her abonelik kendi buffer'ını tutar |
| Callback'ler | `onListen`, `onPause`, `onResume`, `onCancel` | `onListen` (ilk dinleyici), `onCancel` (son dinleyici gitti) |
| Üretim | `async*`, `StreamController()` | `StreamController.broadcast()`, `stream.asBroadcastStream()` |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Data / DataSource | Gerçek zamanlı kaynak (WebSocket, platform event channel). Bağlantı `onListen`'de açılır, `onCancel`'da kapanır; kimse dinlemiyorsa kaynak **inert** kalır |
| Data / RepositoryImpl | Ham frame → entity; hata **stream'i sonlandırmaz**, `Err` olayı olur: `Stream<Result<T>>` |
| Domain / UseCase | `final class` + `Stream<Result<T>> call(...)`; repository stream'ini aynen geçirir |
| Application / state sınıfı (düz Dart) | `start()`'ta `listen`, `StreamSubscription`'ı alan olarak sakla, `dispose()`/`close()`'da `await cancel()` |
| Presentation | Flutter'da `StreamBuilder` (aboneliği kendisi yönetir); state management kullanıyorsan stream'i Notifier'da tüket |

## Doğrulanmış örnekler

Tüm kod `examples/lib/07_streams/` altında, her kavram ayrı dosyada (dosya adı = snippet id);
testleri `examples/test/07_streams/` altında (`dart run dartadvance_tool:dartadvance verify 07_streams`).

### Resmi örnekler (dart.dev)

dart.dev kodunun satır içi yorumları çıkarıldı (açıklama burada), `while (k < n) yield k++;`
`curly_braces_in_flow_control_structures` lint'i için süslü paranteze alındı; davranış aynı.

`await for` ile tüketme, `async*` ile üretme
([receiving stream events](https://dart.dev/libraries/async/using-streams#receiving-stream-events)):

<!-- snippet: 07_streams/sum_stream -->
```dart
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream) {
    sum += value;
  }
  return sum;
}

Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    yield i;
  }
}
```

Hata `await for` döngüsünden **fırlatılır** ve döngüyü bitirir; `try-catch` ile yakala
([error events](https://dart.dev/libraries/async/using-streams#error-events)):

<!-- snippet: 07_streams/sum_stream_with_catch -->
```dart
Future<int> sumStreamWithCatch(Stream<int> stream) async {
  var sum = 0;
  try {
    await for (final value in stream) {
      sum += value;
    }
  } catch (e) {
    return -1;
  }
  return sum;
}
```

Generator'lar: `yield` tek olay, `yield*` başka bir stream'in **tüm** olaylarını
(data + error) iletir ([generators](https://dart.dev/language/functions#generators);
`optionalMap` `Stream` API dokümanından):

<!-- snippet: 07_streams/generators -->
```dart
Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 0;
  while (k < n) {
    yield k++;
  }
}

/// `yield*` forwards every event of [source], errors included.
Stream<T> optionalMap<T>(Stream<T> source, [T Function(T)? convert]) async* {
  if (convert == null) {
    yield* source;
  } else {
    await for (var event in source) {
      yield convert(event);
    }
  }
}
```

Var olan stream'i dönüştürme — birden çok girdi chunk'ından satır üretme
([transforming an existing stream](https://dart.dev/libraries/async/creating-streams#transforming-an-existing-stream)):

<!-- snippet: 07_streams/split_lines -->
```dart
/// Splits a stream of consecutive string chunks into lines.
Stream<String> lines(Stream<String> source) async* {
  var partial = '';
  await for (final chunk in source) {
    var lines = chunk.split('\n');
    lines[0] = partial + lines[0];
    partial = lines.removeLast();
    for (final line in lines) {
      yield line;
    }
  }
  if (partial.isNotEmpty) yield partial;
}
```

Dört callback'i de kullanan, pause'a saygılı controller
([honoring the pause state](https://dart.dev/libraries/async/creating-streams#honoring-the-pause-state)).
Doküman: pause durumunu doğru izlemek için **dördü de** gerekli; abonelik ve pause
durumu aynı anda değişirse yalnızca `onListen`/`onCancel` çağrılır.

<!-- snippet: 07_streams/timed_counter -->
```dart
import 'dart:async';

Stream<int> timedCounter(Duration interval, [int? maxCount]) {
  late StreamController<int> controller;
  Timer? timer;
  int counter = 0;

  void tick(Timer _) {
    counter++;
    controller.add(counter);
    if (counter == maxCount) {
      timer?.cancel();
      controller.close();
    }
  }

  void startTimer() {
    timer = Timer.periodic(interval, tick);
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  controller = StreamController<int>(
    onListen: startTimer,
    onPause: stopTimer,
    onResume: startTimer,
    onCancel: stopTimer,
  );

  return controller.stream;
}
```

### StreamController yaşam döngüsü ve backpressure

`StreamController` pause sırasında olayları buffer'lar; kaynak pause'a uymazsa buffer
sınırsız büyür. Aşağıdaki kaynak her değeri ayrı bir event-loop turunda üretir ve
`running` bayrağıyla pause/cancel'a uyar:

<!-- snippet: 07_streams/pausable_counter -->
```dart
import 'dart:async';

/// Produces one value per event-loop turn, so a pause stops the next value
/// from being produced at all instead of piling it up in the buffer.
Stream<int> pausableCounter(int maxCount, {void Function(String event)? log}) {
  late final StreamController<int> controller;
  var next = 1;
  var running = false;

  void produce() {
    if (!running) return;
    if (next > maxCount) {
      running = false;
      controller.close();
      return;
    }
    log?.call('produce $next');
    controller.add(next++);
    Timer.run(produce);
  }

  void start(String event) {
    log?.call(event);
    running = true;
    Timer.run(produce);
  }

  void stop(String event) {
    log?.call(event);
    running = false;
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

Testin doğruladığı sıra: dinleyici yokken log boş → `onListen, produce 1, produce 2,
onPause` (2'de pause edildi, 3 **üretilmedi**) → `onResume, produce 3, produce 4, onCancel`.
Son `onCancel`: `close()` sonrası "done" olayı aboneliği bitirir ve controller
`onCancel`'ı çağırır (test ile gözlemlendi; API dokümanı bunu açıkça yazmıyor).

`async*` bunu kendiliğinden yapar: abonelik iptal edilince bir sonraki `yield`
`return` gibi davranır, `finally` çalışır, gövde başka değer üretmez; `cancel()`'ın
döndürdüğü future fonksiyon bitince tamamlanır
([creating a stream from scratch](https://dart.dev/libraries/async/creating-streams#creating-a-stream-from-scratch)):

<!-- snippet: 07_streams/endless_ids -->
```dart
/// After cancel, the next `yield` acts as a `return`: `finally` runs.
Stream<int> endlessIds({
  required void Function(int id) onProduce,
  required void Function() onFinally,
}) async* {
  var id = 0;
  try {
    while (true) {
      await Future<void>.delayed(Duration.zero);
      onProduce(++id);
      yield id;
    }
  } finally {
    onFinally();
  }
}
```

### Broadcast

Dinleyici yokken eklenen olay düşer; iki dinleyici aynı olayı alır (testte doğrulandı).
Bir single-subscription stream'i paylaşmak gerekirse `asBroadcastStream()`:

<!-- snippet: 07_streams/broadcast_stream -->
```dart
import 'dart:async';

/// Events reported while nobody listens are dropped.
final class ConnectivityEvents {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get changes => _controller.stream;

  void report({required bool online}) => _controller.add(online);

  Future<void> close() => _controller.close();
}
```

### StreamTransformer

`fromHandlers` handler'ları **stateless** olmalı (aynı transformer birden çok stream'e
bağlanabilir); stream başına state gerekirse `StreamTransformer.fromBind`. Handler'a
verilen `sink` yalnızca o çağrı sırasında kullanılır, saklanmaz.

<!-- snippet: 07_streams/trim_frames_transformer -->
```dart
import 'dart:async';

final trimFrames = StreamTransformer<String, String>.fromHandlers(
  handleData: (frame, sink) {
    final trimmed = frame.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed);
  },
);
```

### Mimari: DataSource → Repository → UseCase → Notifier

Domain: stream elemanları `Result<T>`; kötü bir frame stream'i bitirmez.

<!-- snippet: 07_streams/price_domain -->
```dart
import '../00_architecture/result.dart';

final class PriceTick {
  const PriceTick({required this.symbol, required this.price});
  final String symbol;
  final double price;
}

abstract interface class PriceRepository {
  /// A bad frame is an `Err` event, not the end of the stream.
  Stream<Result<PriceTick>> watchPrices(String symbol);
}

final class WatchPrices {
  const WatchPrices(this._repository);
  final PriceRepository _repository;

  Stream<Result<PriceTick>> call(String symbol) => _repository.watchPrices(symbol);
}
```

Data / DataSource: WebSocket benzeri, **ağ yok**, bellek içi. Bağlantı ilk
dinleyicide açılır, son dinleyici gidince kapanır (Flutter'ın
`EventChannel.receiveBroadcastStream` deseni):

<!-- snippet: 07_streams/price_socket -->
```dart
import 'dart:async';

/// Connected only while someone listens: `onListen` opens, `onCancel` closes.
final class InMemoryPriceSocket {
  late final StreamController<String> _frames = StreamController<String>.broadcast(
    onListen: () => _connected = true,
    onCancel: () => _connected = false,
  );
  var _connected = false;

  bool get isConnected => _connected;

  Stream<String> get frames => _frames.stream;

  void push(String frame) => _frames.add(frame);

  Future<void> close() => _frames.close();
}
```

Data / RepositoryImpl: frame → `Result<PriceTick>`; parse hatası `Err` olayı olur.

<!-- snippet: 07_streams/price_repository_impl -->
```dart
import 'dart:convert';

import '../00_architecture/result.dart';
import 'price_domain.dart';
import 'price_socket.dart';

final class PriceRepositoryImpl implements PriceRepository {
  const PriceRepositoryImpl(this._socket);
  final InMemoryPriceSocket _socket;

  @override
  Stream<Result<PriceTick>> watchPrices(String symbol) =>
      _socket.frames.map(_decode).where((result) => _belongsTo(result, symbol));

  static bool _belongsTo(Result<PriceTick> result, String symbol) => switch (result) {
    Ok(:final value) => value.symbol == symbol,
    Err() => true,
  };

  static Result<PriceTick> _decode(String frame) {
    try {
      return _parse(jsonDecode(frame));
    } on FormatException catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }

  static Result<PriceTick> _parse(Object? json) => switch (json) {
    {'symbol': final String symbol, 'price': final num price} => Ok(
      PriceTick(symbol: symbol, price: price.toDouble()),
    ),
    _ => Err(UnexpectedFailure(FormatException('Bad price frame: $json'), StackTrace.current)),
  };
}
```

Application: state tutan düz Dart sınıfı. `start()` abone olur,
`dispose()` `await cancel()` ile bırakır → DataSource'un `onCancel`'ı bağlantıyı kapatır;
dispose sonrası gelen frame state'i değiştirmez (testte doğrulandı).

<!-- snippet: 07_streams/price_ticker_notifier -->
```dart
import 'dart:async';

import '../00_architecture/result.dart';
import 'price_domain.dart';

final class PriceTickerNotifier {
  PriceTickerNotifier(this._watchPrices);
  final WatchPrices _watchPrices;

  StreamSubscription<Result<PriceTick>>? _subscription;

  double? latestPrice;
  Failure? lastFailure;

  bool get isActive => _subscription != null;

  void start(String symbol) {
    _subscription ??= _watchPrices(symbol).listen(_onResult);
  }

  void _onResult(Result<PriceTick> result) => switch (result) {
    Ok(:final value) => _showPrice(value.price),
    Err(:final failure) => _showFailure(failure),
  };

  void _showPrice(double price) {
    latestPrice = price;
    lastFailure = null;
  }

  void _showFailure(Failure failure) {
    lastFailure = failure;
  }

  /// Awaiting `cancel()` waits until the source has finished its cleanup.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde `StreamController<` geçen
**10** satır (`dart run dartadvance_tool:dartadvance flutter-src grep --count 'StreamController<'`),
`StreamSubscription<` geçen **3** satır var. Framework az ama kurala uygun stream üretir.

| Sembol | Ne gösteriyor | Kaynak |
|---|---|---|
| `StreamBuilderBase<T, S>` | Stream'i summary'ye fold eden widget tabanı (`afterData`/`afterError`/`afterDone`) | [widgets/async.dart#L44](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L44) |
| `StreamBuilder<T>` | `AsyncSnapshot<T>` üreten somut builder | [widgets/async.dart#L406](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L406) |
| `_StreamBuilderBaseState._subscription` | Subscription alan olarak saklanır; `_subscribe()` `listen(onData, onError, onDone)` ile bağlanır ([L133](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L133)) | [widgets/async.dart#L100](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L100) |
| `_StreamBuilderBaseState.dispose` / `_unsubscribe` | `dispose()`'da ve stream değişince (`didUpdateWidget`) `cancel()` + `null` ([L156](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L156)) | [widgets/async.dart#L126](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L126) |
| `EventChannel.receiveBroadcastStream` | `StreamController.broadcast(onListen: ..., onCancel: ...)`: platform stream'i 0→1 dinleyicide aktive, 1→0'da deaktive edilir — DataSource örneğimizin deseni | [services/platform_channel.dart#L696](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/platform_channel.dart#L696) |
| `LicenseRegistry.licenses` | Pahalı iş `onListen`'e kadar başlamaz; collector stream'leri `addStream` ile sırayla aktarılır ([L322](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/licenses.dart#L322)) | [foundation/licenses.dart#L319](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/licenses.dart#L319) |
| `ServicesBinding._addLicenses` | `onListen` içinde asset okuma + `compute` ile parse, sonra `add` ve `close` (bkz. [09](09-isolates.md)) | [services/binding.dart#L196](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/binding.dart#L196) |
| `MultiFrameImageStreamCompleter._chunkSubscription` | Dispose'da `onData(null)` + `cancel()` + `null` ([L1183](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_stream.dart#L1183)) | [painting/image_stream.dart#L1037](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_stream.dart#L1037) |
| `consolidateHttpClientResponseBytes` | `late final` subscription, callback hata verince `subscription.cancel()`; `cancelOnError: true` ([L98](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/consolidate_response.dart#L98)) | [foundation/consolidate_response.dart#L78](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/consolidate_response.dart#L78) |
| `SynchronousFuture.asStream` | Dinleyiciden önce `add` + `close`: tek olaylık stream için controller buffer'ına güvenilen nadir durum | [foundation/synchronous_future.dart#L32](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/synchronous_future.dart#L32) |

Not: `packages/flutter/lib` içinde `async*` ve `asBroadcastStream` kullanımı yok
(grep 0 sonuç).

## Lint'ler

| Lint | Set | Ne yapar |
|---|---|---|
| [cancel_subscriptions](https://dart.dev/tools/linter-rules/cancel_subscriptions) | hiçbiri (opsiyonel) | `StreamSubscription` alanlarının/değişkenlerinin cancel edilmesini ister |
| [close_sinks](https://dart.dev/tools/linter-rules/close_sinks) | hiçbiri (opsiyonel) | `Sink` (ör. `StreamController`) örneklerinin kapatılmasını ister |
| [unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures) | hiçbiri (opsiyonel) | `async` gövdede `cancel()`/`close()` gibi future'ların `await` edilmesini ya da `unawaited` ile işaretlenmesini ister |

Üçü de `package:lints` core/recommended'da **yok**; stream kullanan paketlerde
`analysis_options.yaml`'a elle ekle.

## Kontrol listesi

- [ ] Tek değer mi? → `Future<Result<T>>`, stream değil.
- [ ] Kaynak başka stream/future'dan mı türüyor? → `async*` veya `map`/`where`; controller gereksiz.
- [ ] `StreamController` işi `onListen`'de başlatıyor, dinleyiciden önce üretmiyor.
- [ ] Single-subscription controller'da `onPause`/`onResume`/`onCancel` üretimi durduruyor/sürdürüyor.
- [ ] Birden çok dinleyici gerekiyorsa broadcast (veya `asBroadcastStream`); ikinci `listen` `StateError` vermez.
- [ ] Repository hatayı `Err` olayına çeviriyor; domain'e ham exception sızmıyor.
- [ ] State sınıfı subscription'ı alanda tutuyor, `dispose()`'da `await cancel()` + `null`.
- [ ] Controller'ın sahibi `close()` çağırıyor; `StreamController(sync: true)` kullanılmıyor (dokümana göre "avoid").
- [ ] `fromHandlers` transformer'ı stateless.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: İptalde temizlenen `async*` üretici
- **Demo promptu:** "Sıcaklık sensörünü periyodik okuyan, tüketici `take` ile erken durunca sensörü `finally` içinde kapatan bir `async*` stream yaz."
- **Model:** [`examples/lib/07_streams/endless_ids.dart`](../../../examples/lib/07_streams/endless_ids.dart)
- **Katman:** Data
- **Adımlar:** 1. Controller kullanmadan `async*` fonksiyon yaz. 2. Üretim döngüsünü `try`'a, kaynak bırakmayı `finally`'ye koy. 3. Her değeri `yield` ile ver; başka bir stream'in tüm olaylarını iletmek gerekirse `yield*` kullan. 4. Kaynak açma/bırakma için callback parametresi al ki test gözleyebilsin.
- **Kabul kriteri:** `take(n)` sonrası `finally` bir kez çalıştı ve iptalden sonra yeni değer üretilmedi.
- **Min. sürüm:** Dart 3 SDK alt sınırı (`async*` için sürüm notu yok).

### Tarif: Pause'a saygılı `StreamController`
- **Demo promptu:** "Büyük bir CSV dosyasının satırlarını üreten, dinleyici pause edince üretimi durdurup resume'da kaldığı yerden süren bir stream yaz."
- **Model:** [`examples/lib/07_streams/pausable_counter.dart`](../../../examples/lib/07_streams/pausable_counter.dart)
- **Katman:** Data
- **Adımlar:** 1. Single-subscription `StreamController` oluştur; dört callback'i (`onListen`, `onPause`, `onResume`, `onCancel`) bağla. 2. Üretimi yalnız `onListen`'de başlat. 3. Her değeri ayrı event-loop turunda üret ve üretmeden önce "çalışıyor mu" bayrağına bak (erken `return`). 4. Kaynak bitince bayrağı indir ve `close()` çağır. 5. Olay sırasını test için bir log callback'iyle dışarı ver.
- **Kabul kriteri:** Dinleyici yokken hiçbir şey üretilmedi; pause edilen değerden sonra resume'a kadar yeni değer üretilmedi; `cancel()` `onCancel`'ı tetikledi.
- **Min. sürüm:** Dart 3 SDK alt sınırı.

### Tarif: Broadcast olay yayını
- **Demo promptu:** "Sepet değişikliklerini birden çok ekrana aynı anda yayan bir `CartEvents` sınıfı yaz."
- **Model:** [`examples/lib/07_streams/broadcast_stream.dart`](../../../examples/lib/07_streams/broadcast_stream.dart)
- **Katman:** Data / state sınıfı
- **Adımlar:** 1. Sınıf içinde `StreamController.broadcast()` tut. 2. Dışarıya yalnız `Stream` getter'ı ver, controller'ı açma. 3. Olay eklemek için anlamlı isimli bir metot yaz. 4. `close()` metodu ekle.
- **Kabul kriteri:** İki dinleyici aynı olayı aldı; dinleyici yokken eklenen olay kimseye ulaşmadı; `isBroadcast` `true`.
- **Min. sürüm:** Dart 3 SDK alt sınırı.

### Tarif: Stateless `StreamTransformer`
- **Demo promptu:** "Gelen sohbet mesajlarının baştaki/sondaki boşluklarını kırpıp boş mesajları atan bir `StreamTransformer` yaz."
- **Model:** [`examples/lib/07_streams/trim_frames_transformer.dart`](../../../examples/lib/07_streams/trim_frames_transformer.dart)
- **Katman:** Data
- **Adımlar:** 1. `StreamTransformer.fromHandlers` ile top-level `final` tanımla. 2. `handleData` içinde state tutma; yalnız girdiyi işle. 3. Koşulu sağlamayan olayı `sink`'e ekleme. 4. Stream başına state gerekirse `fromBind`'a geç.
- **Kabul kriteri:** `transform()` sonrası stream beklenen olayları sırayla verip kapandı; boş olay düşürüldü.
- **Min. sürüm:** Dart 3 SDK alt sınırı.

### Tarif: Gerçek zamanlı akış `Stream<Result<T>>` (DataSource → Repository → UseCase)
- **Demo promptu:** "Kargo takibinde WebSocket benzeri kaynaktan gelen konum güncellemelerini `Stream<Result<ShipmentLocation>>` olarak domain'e taşıyan katmanları kur."
- **Model:** [`examples/lib/07_streams/price_repository_impl.dart`](../../../examples/lib/07_streams/price_repository_impl.dart) (kaynak: [`examples/lib/07_streams/price_socket.dart`](../../../examples/lib/07_streams/price_socket.dart), domain: [`examples/lib/07_streams/price_domain.dart`](../../../examples/lib/07_streams/price_domain.dart))
- **Katman:** Domain / Data
- **Adımlar:** 1. Domain'de entity, `abstract interface` repository ve `Stream<Result<T>> call(...)` dönen `final class` use case yaz. 2. DataSource'ta broadcast controller'ın `onListen`'inde bağlantıyı aç, `onCancel`'ında kapat. 3. RepositoryImpl'de frame'i `map` ile `Result<T>`'ye çevir; parse hatasını `Err` olayı yap, stream'i bitirme. 4. Filtre ve decode'u switch expression kullanan küçük private yardımcılara böl.
- **Kabul kriteri:** Bozuk frame `Err` olayı oldu ve sonraki geçerli frame yine geldi; ilk dinleyicide bağlantı açıldı, son dinleyici gidince kapandı.
- **Min. sürüm:** 3.0 (`sealed` `Result` + switch pattern).

### Tarif: Stream dinleyen state sınıfı
- **Demo promptu:** "Kargo konum akışını dinleyip son konumu ve son hatayı tutan, `dispose()`'da aboneliği iptal eden düz Dart bir state sınıfı yaz."
- **Model:** [`examples/lib/07_streams/price_ticker_notifier.dart`](../../../examples/lib/07_streams/price_ticker_notifier.dart)
- **Katman:** state sınıfı
- **Adımlar:** 1. Use case'i constructor'dan al. 2. `start()`'ta `listen` et, `StreamSubscription`'ı alanda sakla (`??=` ile çift abonelik yok). 3. `Result`'ı switch expression ile işleyen private handler metodu yaz. 4. `dispose()`'da `await cancel()` ve alanı `null` yap.
- **Kabul kriteri:** `dispose()` sonrası kaynağın `onCancel`'ı çalıştı (bağlantı kapandı) ve sonra gelen olay state'i değiştirmedi.
- **Min. sürüm:** 3.0 (switch pattern).

### Tarif: `sealed` olay akışı
- **Demo promptu:** "Dosya yükleme chunk'larını `sealed UploadEvent` (ilerleme, tamamlandı, başarısız) olaylarına çeviren bir `async*` fonksiyon yaz."
- **Model:** [`examples/lib/07_streams/practice/ex3_download_events.dart`](../../../examples/lib/07_streams/practice/ex3_download_events.dart)
- **Katman:** Domain / Data
- **Adımlar:** 1. `sealed` olay tabanı ve `final class` alt tiplerini yaz. 2. Girdi stream'ini `try` içinde `await for` ile dolaş, her olayı `yield` et. 3. Döngü bitince tamamlanma olayını ver. 4. `catch` içinde hatayı son veri olayına çevir. 5. Olayı metne çeviren `default`'suz exhaustive switch expression yaz.
- **Kabul kriteri:** Kaynak hata verince çıktı hata olayı değil son olay olarak "başarısız" verip kapandı; hatadan sonraki chunk işlenmedi.
- **Min. sürüm:** 3.0 (`sealed`, switch expression).

## Pekiştirme

### Alıştırma 1 · Sayfalı `async*` okuma, erken durunca dur (kolay)
`Stream<int> pagedIds(fetchPage, {onReleased})` yaz: `fetchPage(0)`, `fetchPage(1)`, … ile
sayfaları sırayla çeker, her id'yi `yield` eder, boş sayfa gelince biter. Tüketici
`take(3)` ile erken durursa **bir sonraki sayfa hiç istenmemeli** ve `finally` içindeki
`onReleased` bir kez çalışmalı. Controller kullanma.

**İpucu:** "StreamController yaşam döngüsü ve backpressure" bölümündeki `endlessIds` örneğine ve [creating a stream from scratch](https://dart.dev/libraries/async/creating-streams#creating-a-stream-from-scratch) notuna bak: iptalden sonra bir sonraki `yield` `return` gibi davranır.

<details><summary>Çözüm</summary>

<!-- snippet: 07_streams/practice/ex1_paged_ids -->
```dart
/// An early stop (`take`, `cancel()`) fetches no further page.
Stream<int> pagedIds(
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

</details>

### Alıştırma 2 · Sembol değiştiren state sınıfı (orta)
`InMemoryPriceSocket` → `PriceRepositoryImpl` → `WatchPrices` zincirini kullanan düz Dart bir
`SymbolWatcher` yaz: `watch(symbol)` önceki aboneliği `await cancel()` ile bırakıp yenisini
açar, `latestPrice`/`lastFailure` alanlarını `Result` üzerinden exhaustive `switch` ile
günceller, `dispose()` aboneliği kapatır. Beklenen: sembol değişince eski sembolün
frame'leri state'i değiştirmez, bozuk frame `lastFailure` olur ama akış sürer,
`dispose()` sonrası socket'in `isConnected`'ı `false` olur.

**İpucu:** "Mimari: DataSource → Repository → UseCase → Notifier" bölümü: broadcast controller cancel sonrası yeniden dinlenebilir, son dinleyici gidince `onCancel` çalışır.

<details><summary>Çözüm</summary>

<!-- snippet: 07_streams/practice/ex2_symbol_watcher -->
```dart
import 'dart:async';

import '../../00_architecture/result.dart';
import '../price_domain.dart';

final class SymbolWatcher {
  SymbolWatcher(this._watchPrices);
  final WatchPrices _watchPrices;

  StreamSubscription<Result<PriceTick>>? _subscription;

  String? symbol;
  double? latestPrice;
  Failure? lastFailure;

  /// Cancels the previous subscription first: old frames cannot leak in.
  Future<void> watch(String newSymbol) async {
    await _subscription?.cancel();
    symbol = newSymbol;
    latestPrice = null;
    lastFailure = null;
    _subscription = _watchPrices(newSymbol).listen(_onResult);
  }

  void _onResult(Result<PriceTick> result) => switch (result) {
    Ok(:final value) => _showPrice(value.price),
    Err(:final failure) => _showFailure(failure),
  };

  void _showPrice(double price) {
    latestPrice = price;
  }

  void _showFailure(Failure failure) {
    lastFailure = failure;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
```

</details>

### Alıştırma 3 · İndirme olayları: stream + `sealed` (zor)
[03](03-class-modifiers.md)'teki `sealed` hiyerarşiyi stream ile birleştir: `DownloadEvent`
(`DownloadProgress`, `DownloadDone`, `DownloadFailed`) tanımla ve `Stream<List<int>>`
chunk'larını bu olaylara çeviren bir `async*` `trackDownload` yaz. Kaynak hata verirse
çıktı stream'i **hata olayı değil**, son olay olarak `DownloadFailed` üretip kapanmalı;
hatadan sonra kaynağa eklenen chunk işlenmemeli. Olayı metne çeviren fonksiyon `default`
kolu olmadan exhaustive `switch` kullanmalı.

**İpucu:** [error events](https://dart.dev/libraries/async/using-streams#error-events): hata `await for` döngüsünden fırlatılır ve döngüyü bitirir; `try-catch` ile yakalayıp `yield` edebilirsin.

<details><summary>Çözüm</summary>

<!-- snippet: 07_streams/practice/ex3_download_events -->
```dart
sealed class DownloadEvent {
  const DownloadEvent();
}

final class DownloadProgress extends DownloadEvent {
  const DownloadProgress(this.received, this.total);
  final int received;
  final int total;
}

final class DownloadDone extends DownloadEvent {
  const DownloadDone(this.bytes);
  final int bytes;
}

final class DownloadFailed extends DownloadEvent {
  const DownloadFailed(this.error);
  final Object error;
}

/// A source error becomes a final `DownloadFailed` data event.
Stream<DownloadEvent> trackDownload(Stream<List<int>> chunks, {required int total}) async* {
  var received = 0;
  try {
    await for (final chunk in chunks) {
      received += chunk.length;
      yield DownloadProgress(received, total);
    }
    yield DownloadDone(received);
  } catch (error) {
    yield DownloadFailed(error);
  }
}

String describeDownload(DownloadEvent event) => switch (event) {
  DownloadProgress(:final received, :final total) => '$received/$total',
  DownloadDone(:final bytes) => 'done $bytes',
  DownloadFailed() => 'failed',
};
```

</details>

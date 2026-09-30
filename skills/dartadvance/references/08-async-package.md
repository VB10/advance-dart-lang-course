# 08 · package:async — dart:async'i tamamlayan araçlar

> Kaynak: https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries ·
> https://dart.dev/libraries#multi-platform-libraries ·
> https://dart.dev/language/libraries#specifying-a-library-prefix ·
> https://dart.dev/language/libraries#importing-only-part-of-a-library
> API (pub.dev, **async 2.13.1**): [CancelableOperation](https://pub.dev/documentation/async/2.13.1/async/CancelableOperation-class.html),
> [CancelableCompleter](https://pub.dev/documentation/async/2.13.1/async/CancelableCompleter-class.html),
> [AsyncMemoizer](https://pub.dev/documentation/async/2.13.1/async/AsyncMemoizer-class.html),
> [AsyncCache](https://pub.dev/documentation/async/2.13.1/async/AsyncCache-class.html),
> [StreamQueue](https://pub.dev/documentation/async/2.13.1/async/StreamQueue-class.html),
> [StreamGroup](https://pub.dev/documentation/async/2.13.1/async/StreamGroup-class.html),
> [StreamSplitter](https://pub.dev/documentation/async/2.13.1/async/StreamSplitter-class.html),
> [LazyStream](https://pub.dev/documentation/async/2.13.1/async/LazyStream-class.html),
> [StreamCompleter](https://pub.dev/documentation/async/2.13.1/async/StreamCompleter-class.html),
> [StreamZip](https://pub.dev/documentation/async/2.13.1/async/StreamZip-class.html),
> [FutureGroup](https://pub.dev/documentation/async/2.13.1/async/FutureGroup-class.html),
> [RestartableTimer](https://pub.dev/documentation/async/2.13.1/async/RestartableTimer-class.html),
> [Result](https://pub.dev/documentation/async/2.13.1/async/Result-class.html)
> Min. sürüm: **package:async 2.12.0+ Dart 3.4 ister** (CHANGELOG); `CancelableOperation.fromValue`
> 2.11.0, `thenOperation` 2.10.0. Bu reference'taki diğer API'lerin hepsi 2.13.1'de mevcut.
> Örnekler dil olarak 3.0 (sealed, patterns) ister.

`package:async` bir Dart-team paketidir; dart.dev onu "Dart core kütüphanelerini
genişleten paketler" arasında sayar ("Expands on dart:async, adding utility classes to
work with asynchronous computations") ve kütüphane listesinde `dart:async` ile yan yana
verir. `Future`/`Stream` temelleri için bkz. [06](06-event-loop-future.md) ve
[07](07-streams.md); bu reference yalnızca onların **çözmediği** işleri anlatır:
iptal, tek-seferlik/TTL'li önbellek, pull-based stream okuma, stream birleştirme/çoğaltma.

Her API `~/.pub-cache/hosted/pub.dev/async-2.13.1/lib/src/` altındaki kaynaktan
doğrulandı (dosya adları aşağıdaki tabloda).

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| Eski isteğin sonucu yenisini ezmesin (search-as-you-type) → **`CancelableOperation`** (`cancelable_operation.dart`) | Sadece süre sınırı → `Future.timeout` ([06](06-event-loop-future.md)). Not: ikisi de alttaki işi **durdurmaz**; `timeout` kaynağı iptal etmez, `fromFuture` da sonucu yalnızca yok sayar |
| İş gerçekten durdurulabiliyorsa (timer, HTTP abort) → **`CancelableCompleter(onCancel: ...)`** | — |
| Pahalı async init'i bir kez çalıştırmak (index açma, `close()`) → **`AsyncMemoizer.runOnce`** (`async_memoizer.dart`) | Hata alınca tekrar denenmesi gerekiyorsa → memoizer **hatayı da sonsuza kadar saklar**; `AsyncCache.ephemeral()` veya kendi `Result`'lı mantığın |
| Değer X süre taze kalsın → **`AsyncCache(duration)`**; eşzamanlı çağrıları tek isteğe indirmek → **`AsyncCache.ephemeral()`** (`async_cache.dart`) | `fetchStream` → kaynakta `@Deprecated('Feature will be removed')`; kullanma |
| Stream'i sırayla, istek-istek okumak (protokol parse, test) → **`StreamQueue`** (`stream_queue.dart`) | Her olay aynı işlem → `await for` / `listen` ([07](07-streams.md)) |
| Birden çok kaynağı tek stream'de birleştirmek → **`StreamGroup.merge`** (`stream_group.dart`) | Kaynak zaten tek → gereksiz |
| Tek-abonelikli stream'i birden çok tüketiciye, **tüm olaylarla** vermek → **`StreamSplitter`** (`stream_splitter.dart`) | Geç gelen dinleyici eski olayları görmek zorunda değilse → `asBroadcastStream()` ([07](07-streams.md)); splitter her olayı **buffer'lar** |
| Stream'i dinleyici gelene kadar oluşturmamak → **`LazyStream`** (`lazy_stream.dart`) | `async*` zaten tembeldir ([07](07-streams.md)); `LazyStream` hazır bir fonksiyonu sarmak içindir |
| `Future<Stream<T>>` yerine düz `Stream<T>` döndürmek → **`StreamCompleter.fromFuture`** (`stream_completer.dart`) | — |
| N stream'in n. olaylarını eşlemek → **`StreamZip`** (`stream_zip.dart`) | — |
| Zamanla eklenen future'ları beklemek → **`FutureGroup`** (`future_group.dart`) | Hepsi baştan belli → `Future.wait` / record `.wait` ([06](06-event-loop-future.md)) |
| Debounce / inaktivite zaman aşımı → **`RestartableTimer.reset()`** (`restartable_timer.dart`) | Tek seferlik gecikme → düz `Timer` |
| — | Domain hata modeli → package:async'in `Result`'ı **değil**, bizim sealed `Result<T>` (aşağıda) |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Data / DataSource | İki gerçek zamanlı kaynak → `StreamGroup.merge`; iptal edilebilir iş → `CancelableCompleter` |
| Data / RepositoryImpl | Tek seferlik init → `AsyncMemoizer`; kısa ömürlü önbellek → `AsyncCache`; hata yine `Err`'e çevrilir |
| Domain / UseCase | **Değişmez**: `Future<Result<T>> call(...)`. package:async tipleri domain sözleşmesine sızmaz |
| Application / state sınıfı (düz Dart) | Yeni sorgu gelince eskisini `cancel()`; `valueOrCancellation()` `null` ise state'e dokunma |
| Test | `StreamQueue` ile olayları tek tek oku (`next`, `take`, `hasNext`) |

Domain'in `Future<Result<T>>` kalmasının bedeli: state sınıfındaki `fromFuture` iptali
**sonucu yok sayar**, alttaki isteği durdurmaz. İsteğin gerçekten iptali şartsa
(büyük indirme), `CancelableOperation` repository'den yukarı taşınmalıdır — bu bir
mimari tercihtir, varsayılan değil.

## Doğrulanmış örnekler

Tüm kod `examples/lib/08_async_package/` altında, her kavram ayrı dosyada (dosya adı =
snippet id; package:async import eden her dosya `hide Result` kuralına uyar); testleri
`examples/test/08_async_package/` altında
(`dart run dartadvance_tool:dartadvance verify 08_async_package`).

### İsim çakışması: iki `Result`

`package:async/async.dart` kendi `Result` sınıfını export eder (`src/result/result.dart`).
Bizim `00_architecture/result.dart` ile birlikte import edilip `Result` kullanılırsa
derleme hatası: **`ambiguous_import`** ("The name 'Result' is defined in the libraries …
Try using 'as prefix' … or hiding the name"). Çözüm dart.dev'in iki aracı:
[`hide`](https://dart.dev/language/libraries#importing-only-part-of-a-library) ve
[prefix](https://dart.dev/language/libraries#specifying-a-library-prefix) (bkz.
[04](04-libraries-metadata.md)). Kural: **domain `Result` çıplak adı alır**, package:async'inki
`hide` edilir; statik yardımcıları gerekiyorsa prefix'le alınır. Üç import satırının
tamamı aşağıdaki `result_to_domain.dart`'ın başında görünür.

İki tip farklı iş yapar. package:async'in `Result`'ı **`abstract class`** (sealed değil),
iki implementasyonu var: `ValueResult<T>` ve `ErrorResult` (`error` + `stackTrace`,
`implements Result<Never>`). "Bir future'ın sonucunu (değer ya da hata) değer olarak yakala"
aracıdır: `Result.capture` asla hata vermeyen bir future döner, `Result.release` tersini yapar.

<!-- snippet: 08_async_package/result_capture -->
```dart
import 'package:async/async.dart' as async_pkg show Result;

Future<async_pkg.Result<int>> captureCount(Future<int> request) =>
    async_pkg.Result.capture(request);

Future<int> releaseCount(Future<async_pkg.Result<int>> captured) =>
    async_pkg.Result.release(captured);
```

Domain'de yine kendi sealed `Result<T>`'miz kullanılır: `Err` tipli, sealed bir `Failure`
taşır (`Object error` değil) ve `switch` **exhaustive**'dir. package:async'in `Result`'ı
sealed olmadığından aşağıdaki `switch` fallback kolu olmadan derlenmez; domain `Result`'ı
fallback istemez — domain'in kendi tipini tutmasının sebebi bu exhaustiveness ve `Object error`
yerine tipli `Failure`. Sınırda (data → domain) bir kez çevir:

<!-- snippet: 08_async_package/result_to_domain -->
```dart
import 'package:async/async.dart' hide Result;
import 'package:async/async.dart' as async_pkg show Result;

import '../00_architecture/result.dart';

Result<T> toDomain<T>(async_pkg.Result<T> captured) => switch (captured) {
  ValueResult<T>(:final value) => Ok(value),
  ErrorResult(:final error, :final stackTrace) => Err(UnexpectedFailure(error, stackTrace)),
  // package:async's Result is not sealed, so a fallback arm is required.
  _ => throw StateError('Unknown Result implementation: $captured'),
};
```

### CancelableOperation: sonucu iptal etmek

Düz bir `Future` iptal edilemez (12'deki `timeout` notu: kaynak future sonradan yine
tamamlanır). `CancelableOperation.fromFuture`: `cancel()` sonrası `value` **hiç**
tamamlanmaz, gelen sonuç atılır; `onCancel` en fazla bir kez, senkron çağrılır ve döndürdüğü
future `cancel()`'ın sonucudur. `valueOrCancellation()` iki durumda da tamamlanır (iptalde
verilen varsayılanla). Tamamlanmış operasyonda `cancel()` hiçbir şey yapmaz
(`isCanceled` false kalır) — testte doğrulandı.

<!-- snippet: 08_async_package/cancelable_from_future -->
```dart
import 'package:async/async.dart' hide Result;

/// Cancelling discards the result; the request itself keeps running.
CancelableOperation<String> fetchCancelable(Future<String> request, {void Function()? onCancel}) =>
    CancelableOperation.fromFuture(request, onCancel: onCancel);

Future<String> describe(CancelableOperation<String> operation) async {
  final value = await operation.valueOrCancellation();
  return value ?? 'cancelled';
}
```

İşi gerçekten durdurmak için completer'ın sahibi ol; `onCancel` yalnızca iş bitmeden
iptal edilirse çalışır:

<!-- snippet: 08_async_package/cancelable_completer -->
```dart
import 'dart:async';

import 'package:async/async.dart' hide Result;

CancelableOperation<int> slowSquare(int n, {required Duration delay}) {
  late final Timer timer;
  final completer = CancelableCompleter<int>(onCancel: () => timer.cancel());
  timer = Timer(delay, () => completer.complete(n * n));
  return completer.operation;
}
```

### AsyncMemoizer ve AsyncCache

`runOnce` ilk çağrıda hesaplamayı başlatır; `hasRun` o anda `true` olur (sonuç gelmeden).
Eşzamanlı ve sonraki çağrılar aynı future'ı alır. **Hata da memoize edilir** — test:
ikinci çağrı yükleyiciyi tekrar çalıştırmaz.

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

`AsyncCache(duration)`: süre, `fetch`'in future'ı **tamamlandıktan sonra** başlar;
`invalidate()` erken temizler. Future'ı sakladığı için başarısız fetch de TTL boyunca
saklanır (testte doğrulandı). `AsyncCache.ephemeral()` yalnızca **uçuştaki** çağrıları
birleştirir; tamamlanınca (değer ya da hata) bir sonraki çağrı yeniden çalışır — token
yenileme gibi "aynı anda iki kez yapma" işleri için (`TokenRefresher`). Kaynak, zamanlamanın
[`fake_async`](https://pub.dev/packages/fake_async) ile taklit edilebileceğini söyler;
testlerimiz bunun yerine `Duration.zero` + `pumpEventQueue()` kullanır.

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

<!-- snippet: 08_async_package/async_cache_ephemeral -->
```dart
import 'package:async/async.dart' hide Result;

/// Shares only in-flight calls; the next call after completion fetches again.
final class TokenRefresher {
  TokenRefresher(this._refresh);
  final Future<String> Function() _refresh;
  final _inFlight = AsyncCache<String>.ephemeral();

  Future<String> refresh() => _inFlight.fetch(_refresh);
}
```

### StreamQueue: pull-based okuma

Stream'i "bir olay ver", "üç olay ver" diye okumayı sağlar; `StreamIterator`'dan daha
rahat (dokümanı: `take`/`skip` ile grup halinde istenebilir, `rest` kalanı stream olarak
verir). İş bitince `cancel()` ile kaynağın aboneliği bırakılır.

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

Testte doğrulanan davranışlar: `peek` tüketmez; `rest` kuyruğu kapatır (sonra `next` →
`StateError`); stream erken biterse `next` `StateError` ile tamamlanır, önce `hasNext`
ile kontrol edilebilir. **Dikkat:** kuyruk, bekleyen istek yokken kaynağı **pause** eder
(sınıf dokümanı). Bu yüzden bir testte `await controller.close()` takılır: done olayı
bir sonraki isteğe kadar bekler. `unawaited(controller.close())` kullan.

### StreamGroup.merge

`merge` = gruba ekle + `close()` + `stream`. Sonuç single-subscription'dır; iptal ve pause
tüm kaynaklara iletilir; stream **tüm** kaynaklar kapanınca kapanır. Broadcast kaynaklardaki
olaylar, grup stream'i dinlenene kadar **düşer** (sınıf dokümanı).

<!-- snippet: 08_async_package/stream_group_merge -->
```dart
import 'package:async/async.dart' hide Result;

Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]);
```

### StreamSplitter, LazyStream, StreamCompleter, StreamZip

`StreamSplitter.splitFrom`: bir stream'in N single-subscription kopyası. `asBroadcastStream`'den
([07](07-streams.md)) farkı: her dal, geç dinlemeye başlasa bile **her** olayı alır.

<!-- snippet: 08_async_package/stream_splitter -->
```dart
import 'package:async/async.dart' hide Result;

Future<(int count, int sum)> countAndSum(Stream<int> source) async {
  final [forCount, forSum] = StreamSplitter.splitFrom(source);
  return (forCount.length, forSum.fold(0, (a, b) => a + b)).wait;
}
```

Testte: splitter'dan geç açılan dal `[1, 2, 3]`'ü yine alır; `asBroadcastStream()`'de
ikinci `toList()` boş döner. Splitter, `close()` çağrılana kadar her olayı bellekte tutar.

`LazyStream`: fabrika fonksiyonu fonksiyon çağrılınca değil, biri **dinleyince** çalışır (testte
dinlemeden önce `opened == 0`).

<!-- snippet: 08_async_package/lazy_stream -->
```dart
import 'package:async/async.dart' hide Result;

Stream<String> lazyLogLines(Stream<String> Function() openLog) => LazyStream(openLog);
```

`StreamCompleter` dokümanı: "genelde `Future<Stream>` oluşturmayın" — hazır olana kadar
olay üretmeyen bir stream döndürün. `fromFuture` future hata verirse stream'e tek bir
hata olayı koyar.

<!-- snippet: 08_async_package/stream_completer -->
```dart
import 'package:async/async.dart' hide Result;

Stream<int> ticksAfterConnect(Future<Stream<int>> connect) => StreamCompleter.fromFuture(connect);
```

`StreamZip`: her stream'in n. olayını bir listede eşler; **en kısa** stream bitince biter.

<!-- snippet: 08_async_package/stream_zip -->
```dart
import 'package:async/async.dart' hide Result;

Stream<String> labelled(Stream<String> names, Stream<int> scores) =>
    StreamZip<Object>([names, scores]).map((pair) => '${pair[0]}=${pair[1]}');
```

### FutureGroup ve RestartableTimer

`FutureGroup` dokümanı: `Future.wait` + `eagerError: true` gibidir, fakat future'lar
zamanla eklenir. `future`, `close()` **ve** eklenen tüm future'lar tamamlanınca tamamlanır; değerler ekleme
sırasını korur. Bir future hata verirse `future` o hatayla tamamlanır ve grup kapanır.

<!-- snippet: 08_async_package/future_group -->
```dart
import 'package:async/async.dart' hide Result;

/// Completes after `close()` and every added future; keeps insertion order.
Future<List<int>> uploadAll(Stream<Future<int>> uploads) async {
  final group = FutureGroup<int>();
  await for (final upload in uploads) {
    group.add(upload);
  }
  group.close();
  return group.future;
}
```

`RestartableTimer.reset()` "ateşlenmiş veya iptal edilmiş olsa bile" geri sayımı baştan
başlatır; bu yüzden callback birden çok kez çalışabilir (debounce / inaktivite zaman aşımı).
Örnekte timer oluşturulur oluşturulmaz `cancel()` edilir: ilk `ping`'e kadar boşta durur.
Aynı turda üç `ping` → tek çağrı (testte).

<!-- snippet: 08_async_package/restartable_timer -->
```dart
import 'package:async/async.dart' hide Result;

final class Debouncer {
  Debouncer(Duration wait, void Function() action) : _timer = RestartableTimer(wait, action) {
    _timer.cancel(); // idle until the first `ping`
  }
  final RestartableTimer _timer;

  /// Restarts the full countdown, even after the timer fired.
  void ping() => _timer.reset();

  void dispose() => _timer.cancel();
}
```

### Mimari: Domain

Domain package:async'ten habersiz; sözleşme `Future<Result<T>>`:

<!-- snippet: 08_async_package/product_domain -->
```dart
import '../00_architecture/result.dart';

final class Product {
  const Product({required this.id, required this.name});
  final int id;
  final String name;
}

abstract interface class ProductRepository {
  Future<Result<List<Product>>> search(String query);
}

final class SearchProducts {
  const SearchProducts(this._repository);
  final ProductRepository _repository;

  Future<Result<List<Product>>> call(String query) => _repository.search(query);
}
```

### Data: RepositoryImpl — init bir kez (`AsyncMemoizer`)

Eşzamanlı ilk iki arama tek `openIndex()` çağrısını paylaşır (testte `openCalls == 1`).
`openIndex` hata verirse bu repository kalıcı olarak `Err` döner — memoizer hatayı saklar;
tekrar deneme gerekiyorsa `AsyncCache.ephemeral()` seç.

<!-- snippet: 08_async_package/product_repository_impl -->
```dart
import 'package:async/async.dart' hide Result;

import '../00_architecture/result.dart';
import 'product_domain.dart';

typedef Json = Map<String, Object?>;

abstract interface class ProductLocalDataSource {
  Future<void> openIndex();
  Future<List<Json>> query(String text);
}

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._local);
  final ProductLocalDataSource _local;
  final _indexReady = AsyncMemoizer<void>();

  @override
  Future<Result<List<Product>>> search(String query) async {
    try {
      await _indexReady.runOnce(_local.openIndex);
      final rows = await _local.query(query);
      return Ok(rows.map(_toProduct).nonNulls.toList());
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }

  static Product? _toProduct(Json row) => switch (row) {
    {'id': final int id, 'name': final String name} => Product(id: id, name: name),
    _ => null,
  };
}
```

### Data: DataSource — iki gerçek zamanlı kaynak (`StreamGroup.merge`)

Testte olaylar `StreamQueue` ile tek tek okunur; kuyruk `cancel()` edilince iki
controller'ın `onCancel`'ı da çalışır.

<!-- snippet: 08_async_package/inbox_data_source -->
```dart
import 'package:async/async.dart' hide Result;

/// Listening to [watch] listens to both sources; cancelling cancels both.
final class InboxDataSource {
  const InboxDataSource({required this.push, required this.localEdits});
  final Stream<Map<String, Object?>> push;
  final Stream<Map<String, Object?>> localEdits;

  Stream<Map<String, Object?>> watch() => StreamGroup.merge([push, localEdits]);
}
```

### Application: state sınıfı — son sorgu kazanır (`CancelableOperation`)

Önemli ayrıntı: yeni operasyon **ilk `await`'ten önce** `_pending`'e yazılır. Önce
`await _pending?.cancel()` yazılırsa, arka arkaya iki çağrıda ikincisi `_pending`'i hâlâ
`null` görür ve eski istek iptal edilmez — bu sürümle test gerçekten başarısız oldu
(eski `'ph'` sonucu `'phone'`'u ezdi). Test: yeni istek önce, eski istek sonra tamamlanır;
state `'phone'` kalır. `valueOrCancellation()` `null` dönerse operasyon daha yeni bir sorgu
tarafından iptal edilmiştir: state'e dokunulmaz.

<!-- snippet: 08_async_package/search_state -->
```dart
import '../00_architecture/result.dart';
import 'product_domain.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading(this.query);
  final String query;
}

final class SearchLoaded extends SearchState {
  const SearchLoaded(this.query, this.products);
  final String query;
  final List<Product> products;
}

final class SearchFailed extends SearchState {
  const SearchFailed(this.failure);
  final Failure failure;
}
```

<!-- snippet: 08_async_package/search_notifier -->
```dart
import 'package:async/async.dart' hide Result;

import '../00_architecture/result.dart';
import 'product_domain.dart';
import 'search_state.dart';

/// Every new query cancels the previous one: a stale response never lands.
final class SearchNotifier {
  SearchNotifier(this._searchProducts);
  final SearchProducts _searchProducts;

  CancelableOperation<Result<List<Product>>>? _pending;
  SearchState state = const SearchIdle();

  Future<void> onQueryChanged(String query) async {
    final previous = _pending;
    // Swapped before the first `await`, so a second call sees this one.
    final operation = _pending = CancelableOperation.fromFuture(_searchProducts(query));
    state = SearchLoading(query);
    await previous?.cancel();

    final result = await operation.valueOrCancellation();
    if (result == null) return;
    state = switch (result) {
      Ok(:final value) => SearchLoaded(query, value),
      Err(:final failure) => SearchFailed(failure),
    };
  }

  Future<void> dispose() async {
    await _pending?.cancel();
  }
}
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde **package:async kullanılmıyor**:
`^import 'package:async/` → **0**, `package:async` → **0**,
`RestartableTimer|CancelableOperation|AsyncMemoizer` → **0**
(`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`).
Framework aynı fikirleri **elle** yazar. Aşağıdakiler package:async kullanımı **değil**,
"aynı fikir, elle yazılmış" örnekleridir:

| Sembol | Aynı fikir (package:async karşılığı) | Kaynak |
|---|---|---|
| `_RawAutocompleteState._onChangedCallId` | Her metin değişikliğinde sayaç artar; `await optionsBuilder(...)` dönünce `callId != _onChangedCallId` ise sonuç atılır ([L498](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/autocomplete.dart#L498)). Search-as-you-type, son sorgu kazanır (`CancelableOperation` + `valueOrCancellation`) | [widgets/autocomplete.dart#L473](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/autocomplete.dart#L473) |
| `_FutureBuilderState._activeCallbackIdentity` | Her abonelikte yeni `Object()` kimliği; callback yalnızca kimlik hâlâ aktifse `setState` çağırır ([L642](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L642)); future değişince/dispose'da kimlik `null`. Future'ı durdurmaz, sonucu yok sayar (`CancelableOperation.fromFuture`) | [widgets/async.dart#L599](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L599) |
| `Listenable.merge` → `_MergingListenable` | Birden çok `Listenable`'ı tek `Listenable` yapar; `addListener`/`removeListener` her çocuğa iletilir ([L495](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L495)). Stream yerine listenable için `StreamGroup.merge` | [foundation/change_notifier.dart#L74](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L74) |
| `SchedulerBinding.endOfFrame` | `_nextFrameCompleter == null` ise yeni completer, değilse **aynı** future; frame bitince `null`'a döner. Uçuştaki işi paylaşıp tamamlanınca unutmak (`AsyncCache.ephemeral`) | [scheduler/binding.dart#L848](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L848) |
| `ImageCache.putIfAbsent` → `_pendingImages[key]` | Aynı anahtar için yükleme sürüyorsa yeni yükleme başlatılmaz, bekleyen completer döner. Anahtar başına uçuştaki işi paylaşmak (`AsyncCache.ephemeral` fikri, anahtarlı) | [painting/image_cache.dart#L330](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_cache.dart#L330) |
| `RawScrollbarState._maybeStartFadeoutTimer` | `_fadeoutTimer?.cancel()` + yeni `Timer(widget.timeToFade, ...)`: her çağrıda geri sayımı baştan başlatma (`RestartableTimer.reset`) | [widgets/scrollbar.dart#L1613](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/scrollbar.dart#L1613) |

Flutter uygulamasında bu paketleri kullanmak serbesttir (saf Dart); framework'ün
kullanmaması bağımlılık politikasıdır, API'lere dair bir uyarı değildir.

## Lint'ler

Hiçbiri `core`/`recommended` setinde değil (`lints` paketinin `core.yaml` /
`recommended.yaml` dosyalarında yok) — opsiyonel olarak açılır.

| Lint | Set | Ne yapar |
|---|---|---|
| [unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures) | hiçbiri (opsiyonel) | `async` gövdede `await` edilmeyen future'ı yakalar; `operation.cancel()` / `controller.close()` ya `await` ya `unawaited(...)` |
| [discarded_futures](https://dart.dev/tools/linter-rules/discarded_futures) | hiçbiri (opsiyonel) | `async` olmayan fonksiyonda (ör. senkron `dispose`) atılan `cancel()` future'ını yakalar |
| [cancel_subscriptions](https://dart.dev/tools/linter-rules/cancel_subscriptions) | hiçbiri (opsiyonel) | `StreamSubscription`'ların cancel edilmesini ister; `StreamQueue` için de `cancel()` unutma (kaynak aboneliği onda) |
| [close_sinks](https://dart.dev/tools/linter-rules/close_sinks) | hiçbiri (opsiyonel) | `dart:core` `Sink` örneklerinde `close` çağrılmasını ister. `FutureGroup` ve `StreamGroup` kaynakta `implements Sink<...>`, yani kuralın hedeflediği tiptedir; zaten `close()` edilmeden `future`/`stream` tamamlanmaz |
| [library_prefixes](https://dart.dev/tools/linter-rules/library_prefixes) | recommended | Prefix `lower_case_with_underscores` olmalı: `as async_pkg` |

## Kontrol listesi

- [ ] `package:async/async.dart` import eden dosyada domain `Result` de varsa → `hide Result` (statik yardımcılar için `as async_pkg show Result`).
- [ ] package:async'in `Result`'ı domain'e sızmıyor; sınırda `Ok`/`Err(Failure)`'a çevriliyor.
- [ ] Domain/UseCase sözleşmesi `Future<Result<T>>` / `Stream<Result<T>>` kalıyor.
- [ ] Son-sorgu-kazanır akışında yeni operasyon ilk `await`'ten **önce** alana yazılıyor; `valueOrCancellation()` `null` → state'e dokunma.
- [ ] `fromFuture` iptalinin alttaki işi durdurmadığı biliniyor; gerçek iptal gerekiyorsa `CancelableCompleter(onCancel: ...)`.
- [ ] `AsyncMemoizer`/`AsyncCache(duration)` hatayı da sakladığı için başarısız init/fetch'in etkisi düşünüldü.
- [ ] `AsyncCache.fetchStream` kullanılmıyor (deprecated).
- [ ] `StreamQueue` işi bitince `cancel()` ediliyor; testte `await controller.close()` yerine `unawaited(...)`.
- [ ] `StreamSplitter` ile büyük/sonsuz stream çoğaltılmıyor (her olay buffer'lanır) ya da `close()` çağrılıyor.
- [ ] `FutureGroup`/`StreamGroup` `close()` ediliyor.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.
Her tarif `package:async` bağımlılığı ister; domain `Result<T>` ile aynı dosyada `import 'package:async/async.dart' hide Result;` kuralı geçerlidir.

### Tarif: Son sorgu kazanır (`CancelableOperation.fromFuture`)
- **Demo promptu:** "Film arama kutusunda her yeni harfte önceki aramayı iptal eden, geç gelen eski sonucun yenisini ezmediği bir state sınıfı yaz."
- **Model:** [`examples/lib/08_async_package/search_notifier.dart`](../../../examples/lib/08_async_package/search_notifier.dart) (state'ler: [`examples/lib/08_async_package/search_state.dart`](../../../examples/lib/08_async_package/search_state.dart))
- **Katman:** state sınıfı
- **Adımlar:** 1. State'i `sealed` hiyerarşi olarak yaz (boşta, yükleniyor, yüklendi, hata). 2. Use case çağrısını `CancelableOperation.fromFuture` ile sar ve **ilk `await`'ten önce** alana yaz. 3. Önceki operasyonu `cancel()` et. 4. `valueOrCancellation()` `null` ise erken `return`; değilse `Result`'ı switch expression ile state'e çevir. 5. `dispose()`'da bekleyen operasyonu iptal et.
- **Kabul kriteri:** Yeni sorgunun cevabı önce, eski sorgunun cevabı sonra geldiğinde state yeni sorgunun sonucunda kaldı; `Err` hata state'ine dönüştü.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0 (`sealed`, switch expression).

### Tarif: Gerçekten durdurulan iş (`CancelableCompleter`)
- **Demo promptu:** "İptal edilince zamanlayıcısını durduran, süre dolunca rapor üreten iptal edilebilir bir işlem yaz."
- **Model:** [`examples/lib/08_async_package/cancelable_completer.dart`](../../../examples/lib/08_async_package/cancelable_completer.dart)
- **Katman:** Data
- **Adımlar:** 1. `CancelableCompleter` oluştur, `onCancel`'da alttaki işi (timer, istek) durdur. 2. İş bitince `complete` çağır. 3. Dışarıya yalnız `completer.operation` döndür.
- **Kabul kriteri:** Bitmeden iptal edilen operasyonda `isCanceled` `true`, `isCompleted` `false` (alttaki iş hiç tamamlamadı); iptal edilmeyen operasyon değeri verdi.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: Bir kez çalışan pahalı init (`AsyncMemoizer`)
- **Demo promptu:** "İlk sorguda yerel tarif veritabanını bir kez açan, eşzamanlı ilk sorgularda da tek açılış yapan bir `RecipeRepositoryImpl` yaz."
- **Model:** [`examples/lib/08_async_package/product_repository_impl.dart`](../../../examples/lib/08_async_package/product_repository_impl.dart)
- **Katman:** Data
- **Adımlar:** 1. Repository'de `AsyncMemoizer<void>` alanı tut. 2. Her çağrıda önce `runOnce(dataSource.open)` bekle. 3. Satırları switch expression'lı private yardımcıyla entity'ye çevir. 4. Hatayı `Err(UnexpectedFailure)` yap. 5. Init hatasının da kalıcı saklandığını bil; tekrar deneme gerekiyorsa `AsyncCache.ephemeral()` seç.
- **Kabul kriteri:** Eşzamanlı iki arama + bir sonraki arama sonunda açılış sayısı 1; veri kaynağı hatası `Err` oldu.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: TTL önbellek ve uçuştaki çağrıyı paylaşma (`AsyncCache`)
- **Demo promptu:** "Hava durumunu şehir başına 10 dakika önbellekleyen, hata alınca önbelleğe almayıp bir sonraki çağrıda yeniden deneyen bir repository yaz."
- **Model:** [`examples/lib/08_async_package/practice/ex2_cached_rate_repository.dart`](../../../examples/lib/08_async_package/practice/ex2_cached_rate_repository.dart) (yalnız uçuştaki çağrı: [`examples/lib/08_async_package/async_cache_ephemeral.dart`](../../../examples/lib/08_async_package/async_cache_ephemeral.dart))
- **Katman:** Data
- **Adımlar:** 1. Anahtar başına `AsyncCache(ttl)` tutan bir map kur (`??=`). 2. `fetch` sonucunu `Ok`'a sar. 3. Hata yakalanınca `invalidate()` çağır ve `Err` dön. 4. Süre yerine yalnız eşzamanlı çağrıları birleştirmek gerekiyorsa `AsyncCache.ephemeral()` kullan.
- **Kabul kriteri:** TTL içinde iki eşzamanlı + bir sonraki çağrı tek uzak istek yaptı; hatadan sonra TTL dolmadan gelen çağrı isteği yeniden yaptı.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: Çok kaynaklı stream (`StreamGroup.merge`, `StreamSplitter`, `StreamZip`)
- **Demo promptu:** "Not uygulamasında sunucu bildirimleri ile yerel taslak değişikliklerini tek akışta birleştiren bir `NotesDataSource` yaz."
- **Model:** [`examples/lib/08_async_package/inbox_data_source.dart`](../../../examples/lib/08_async_package/inbox_data_source.dart) (çoğaltma: [`examples/lib/08_async_package/stream_splitter.dart`](../../../examples/lib/08_async_package/stream_splitter.dart), eşleme: [`examples/lib/08_async_package/stream_zip.dart`](../../../examples/lib/08_async_package/stream_zip.dart))
- **Katman:** Data
- **Adımlar:** 1. Kaynak stream'leri constructor'dan al. 2. Birleştirmek için `StreamGroup.merge` döndür. 3. Bir stream'i her olayı alması gereken birden çok tüketiciye vermek gerekiyorsa `StreamSplitter.splitFrom` kullan (buffer'ladığını bil). 4. n. olayları eşlemek için `StreamZip` kullan. 5. Testte olayları `StreamQueue` ile tek tek oku.
- **Kabul kriteri:** Her iki kaynağın olayı sırayla okundu ve birleşik stream iptal edilince iki kaynağın da `onCancel`'ı çalıştı.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: Pull-based protokol okuma (`StreamQueue`)
- **Demo promptu:** "Seri port satır akışından önce başlık satırını, sonra başlıkta yazan sayıda ölçüm satırını okuyan bir fonksiyon yaz."
- **Model:** [`examples/lib/08_async_package/stream_queue.dart`](../../../examples/lib/08_async_package/stream_queue.dart) (sonlandırıcıya kadar: [`examples/lib/08_async_package/practice/ex1_read_until.dart`](../../../examples/lib/08_async_package/practice/ex1_read_until.dart))
- **Katman:** Data
- **Adımlar:** 1. Girdiyi `StreamQueue`'ya sar. 2. `next`, `take(n)` ile istek-istek oku; bitebilecek stream'de önce `hasNext` sor. 3. Okumayı `try` içinde yap, `finally`'de `await queue.cancel()` çağır. 4. Testte kaynak controller'ı `unawaited(controller.close())` ile kapat.
- **Kabul kriteri:** Başlıkta yazan kadar satır okundu, fazlası okunmadı; iş bitince kaynağın `onCancel`'ı çalıştı; erken biten stream'de `StateError` fırlamadı.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0 (liste pattern'i).

### Tarif: Hazır olmayan ya da tembel kaynak (`StreamCompleter`, `LazyStream`, `FutureGroup`)
- **Demo promptu:** "Bağlantı kurulduktan sonra mesaj akışını veren `connect()` future'ını, çağırana düz bir `Stream<Message>` olarak döndüren fonksiyon yaz."
- **Model:** [`examples/lib/08_async_package/stream_completer.dart`](../../../examples/lib/08_async_package/stream_completer.dart) (tembel açma: [`examples/lib/08_async_package/lazy_stream.dart`](../../../examples/lib/08_async_package/lazy_stream.dart), zamanla eklenen future'lar: [`examples/lib/08_async_package/future_group.dart`](../../../examples/lib/08_async_package/future_group.dart))
- **Katman:** Data
- **Adımlar:** 1. `Future<Stream<T>>` döndürme; `StreamCompleter.fromFuture` ile hemen bir `Stream<T>` ver. 2. Kaynak yalnız dinlenince açılmalıysa fabrikayı `LazyStream` ile sar. 3. Sayısı baştan belli olmayan future'ları `FutureGroup`'a ekle ve iş bitince `close()` çağır.
- **Kabul kriteri:** Future tamamlanmadan dinlenen stream olayları sonra aldı; başarısız future tek hata olayı oldu (LazyStream için: dinlemeden önce fabrika çağrılmadı).
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: Debounce (`RestartableTimer`)
- **Demo promptu:** "Kullanıcı yazmayı bıraktıktan 300 ms sonra taslağı kaydeden bir otomatik kaydetme sınıfı yaz."
- **Model:** [`examples/lib/08_async_package/restartable_timer.dart`](../../../examples/lib/08_async_package/restartable_timer.dart)
- **Katman:** state sınıfı
- **Adımlar:** 1. `RestartableTimer`'ı oluştur ve hemen `cancel()` et (ilk olaya kadar boşta). 2. Her olayda `reset()` çağır. 3. `dispose()`'da `cancel()` çağır.
- **Kabul kriteri:** Aynı turdaki üç olay tek kayıt tetikledi; kayıttan sonraki yeni olay tekrar tetikledi.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

### Tarif: package:async `Result` → domain `Result` sınırı
- **Demo promptu:** "Bir ödeme SDK'sının future'ını `Result.capture` ile yakalayıp domain `Result<PaymentReceipt>`'e çeviren sınır fonksiyonunu yaz."
- **Model:** [`examples/lib/08_async_package/result_to_domain.dart`](../../../examples/lib/08_async_package/result_to_domain.dart) (yakalama: [`examples/lib/08_async_package/result_capture.dart`](../../../examples/lib/08_async_package/result_capture.dart))
- **Katman:** Data
- **Adımlar:** 1. `package:async/async.dart`'ı `hide Result` ile, statik yardımcılar için ayrıca `as async_pkg show Result` ile import et. 2. `ValueResult` → `Ok`, `ErrorResult` → `Err(UnexpectedFailure)` eşleyen switch expression yaz. 3. package:async'in `Result`'ı sealed olmadığı için fallback kolu ekle. 4. package:async `Result`'ını domain'e sızdırma.
- **Kabul kriteri:** Değer `Ok` oldu; hata, orijinal hatayı taşıyan `Err(UnexpectedFailure)` oldu.
- **Min. sürüm:** package:async `^2.13.0` bağımlılığı (2.12+ Dart 3.4 ister); dil 3.0.

## Pekiştirme

### Alıştırma 1 · `StreamQueue` ile sonlandırıcıya kadar oku (kolay)
`Future<List<String>> readUntil(Stream<String> lines, String terminator)` yaz: satırları
`StreamQueue` ile tek tek çeker, `terminator`'a gelince durur (sonlandırıcı ve sonrası
sonuçta yok). Stream sonlandırıcı olmadan biterse `StateError` fırlatmadan o ana kadarki
satırları dönmeli. Her durumda kaynağın aboneliği bırakılmalı (kaynak controller'ın
`onCancel`'ı çalışır).

**İpucu:** "StreamQueue: pull-based okuma" bölümü: bitmiş kuyrukta `next` `StateError` verir, önce `hasNext`; iş bitince `cancel()`; testte `await controller.close()` yerine `unawaited(...)`.

<details><summary>Çözüm</summary>

<!-- snippet: 08_async_package/practice/ex1_read_until -->
```dart
import 'package:async/async.dart' hide Result;

/// Stops before [terminator]; a stream without one returns everything read.
Future<List<String>> readUntil(Stream<String> lines, String terminator) async {
  final queue = StreamQueue(lines);
  try {
    final body = <String>[];
    while (await queue.hasNext) {
      final line = await queue.next;
      if (line == terminator) break;
      body.add(line);
    }
    return body;
  } finally {
    await queue.cancel();
  }
}
```

</details>

### Alıştırma 2 · Hata önbelleklemeyen TTL'li repository (orta)
Domain sözleşmesi `Future<Result<double>> usdTo(String currency)` olan bir
`CachedRateRepository` yaz (Data katmanı). Para birimi başına `AsyncCache(ttl)` kullanır:
TTL içinde eşzamanlı ve sonraki çağrılar **tek** uzak isteği paylaşır. Uzak çağrı
hata verirse sonuç `Err(UnexpectedFailure)` olur ve bir sonraki çağrı — TTL dolmamış
olsa bile — isteği **yeniden** yapar. package:async'in `Result`'ı `hide` edilmeli.

**İpucu:** "AsyncMemoizer ve AsyncCache" bölümü: `AsyncCache` future'ı sakladığı için başarısız fetch de TTL boyunca saklanır; `invalidate()` girişi erken temizler.

<details><summary>Çözüm</summary>

<!-- snippet: 08_async_package/practice/ex2_cached_rate_repository -->
```dart
import 'package:async/async.dart' hide Result;

import '../../00_architecture/result.dart';

abstract interface class RateRepository {
  Future<Result<double>> usdTo(String currency);
}

abstract interface class RateRemoteDataSource {
  Future<double> fetchRate(String currency);
}

final class CachedRateRepository implements RateRepository {
  CachedRateRepository(this._remote, {required this.ttl});
  final RateRemoteDataSource _remote;
  final Duration ttl;
  final _caches = <String, AsyncCache<double>>{};

  @override
  Future<Result<double>> usdTo(String currency) async {
    final cache = _caches[currency] ??= AsyncCache(ttl);
    try {
      return Ok(await cache.fetch(() => _remote.fetchRate(currency)));
    } catch (error, stackTrace) {
      // AsyncCache stores the failed future: drop it so the next call retries.
      cache.invalidate();
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}
```

</details>

### Alıştırma 3 · Stream'den son sorgu kazanır (zor)
[07](07-streams.md)'deki `StreamController` yaşam döngüsünü `CancelableOperation` ile
birleştir: `Stream<R> latestResults<Q, R extends Object>(Stream<Q> queries,
CancelableOperation<R> Function(Q) run)` yaz. Her sorgu olayı yeni bir operasyon başlatır
ve öncekini iptal eder; yalnızca **en son** sorgunun sonucu yayınlanır, eski sonuç geç
gelse bile atılır. Çıktı `onListen`'den önce kaynağı dinlememeli; çıktı iptal edilince hem
kaynak abonelik hem bekleyen operasyon iptal edilmeli. Operasyon hatası hata olayı olarak
iletilmeli; kaynak bitip son operasyon tamamlanınca çıktı kapanmalı.

**İpucu:** "Application: state sınıfı — son sorgu kazanır" bölümü: yeni operasyonu ilk asenkron adımdan **önce** alana yaz, `valueOrCancellation()` `null` ise hiçbir şey yapma.

<details><summary>Çözüm</summary>

<!-- snippet: 08_async_package/practice/ex3_latest_results -->
```dart
import 'dart:async';

import 'package:async/async.dart' hide Result;

/// Emits only the result of the latest query ("switch map").
Stream<R> latestResults<Q, R extends Object>(
  Stream<Q> queries,
  CancelableOperation<R> Function(Q query) run,
) => _LatestResults(queries, run).output.stream;

final class _LatestResults<Q, R extends Object> {
  _LatestResults(this._queries, this._run) {
    output = StreamController<R>(
      onListen: _listen,
      onPause: () => _source?.pause(),
      onResume: () => _source?.resume(),
      onCancel: _cancel,
    );
  }
  final Stream<Q> _queries;
  final CancelableOperation<R> Function(Q query) _run;
  late final StreamController<R> output;
  StreamSubscription<Q>? _source;
  CancelableOperation<R>? _pending;
  var _sourceDone = false;

  void _listen() {
    _source = _queries.listen(_onQuery, onError: output.addError, onDone: _onSourceDone);
  }

  void _onQuery(Q query) {
    final previous = _pending;
    final operation = _pending = _run(query);
    unawaited(previous?.cancel());
    unawaited(_deliver(operation));
  }

  Future<void> _deliver(CancelableOperation<R> operation) async {
    try {
      final value = await operation.valueOrCancellation();
      if (value == null || !identical(_pending, operation)) return;
      _pending = null;
      output.add(value);
    } catch (error, stackTrace) {
      if (!identical(_pending, operation)) return;
      _pending = null;
      output.addError(error, stackTrace);
    }
    _closeIfIdle();
  }

  void _onSourceDone() {
    _sourceDone = true;
    _closeIfIdle();
  }

  void _closeIfIdle() {
    if (_sourceDone && _pending == null) unawaited(output.close());
  }

  Future<void> _cancel() async {
    await _source?.cancel();
    await _pending?.cancel();
  }
}
```

</details>

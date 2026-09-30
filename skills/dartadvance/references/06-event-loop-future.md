# 06 · Event loop ve Future

> Kaynak: https://dart.dev/language/concurrency#event-loop ·
> https://dart.dev/language/async#handling-futures ·
> https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await ·
> https://dart.dev/libraries/dart-async#future ·
> https://dart.dev/libraries/async/futures-error-handling#errors-in-the-middle-of-a-long-chain
> API: [scheduleMicrotask](https://api.dart.dev/stable/dart-async/scheduleMicrotask.html),
> [Future.wait](https://api.dart.dev/stable/dart-async/Future/wait.html),
> [FutureRecord2.wait](https://api.dart.dev/stable/dart-async/FutureRecord2/wait.html),
> [ParallelWaitError](https://api.dart.dev/stable/dart-async/ParallelWaitError-class.html),
> [Future.timeout](https://api.dart.dev/stable/dart-async/Future/timeout.html),
> [Completer](https://api.dart.dev/stable/dart-async/Completer-class.html),
> [unawaited](https://api.dart.dev/stable/dart-async/unawaited.html)
> Min. dil sürümü: `Future`/`async`-`await` her sürümde; **`FutureExtensions.ignore` 2.14**,
> **`unawaited` 2.15**; **record/iterable `.wait` ve `ParallelWaitError` 3.0**.

Her isolate'in **tek bir event loop**'u vardır; olaylar kuyruğa girdikleri sırayla,
**birer birer** işlenir. `Future` bu döngünün üstüne kurulmuş bir sözdür: sonucu (değer
veya hata) **daha sonra** gelir. Bir `async` fonksiyon **ilk `await`'e kadar senkron**
çalışır, orada bir `Future` döner ve kalanı sonra devam eder.

İki kuyruk vardır (API: `scheduleMicrotask`): **microtask** kuyruğundaki callback'ler
"Timer olayları gibi diğer asenkron olaylardan **önce** çalışmaları garanti edilir".
`Timer.run` ve `Future(() {...})` ise **event** kuyruğuna girer (`Future()` hesaplamasını
"`Timer.run` ile asenkron" çalıştırır). Microtask kuyruğunu sürekli beslemek event
kuyruğunu **aç bırakır** (API'deki uyarı) — bu yüzden `scheduleMicrotask` uygulama
kodunda nadiren gerekir.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| `async`/`await` + `try`/`catch`: RepositoryImpl, UseCase, Notifier'daki her sıralı asenkron akış | `.then().catchError()` zinciri → yalnızca `await` kullanılamayan yerde (ör. `Future` döndüren ama `async` olmayan fonksiyon). Okunabilirlik için `await` tercih et |
| Birbirinden bağımsız istekler → **aynı anda başlat**, record `.wait` ile bekle (her alan kendi tipinde) | Aynı tipte, sonucu tek liste olan istekler → `Future.wait` yeterli. İkinci istek birincinin sonucuna bağlıysa → sıralı `await` |
| Hata olursa başarılı sonuçlara da erişmek gerekiyor → `.wait` + `ParallelWaitError` | Tek hata yeterli ve ilk hatayı istiyorsan → `Future.wait` (sonraki hatalar düşer) |
| Ağ/IO sınırı olan data katmanı → `.timeout(limit)` → `TimeoutException`'ı Failure'a çevir | UI'da "çok uzun sürdü" göstermek için ayrı bir `Timer` → `timeout` + `onTimeout` zaten yeter |
| Callback tabanlı bir API'yi `Future`'a çevirmek → `Completer` | Zaten `Future` dönen bir şeyi sarmak → `Completer` **gerekmez**; `then`/`async` kullan (API: "most of the time" `Future` constructor'ları veya zincir yeter) |
| Senkron bir lifecycle'dan (ör. `initState`) bilerek ateşle-unut → `unawaited(f)` | Hatasını da umursamadığın future → `f.ignore()`. `unawaited` hatayı **yutmaz**; hata yine "unhandled" olur |
| Aynı frame/tick içinde biriken işleri bir kez işlemek (Flutter'ın focus/pointer kuyruğu gibi framework kodu) → `scheduleMicrotask` | Uygulama kodunda sıralama "düzeltmek" için microtask → neredeyse her zaman `await` doğru araç |
| — | `SynchronousFuture` (Flutter) → kendi dokümanı: "genel olarak kaçınılmalı, bu çift modlu davranışı debug etmek çok zor". Yalnızca framework sözleşmesi (ör. `LocalizationsDelegate.load`) istiyorsa |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Data / DataSource | `Future<Json>` döner, `ServerException` fırlatır; callback SDK'ları `Completer` ile `Future`'a çevrilir |
| Data / RepositoryImpl | Bağımsız çağrılar record `.wait` ile paralel; `.timeout()`; `TimeoutException` → `NetworkFailure`, `ParallelWaitError` → ilk hatanın Failure karşılığı. Dışarıya **asla** exception sızmaz: `Future<Result<T>>` |
| Domain / UseCase | `Future<Result<T>> call(...)` — ince geçiş, `async` bile gerekmez |
| Application / state sınıfı (düz Dart) | `await useCase(...)` + `switch`; senkron hook'tan başlatma `unawaited(load())` (güvenli, çünkü `load` `Result` sayesinde throw etmez) |

## Doğrulanmış örnekler

Tüm kod `examples/lib/06_event_loop_future/` altında, testleri
`examples/test/06_event_loop_future/` altında
(`dart run dartadvance_tool:dartadvance verify 06_event_loop_future`).

### Event loop: microtask vs event kuyruğu

Test çıktısı: önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu
(`Timer.run`, `Future()`) — sırayla.

<!-- snippet: 06_event_loop_future/microtask_order -->
```dart
import 'dart:async';

/// Returns the order in which each kind of callback ran.
Future<List<String>> eventLoopOrder() {
  final log = <String>[];
  final done = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()')));
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask'));
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function');

  Timer.run(() => done.complete(log));
  return done.future;
}
```

`async` fonksiyon ilk `await`'e kadar senkron çalışır
([execution flow](https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await)):

<!-- snippet: 06_event_loop_future/async_runs_sync -->
```dart
import 'dart:async';

Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null; // `await_only_futures` allows this microtask delay.
  log.add('greet: after await');
}

List<String> callWithoutAwait() {
  final log = <String>[];
  unawaited(greet(log));
  log.add('caller: next statement');
  return log;
}
```

### Future chaining

Zincirin ortasındaki hata sonraki `then` callback'lerini atlar, `catchError`'a kadar
taşınır ([dart.dev örneği](https://dart.dev/libraries/async/futures-error-handling#errors-in-the-middle-of-a-long-chain)).
`catchError`'ı orijinal future'a değil **`then()`'in sonucuna** bağla
([dart-async](https://dart.dev/libraries/dart-async#chaining-multiple-asynchronous-methods)).

<!-- snippet: 06_event_loop_future/future_chain -->
```dart
Future<String> one() => Future.value('from one');
Future<String> two() => Future.error('error from two');
Future<String> three() => Future.value('from three');

int _logAndRecover(List<String> log, Object error) {
  log.add('Got error: $error');
  return 42;
}

Future<String> longChain(List<String> log) {
  return one()
      .then((_) => two())
      .then((_) => three()) // skipped: still two()'s error
      .then((value) => value.length) // skipped: still two()'s error
      .catchError((Object error) => _logAndRecover(log, error))
      .then((value) => 'The value is $value');
}
```

Aynı akış `await` ile — katmanlarda tercih edilen biçim:

<!-- snippet: 06_event_loop_future/future_chain_await -->
```dart
import 'future_chain.dart';

Future<String> longChainAwait(List<String> log) async {
  int value;
  try {
    await one();
    final text = await two();
    await three();
    value = text.length;
  } catch (error) {
    log.add('Got error: $error');
    value = 42;
  }
  return 'The value is $value';
}
```

### Birden fazla future'ı beklemek

`Future.wait`: sonuç listesi **verilen sırayla** gelir (tamamlanma sırasıyla değil);
bir future hata verirse dönen future **ilk hatayla** tamamlanır, diğer hatalar
düşürülür ([waiting for multiple futures](https://dart.dev/libraries/dart-async#waiting-for-multiple-futures)).
`eagerError: true` ilk hatada beklemeden tamamlar; `cleanUp` başarılı sonuçları
hata durumunda serbest bırakmak içindir.

<!-- snippet: 06_event_loop_future/future_wait -->
```dart
/// Results keep the input order; the first error fails the whole wait.
Future<List<int>> fetchAllCounts(List<Future<int>> requests) => Future.wait(requests);
```

Record `.wait` (3.0): farklı tipler, destructuring ve `ParallelWaitError` ile
başarılı değerlere erişim. `values` başarısızlar için `null`, `errors` başarılılar
için `null` içeren **aynı şekilde** record'lardır
([handling errors for multiple futures](https://dart.dev/libraries/dart-async#handling-errors-for-multiple-futures)).
Iterable için de `.wait` vardır (`FutureIterable`); record uzantıları 2–9 alan
arası (`FutureRecord2` … `FutureRecord9`).

<!-- snippet: 06_event_loop_future/record_wait -->
```dart
import 'dart:async';

Future<String> loadDashboard(Future<int> unread, Future<String> userName) async {
  try {
    final (count, name) = await (unread, userName).wait;
    return '$name has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    final (count, name) = error.values;
    final (countError, _) = error.errors;
    return 'partial: name=$name count=$count countError=${countError?.error}';
  }
}
```

### Timeout

`onTimeout` yoksa `TimeoutException`; varsa onun sonucu kullanılır. Kaynak future
**iptal edilmez**, sonradan tamamlanabilir; sonucu (hatası dahil) yok sayılır.

<!-- snippet: 06_event_loop_future/future_timeout -->
```dart
import 'dart:async';

/// Fails with a [TimeoutException] when [limit] passes first.
Future<String> fetchOrThrow(Future<String> request, Duration limit) => request.timeout(limit);

/// The source future is not cancelled; its late result is ignored.
Future<String> fetchOrCached(Future<String> request, Duration limit) =>
    request.timeout(limit, onTimeout: () => 'cached');
```

### Completer: callback API → Future

`complete`/`completeError` **en fazla bir kez** çağrılabilir; callback birden fazla
tetiklenebiliyorsa `isCompleted` ile koru.

<!-- snippet: 06_event_loop_future/callback_completer -->
```dart
import 'dart:async';

abstract interface class LegacyLocationClient {
  void requestCity(void Function(String? city, Object? error) onDone);
}

Future<String> currentCity(LegacyLocationClient client) {
  final completer = Completer<String>();
  client.requestCity((city, error) {
    if (completer.isCompleted) return;
    if (error != null) return completer.completeError(error);
    completer.complete(city ?? 'unknown');
  });
  return completer.future;
}
```

### Domain: entity, repository arayüzü, UseCase

<!-- snippet: 06_event_loop_future/profile_domain -->
```dart
import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show User, UserId;

final class Profile {
  const Profile({required this.user, required this.followers});
  final User user;
  final int followers;
}

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile(UserId id);
}

final class GetProfile {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(UserId id) => _repository.getProfile(id);
}
```

### Data: RepositoryImpl — paralel istek + timeout → Result

İki istek `try`'dan önce, tek bir record içinde **aynı anda** başlar; `.wait.timeout(...)`
hem süreyi hem hataları tek yerde toplar. JSON eşleme ve hata eşleme küçük private
fonksiyonlardadır. `Failure` sealed olduğu için yeni alt tip eklenmez; mevcutlara map edilir
(`TimeoutException` → `NetworkFailure`). `AsyncError.stackTrace` orijinal stack
trace'i taşır (ileride: Hata yönetimi).

<!-- snippet: 06_event_loop_future/profile_repository_impl -->
```dart
import 'dart:async';

import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show Json, ServerException, User, UserId;
import 'profile_domain.dart';

abstract interface class ProfileRemoteDataSource {
  /// Both throw [ServerException] on a non-2xx response.
  Future<Json> fetchUser(int id);
  Future<Json> fetchStats(int id);
}

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote, {this.timeLimit = const Duration(seconds: 10)});
  final ProfileRemoteDataSource _remote;
  final Duration timeLimit;

  @override
  Future<Result<Profile>> getProfile(UserId id) async {
    final requests = (_remote.fetchUser(id.value), _remote.fetchStats(id.value));
    try {
      final (user, stats) = await requests.wait.timeout(timeLimit);
      return _toProfile(user, stats);
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on ParallelWaitError<(Json?, Json?), (AsyncError?, AsyncError?)> catch (error) {
      return _toFailure(error.errors.$1 ?? error.errors.$2!);
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

Result<Profile> _toProfile(Json user, Json stats) => switch ((user, stats)) {
  ({'id': final int id, 'name': final String name}, {'followers': final int followers}) => Ok(
    Profile(
      user: User(id: UserId(id), name: name),
      followers: followers,
    ),
  ),
  _ => Err(UnexpectedFailure(const FormatException('Bad profile JSON'), StackTrace.current)),
};

Result<Profile> _toFailure(AsyncError first) => switch (first.error) {
  ServerException(:final statusCode) => Err(ServerFailure(statusCode)),
  final error => Err(UnexpectedFailure(error, first.stackTrace)),
};
```

### Application: state sınıfı — `unawaited` ile başlatma

<!-- snippet: 06_event_loop_future/profile_notifier -->
```dart
import 'dart:async';

import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show UserId;
import 'profile_domain.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final Profile profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

final class ProfileNotifier {
  ProfileNotifier(this._getProfile);
  final GetProfile _getProfile;

  ProfileState state = const ProfileLoading();

  /// Safe to fire and forget: [load] never throws, failures are a `Result`.
  void start(UserId id) => unawaited(load(id));

  Future<void> load(UserId id) async {
    state = const ProfileLoading();
    state = switch (await _getProfile(id)) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileError(failure.message),
    };
  }
}
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde `Completer<` **43**,
`scheduleMicrotask(` **21**, `SynchronousFuture<` **22**, `Future.wait` **9**,
`unawaited(` **8** satır (`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`).

| Sembol | Ne gösteriyor | Kaynak |
|---|---|---|
| `SynchronousFuture<T> implements Future<T>` | `then` callback'i **aynı event-loop turunda** çalışır; asla hata ile tamamlanmaz. Dokümanı: genel olarak kaçın | [foundation/synchronous_future.dart#L19](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/synchronous_future.dart#L19) |
| `SynchronousFuture.then` | `onValue(_value)`'yu hemen çağırır; sonuç `Future` değilse yine `SynchronousFuture` sarar | [foundation/synchronous_future.dart#L43](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/synchronous_future.dart#L43) |
| `_loadAll`: `SynchronousFuture` vs `Future.wait` | Tüm delegate'ler senkron döndüyse `SynchronousFuture` ([L87](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/localizations.dart#L87)), yoksa yalnızca bekleyenler `Future.wait` ile | [widgets/localizations.dart#L91](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/localizations.dart#L91) |
| `SchedulerBinding.endOfFrame` | `Completer<void>` + post-frame callback: callback tabanlı olayı `Future`'a çevirme; tek completer paylaşılır | [scheduler/binding.dart#L852](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L852) |
| `TickerFuture._primaryCompleter` | Kendi `Future` implementasyonu; `then`, `catchError`, `timeout` completer'ın future'ına devredilir ([L518](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/ticker.dart#L518)) | [scheduler/ticker.dart#L448](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/ticker.dart#L448) |
| `precacheImage` | Stream listener → `Completer<void>`; `if (!completer.isCompleted)` guard'ı ile tek tamamlama | [widgets/image.dart#L128](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/image.dart#L128) |
| `FocusManager._markNeedsUpdate` | `_haveScheduledUpdate` bayrağı + `scheduleMicrotask`: aynı turdaki çok sayıda focus değişikliğini **bir kez** uygula | [widgets/focus_manager.dart#L1947](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/focus_manager.dart#L1947) |
| `GestureBinding.cancelPointer` | Cancel olayı "bir sonraki pointer olayından önce ama bu çağrının içinde değil" — microtask ile | [gestures/binding.dart#L342](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/binding.dart#L342) |
| `unawaited(_forceRepaint())` | Service extension setter'ı frame'in çizilmesini beklemeden döner (yorum: VM service yanıtını bloklamamak için) | [rendering/binding.dart#L91](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/binding.dart#L91) |
| `Feedback.forLongPress` (iOS) | `SystemSound.play` + `HapticFeedback.heavyImpact` `Future.wait` ile paralel | [widgets/feedback.dart#L143](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/feedback.dart#L143) |
| `Scrollable.ensureVisible` | İç içe scrollable'ların animasyonları `Future.wait<void>`; tek future varsa doğrudan onu döner | [widgets/scrollable.dart#L533](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/scrollable.dart#L533) |

Not: `packages/flutter/lib` içinde record/iterable `.wait` kullanımı yok (`\]\.wait|\)\.wait` → 0).

## Lint'ler

| Lint | Set | Ne yapar |
|---|---|---|
| [unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures) | hiçbiri (opsiyonel, [dart.dev önerir](https://dart.dev/libraries/async/async-await#which-lints-work-for-futures)) | `async` gövdede `await` edilmeyen `Future`'ı yakalar; bilinçli ateşle-unut için `unawaited(...)` |
| [discarded_futures](https://dart.dev/tools/linter-rules/discarded_futures) | hiçbiri (opsiyonel, dart.dev önerir) | `async` **olmayan** fonksiyonda `Future` döndüren çağrıyı yakalar |
| [avoid_void_async](https://dart.dev/tools/linter-rules/avoid_void_async) | hiçbiri (opsiyonel) | `void f() async` yerine `Future<void> f() async` (top-level `main` hariç) |
| [await_only_futures](https://dart.dev/tools/linter-rules/await_only_futures) | core (→ recommended) | `Future`/`FutureOr`/`dynamic` olmayan şeyi `await` etmeyi yasaklar; `await null` microtask gecikmesi için izinli |

`unnecessary_await_in_return` **deprecated** (lint sayfası: kaldırın), önerilmez.

## Kontrol listesi

- [ ] Bağımsız istekler sıralı `await` ile değil, birlikte başlatılıp `.wait` / `Future.wait` ile mi bekleniyor?
- [ ] Farklı tipler veya kısmi sonuç gerekiyorsa record `.wait` + `ParallelWaitError`.
- [ ] Ağ/IO çağrısında `.timeout()` var ve `TimeoutException` Failure'a map ediliyor.
- [ ] RepositoryImpl'den exception sızmıyor; dönüş `Future<Result<T>>`.
- [ ] `catchError`, `then()`'in sonucuna bağlı (ya da hiç yok: `await` + `try`/`catch`).
- [ ] `Completer` yalnızca callback → Future köprüsünde; birden fazla tetiklenebiliyorsa `isCompleted` guard'ı.
- [ ] `unawaited` yalnızca hata vermeyecek future'da; hatası önemsizse `.ignore()`.
- [ ] `void f() async` yok → `Future<void>`.
- [ ] Uygulama kodunda `scheduleMicrotask`/`SynchronousFuture` yok (gerçek bir gerekçe yoksa).

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: Event loop sırası (microtask vs event kuyruğu)
- **Demo promptu:** "Uygulama açılışında log kaydı, önbellek ısıtma ve ayar okuma adımlarının hangi kuyruktan hangi sırayla çalıştığını gösteren bir fonksiyon ve testini yaz."
- **Model:** [`examples/lib/06_event_loop_future/microtask_order.dart`](../../../examples/lib/06_event_loop_future/microtask_order.dart), [`async_runs_sync.dart`](../../../examples/lib/06_event_loop_future/async_runs_sync.dart)
- **Katman:** tüm katmanlar (temel)
- **Adımlar:** 1. Bir log listesi ve `Completer<List<String>>` oluştur. 2. `Timer.run`, `Future()`, `scheduleMicrotask`, `Future.microtask` ve `await null` içeren bir `async` çağrıyı (`unawaited`) sırayla kuyruğa koy. 3. En sona senkron bir kayıt ekle. 4. Son bir `Timer.run` ile log'u completer'dan döndür.
- **Kabul kriteri:** Test, sıranın senkron → tüm microtask'lar (kuyruğa girdikleri sırayla) → event kuyruğu olduğunu ve `async` fonksiyonun ilk `await`'e kadar senkron çalıştığını kanıtlar.
- **Min. sürüm:** `unawaited` 2.15

### Tarif: `then` zincirinden `await` + `try`/`catch`'e
- **Demo promptu:** "Sipariş oluştur → ödeme al → fatura kes adımlarını `then` zinciriyle yaz, ortadaki adım hata verince zincirin nasıl toparlandığını göster, sonra aynısını `await` ile yeniden yaz."
- **Model:** [`examples/lib/06_event_loop_future/future_chain.dart`](../../../examples/lib/06_event_loop_future/future_chain.dart), [`future_chain_await.dart`](../../../examples/lib/06_event_loop_future/future_chain_await.dart)
- **Katman:** Data / RepositoryImpl
- **Adımlar:** 1. Her adımı `Future` döndüren küçük bir fonksiyon yap; biri hata versin. 2. Zinciri kur; `catchError`'ı orijinal future'a değil `then()`'in sonucuna bağla. 3. Aynı akışı `async` fonksiyonda `await` + `try`/`catch` ile yaz. 4. İki sürümü aynı girdiyle test et.
- **Kabul kriteri:** Test, hatadan sonraki `then` callback'lerinin atlandığını, zincirin `catchError`'ın değeriyle devam ettiğini ve `await` sürümünün aynı sonucu verdiğini kanıtlar.
- **Min. sürüm:** her sürüm

### Tarif: Paralel bekleme (`Future.wait` ve record `.wait`)
- **Demo promptu:** "Ürün detay ekranı için fiyat (`double`) ve stok adedini (`int`) aynı anda iste; stok isteği hata verse bile fiyatı göster."
- **Model:** [`examples/lib/06_event_loop_future/record_wait.dart`](../../../examples/lib/06_event_loop_future/record_wait.dart), [`future_wait.dart`](../../../examples/lib/06_event_loop_future/future_wait.dart)
- **Katman:** Data / RepositoryImpl
- **Adımlar:** 1. Aynı tipte, tek liste sonucu gereken istekler için `Future.wait` kullan. 2. Farklı tipteki bağımsız istekleri bir record'a koyup `.wait` ile bekle ve destructure et. 3. `on ParallelWaitError<(A?, B?), (AsyncError?, AsyncError?)>` yakala. 4. `values` ile başarılı değerleri, `errors` ile hataları oku.
- **Kabul kriteri:** Test, `Future.wait` sonucunun tamamlanma değil verilme sırasında geldiğini ve ilk hatayla başarısız olduğunu; record `.wait` hatasında başarılı değerin `values` içinde kaldığını kanıtlar.
- **Min. sürüm:** record `.wait` ve `ParallelWaitError` 3.0

### Tarif: Timeout ve yedek değer
- **Demo promptu:** "Hava durumu isteği 3 saniyeyi geçerse önbellekteki son değeri döndüren bir fonksiyon yaz."
- **Model:** [`examples/lib/06_event_loop_future/future_timeout.dart`](../../../examples/lib/06_event_loop_future/future_timeout.dart)
- **Katman:** Data / RepositoryImpl
- **Adımlar:** 1. Hata isteyen sürüm için `request.timeout(limit)` kullan. 2. Yedek değer isteyen sürüm için `onTimeout` ver. 3. Testte hiç tamamlanmayan bir `Completer().future` ve `Duration.zero` kullan.
- **Kabul kriteri:** Test, `onTimeout` yokken `TimeoutException`, varken yedek değer döndüğünü ve süresinde biten kaynağın kazandığını kanıtlar.
- **Min. sürüm:** her sürüm

### Tarif: Callback API'yi `Future`'a çevirmek (`Completer`)
- **Demo promptu:** "Sonucu callback ile bildiren (ve callback'i bazen iki kez çağıran) bir parmak izi doğrulama SDK'sını `Future<bool>` döndüren bir fonksiyona çevir."
- **Model:** [`examples/lib/06_event_loop_future/callback_completer.dart`](../../../examples/lib/06_event_loop_future/callback_completer.dart)
- **Katman:** Data / DataSource
- **Adımlar:** 1. Sahibi olmadığın SDK'yı `abstract interface class` ile tanımla. 2. Fonksiyonda bir `Completer<T>` oluştur. 3. Callback'in ilk satırında `isCompleted` ise çık. 4. Hata varsa `completeError`, yoksa `complete` çağır ve `completer.future` döndür.
- **Kabul kriteri:** Test, değer ve hata ile tamamlanmayı ve ikinci callback'in yok sayıldığını kanıtlar.
- **Min. sürüm:** her sürüm

### Tarif: Paralel istek + timeout → `Result`, state sınıfında `unawaited` başlatma
- **Demo promptu:** "Sipariş detay ekranı için sipariş ve kargo bilgisini aynı anda çeken, zaman aşımı ve sunucu hatasını Failure'a çeviren bir repository ile onu senkron bir hook'tan başlatan state sınıfını yaz."
- **Model:** [`examples/lib/06_event_loop_future/profile_repository_impl.dart`](../../../examples/lib/06_event_loop_future/profile_repository_impl.dart), [`profile_domain.dart`](../../../examples/lib/06_event_loop_future/profile_domain.dart), [`profile_notifier.dart`](../../../examples/lib/06_event_loop_future/profile_notifier.dart)
- **Katman:** tüm katmanlar (Domain, Data / RepositoryImpl, state sınıfı)
- **Adımlar:** 1. Domain'de entity, `Future<Result<T>>` dönen repository arayüzü ve UseCase yaz. 2. RepositoryImpl'de istekleri `try`'dan önce tek bir record içinde başlat, `.wait.timeout(limit)` ile bekle. 3. `TimeoutException` → `NetworkFailure`, `ParallelWaitError` içindeki ilk hata → `ServerFailure`/`UnexpectedFailure`; eşlemeleri private fonksiyonlara çıkar. 4. State sınıfında `start` → `unawaited(load(id))`, `load` sonucu `switch` ile sealed state'e çevirsin.
- **Kabul kriteri:** Test, `Ok` birleşimini, timeout → `NetworkFailure`, `ServerException` → `ServerFailure`, diğer hata → `UnexpectedFailure` eşlemelerini ve `start` sonrası state'in önce loading kalıp sonra yerleştiğini kanıtlar.
- **Min. sürüm:** 3.0 (record `.wait`, sealed); `unawaited` 2.15

## Pekiştirme

### Alıştırma 1 · Açılış sırasını tahmin et (kolay)

`bootOrder()` bir log listesi tutsun ve sırayla şunları yapsın: `Timer.run` ile bir kayıt,
`scheduleMicrotask` ile bir kayıt, `await null` içeren bir `async` fonksiyonu `await`
etmeden çağırmak (await'ten önce ve sonra birer kayıt), en sonda senkron bir kayıt. Log,
event kuyruğu boşaldıktan sonra dönsün. Çalıştırmadan önce **sırayı tahmin et**, sonra
testle doğrula.

**İpucu:** "Event loop: microtask vs event kuyruğu" bölümü ve
[execution flow](https://dart.dev/libraries/async/async-await#execution-flow-with-async-and-await):
`async` fonksiyon ilk `await`'e kadar senkron çalışır.

<details><summary>Çözüm</summary>

<!-- snippet: 06_event_loop_future/practice/ex1_boot_order -->
```dart
import 'dart:async';

Future<void> _loadConfig(List<String> log) async {
  log.add('loadConfig: before await');
  await null;
  log.add('loadConfig: after await');
}

Future<List<String>> bootOrder() {
  final log = <String>[];
  final done = Completer<List<String>>();

  Timer.run(() => log.add('Timer.run'));
  scheduleMicrotask(() => log.add('scheduleMicrotask'));
  unawaited(_loadConfig(log));
  log.add('boot: end of function');

  Timer.run(() => done.complete(log));
  return done.future;
}
```

Sonuç: `loadConfig: before await` → `boot: end of function` → `scheduleMicrotask` →
`loadConfig: after await` → `Timer.run`. `Timer.run` ilk yazılan satır olsa da en sonda.

</details>

### Alıştırma 2 · Dashboard: paralel istek, kısmi sonuç (orta)

**Data:** `DashboardRemoteDataSource` iki istek sunar: `fetchUserName` (zorunlu) ve
`fetchUnreadCount` (opsiyonel rozet). `DashboardRepositoryImpl.load` ikisini **aynı anda**
başlatsın, record `.wait` + `.timeout` ile beklesin ve `Future<Result<Dashboard>>` dönsün:
yalnızca rozet isteği hata verirse yine `Ok` (rozet `null`), isim isteği hata verirse
`ServerException` → `ServerFailure`, timeout → `NetworkFailure`. **State sınıfı:**
`DashboardNotifier.start` senkron bir hook'tan `unawaited` ile yüklesin. **Presentation:**
`dashboardTitle(state)` exhaustive switch. Testler gerçek bekleme yerine `Completer` ve
`Duration.zero` kullansın.

**İpucu:** "Data: RepositoryImpl — paralel istek + timeout → Result" bölümü ve
[handling errors for multiple futures](https://dart.dev/libraries/dart-async#handling-errors-for-multiple-futures):
`ParallelWaitError.values` başarılı değerleri taşır.

<details><summary>Çözüm</summary>

Domain:

<!-- snippet: 06_event_loop_future/practice/ex2_dashboard_domain -->
```dart
import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show UserId;

final class Dashboard {
  const Dashboard({required this.userName, required this.unread});
  final String userName;

  /// `null` when the optional unread badge could not be loaded.
  final int? unread;
}

abstract interface class DashboardRepository {
  Future<Result<Dashboard>> load(UserId id);
}
```

Data — istekler `try`'dan önce, tek record içinde başlar:

<!-- snippet: 06_event_loop_future/practice/ex2_dashboard_repository -->
```dart
import 'dart:async';

import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show ServerException, UserId;
import 'ex2_dashboard_domain.dart';

abstract interface class DashboardRemoteDataSource {
  /// Both throw [ServerException] on a non-2xx response.
  Future<String> fetchUserName(int id);
  Future<int> fetchUnreadCount(int id);
}

final class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote, {this.timeLimit = const Duration(seconds: 10)});
  final DashboardRemoteDataSource _remote;
  final Duration timeLimit;

  @override
  Future<Result<Dashboard>> load(UserId id) async {
    final requests = (_remote.fetchUserName(id.value), _remote.fetchUnreadCount(id.value));
    try {
      final (name, unread) = await requests.wait.timeout(timeLimit);
      return Ok(Dashboard(userName: name, unread: unread));
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on ParallelWaitError<(String?, int?), (AsyncError?, AsyncError?)> catch (error) {
      final (name, _) = error.values;
      if (name != null) return Ok(Dashboard(userName: name, unread: null));
      return _toFailure(error.errors.$1!);
    }
  }
}

Result<Dashboard> _toFailure(AsyncError nameError) => switch (nameError.error) {
  ServerException(:final statusCode) => Err(ServerFailure(statusCode)),
  final error => Err(UnexpectedFailure(error, nameError.stackTrace)),
};
```

State sınıfı ve Presentation:

<!-- snippet: 06_event_loop_future/practice/ex2_dashboard_notifier -->
```dart
import 'dart:async';

import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show UserId;
import 'ex2_dashboard_domain.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardReady extends DashboardState {
  const DashboardReady(this.dashboard);
  final Dashboard dashboard;
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
}

final class DashboardNotifier {
  DashboardNotifier(this._repository);
  final DashboardRepository _repository;

  DashboardState state = const DashboardLoading();

  void start(UserId id) => unawaited(load(id));

  Future<void> load(UserId id) async {
    state = const DashboardLoading();
    state = switch (await _repository.load(id)) {
      Ok(:final value) => DashboardReady(value),
      Err(:final failure) => DashboardError(failure.message),
    };
  }
}

String dashboardTitle(DashboardState state) => switch (state) {
  DashboardLoading() => 'Loading...',
  DashboardReady(dashboard: Dashboard(:final userName, unread: final int count)) =>
    '$userName ($count)',
  DashboardReady(dashboard: Dashboard(:final userName)) => userName,
  DashboardError(:final message) => message,
};
```

Test, `load` çağrıldıktan hemen sonra (hiçbir completer tamamlanmadan) iki isteğin de
başladığını (`calls == ['name', 'unread']`) doğrular: sıralı `await` bunu sağlamazdı.

</details>

### Alıştırma 3 · Callback'ten Future'a, `sealed` olaylarla (zor)

03 (class modifiers) ile birleştir. Bir barkod SDK'sı sonucu callback ile bildiriyor ve
callback'i **birden fazla kez** çağırabiliyor (ör. `ScanFound`'dan sonra geç bir
`ScanFailed`). `sealed class ScanEvent` (`ScanFound(code)`, `ScanFailed(error)`,
`ScanCancelled`) tanımla ve `scanOnce(scanner, {timeLimit})` yaz: **ilk olay kazanır**,
ikinci callback hata fırlatmaz; süre dolarsa iptal sayılır. Sonuç
`Future<Result<String?>>`: bulundu → `Ok(code)`, iptal/timeout → `Ok(null)`, hata →
`Err(UnexpectedFailure)`. Eşleme `_` kolu olmayan bir switch ile yapılsın.

**İpucu:** "Completer: callback API → Future" (`isCompleted` guard'ı) ve "Timeout"
bölümleri (`onTimeout` varsa onun sonucu kullanılır).

<details><summary>Çözüm</summary>

<!-- snippet: 06_event_loop_future/practice/ex3_scan_once -->
```dart
import 'dart:async';

import '../../00_architecture/result.dart';

sealed class ScanEvent {
  const ScanEvent();
}

final class ScanFound extends ScanEvent {
  const ScanFound(this.code);
  final String code;
}

final class ScanFailed extends ScanEvent {
  const ScanFailed(this.error);
  final Object error;
}

final class ScanCancelled extends ScanEvent {
  const ScanCancelled();
}

/// A callback SDK that may fire its callback more than once.
abstract interface class BarcodeScanner {
  void start(void Function(ScanEvent event) onEvent);
}

/// The first event wins; a timeout counts as a cancel.
Future<Result<String?>> scanOnce(
  BarcodeScanner scanner, {
  Duration timeLimit = const Duration(seconds: 30),
}) async {
  final completer = Completer<ScanEvent>();
  scanner.start((event) {
    if (!completer.isCompleted) completer.complete(event);
  });
  final event = await completer.future.timeout(
    timeLimit,
    onTimeout: () => const ScanCancelled(),
  );
  return switch (event) {
    ScanFound(:final code) => Ok(code),
    ScanCancelled() => const Ok(null),
    ScanFailed(:final error) => Err(UnexpectedFailure(error, StackTrace.current)),
  };
}
```

Guard olmadan ikinci `complete` `StateError` fırlatır (test bunu ayrıca gösterir).
Completer `completeError` yerine olayın kendisiyle tamamlandığı için hata da iptal de
aynı exhaustive switch'ten geçer; `ScanEvent`'e yeni bir alt tip eklemek bu switch'i
derleme hatasına çevirir.

</details>

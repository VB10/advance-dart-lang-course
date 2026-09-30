---
name: dartadvance
description: "Advanced Dart language guidance — what each feature does, when to use it and where it fits in a layered (Clean Architecture) app, backed by tested examples. Use when writing or reviewing Dart that involves typedefs, generics/type system, null safety & type promotion, records, patterns/switch expressions, sealed/final/base/interface class modifiers, enhanced enums, extension methods, extension types (typed IDs, value objects), callable use cases, mixins, constructors, dot shorthands, null-aware elements, primary constructors, Future/event loop, Streams/StreamController/async*, isolates/compute/Isolate.run, error handling and stack traces, Result<T>/Failure modeling, iterables/sync*, dart:collection & package:collection (firstWhereOrNull, groupBy, sortedBy, DeepCollectionEquality/ListEquality, PriorityQueue, UnmodifiableListView, SplayTreeMap), package:async (CancelableOperation, AsyncMemoizer, AsyncCache, StreamGroup, StreamQueue, StreamSplitter, FutureGroup, Result name clash), package:characters, libraries/exports/part/part of/library privacy/deferred imports/metadata annotations (@immutable, @useResult, @protected), built-in types (int vs double vs num, web number semantics, String length vs runes vs grapheme clusters, Symbols), final vs const vs late, wildcard _, null-aware cascade ?.., ~/ and other overlooked operators, keywords, Never/Object?/dynamic, Effective Dart API design."
---

# dartadvance

İleri seviye Dart: her özelliğin **ne olduğu, ne zaman kullanıldığı (ve ne zaman gerekmediği)**
ve katmanlı bir uygulamada **hangi problemi çözdüğü**. Her kod bloğu testli bir örnekten gelir.

Kapsam **yalnızca Dart dili** ve onu tamamlayan Dart ekibi core paketleri (`dart-lang/core`: collection, async, characters, meta…). Hangi API'nin SDK'dan, hangisinin paketten geldiği her zaman belirtilir. State management (Riverpod, bloc…) konu dışı; "state sınıfı" = state tutan düz Dart sınıfı.

## 0. Her görevde önce: SDK kontrolü

1. Hedef paketin `pubspec.yaml` → `environment: sdk:` **alt sınırını** oku
   (`^3.8.0` → 3.8, `'>=3.0.0 <4.0.0'` → 3.0). Monorepo'da her paket ayrı
   bakılır; kodun yazılacağı paketin sınırı geçerlidir.
2. Aşağıdaki tablodan alt sınırın **üstündeki** özellikleri önerme. Kullanıcı
   isterse "SDK alt sınırını X'e çekmek gerekir" diye belirt.

| Özellik | Min. dil sürümü | Kaynak |
| --- | --- | --- |
| Records, patterns, switch expression, if-case, class modifiers (`sealed`/`final`/`base`/`interface`), `mixin class` | 3.0 | dart.dev/language/records, patterns, class-modifiers |
| Private final field promotion | 3.2 | dart.dev/tools/non-promotion-reasons |
| Extension types | 3.3 | Dart SDK CHANGELOG 3.3.0 (docs sayfasında version-note yok) |
| Digit separators (`1_000_000`) | 3.6 | dart.dev/language/built-in-types#numbers |
| Wildcard variables (`_`), inference using bounds | 3.7 | dart.dev/language/variables#wildcard-variables |
| Null-aware elements (`[?x]`, `{?k: v}`) | 3.8 | dart.dev/language/collections#null-aware-element |
| Dot shorthands (`.center`, `.new()`) | 3.10 | dart.dev/language/dot-shorthands |
| Private named parameters as initializing formals | 3.12 | dart.dev/language/constructors#private-named-parameters |
| Primary constructors, concise constructor syntax | 3.13 | dart.dev/language/primary-constructors |
| Generalized typedefs (non-function) | 2.13 | dart.dev/language/typedefs |
| Unnamed `library;` directive | 2.19 | Dart SDK CHANGELOG 2.19 |
| `part of '<uri>'` (isimli form deprecated) | 2.0 | Dart SDK CHANGELOG 2.0 |
| `>>>` triple-shift | 2.14 | dart.dev/language/operators |
| Enhanced enums, super parameters | 2.17 | dart.dev/language/enums |

## 1. Mimari kararlar (sabit)

**Hata modeli: `sealed class Result<T>`** (dartz `Either` kullanılmaz). UseCase ve
Repository `Future<Result<T>>` döner; tüketici `switch` ile exhaustive işler.

<!-- snippet: 00_architecture/result#result -->
```dart
/// Outcome of an operation that can fail with a domain [Failure].
///
/// `sealed` makes `switch` over a `Result` exhaustive: the compiler rejects a
/// switch that forgets `Err`.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
```

<!-- snippet: 00_architecture/result#failure -->
```dart
/// Every failure the domain layer knows about. New subtypes must be handled
/// by every exhaustive `switch` — that is the point of `sealed`.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('No connection');
}

final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode) : super('Server error');
  final int statusCode;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error, this.stackTrace) : super('Unexpected error');
  final Object error;
  final StackTrace stackTrace;
}
```

<!-- snippet: 00_architecture/describe_user -->
```dart
import 'result.dart';
import 'user.dart';

String describe(Result<User> result) => switch (result) {
  Ok(value: User(:final name)) => 'Hello, $name',
  Err(failure: ServerFailure(:final statusCode)) => 'Server said $statusCode',
  Err(:final failure) => failure.message,
};
```

**freezed vs native `sealed`: kural**

| Durum | Kullan |
| --- | --- |
| Union / state hiyerarşisi / Failure (varyantlar arası `switch`) | native `sealed class` + `final class` alt tipler |
| `copyWith`, value equality ve/veya JSON gereken veri sınıfı (Model, büyük state) | `freezed` 3 (+ `json_serializable`) |
| 1–3 alanlı, davranışsız iç veri | record |
| Tek değeri saran ID / value object | extension type |

Projedeki freezed sürümünü `pubspec.lock`'tan doğrula; freezed 2.x ile 3.x'in
davranışı farklı. Emin değilsen freezed'in pub.dev sayfasını oku, tahmin etme.

**UseCase:** `final class`, tek public `call()` metodu, abstract repository'ye bağlı.

<!-- snippet: 00_architecture/get_user -->
```dart
import 'result.dart';
import 'user.dart';
import 'user_repository.dart';

final class GetUser {
  const GetUser(this._repository);
  final UserRepository _repository;

  Future<Result<User>> call(UserId id) => _repository.getUser(id);
}
```

## 2. Katman × Dart özelliği → reference

Görevdeki katmanı bul, ilgili reference'ı **oku**, sonra yaz. "ileride" = henüz yazılmadı (§3).

| Katman | Özellikler | Reference |
| --- | --- | --- |
| Tüm katmanlar (temel) | int/double/num, String vs grapheme, `final`/`const`/`late`, `?..`, `Never`, keyword türleri | 01 |
| Domain / Entity | sealed state/Failure, `final`/`interface`; extension type ID'ler, enhanced enum (ileride) | 03 |
| Domain / Repository arayüzü | `abstract interface class`, typedef; generics (ileride) | 03 · 02 |
| Domain / UseCase | `final class` + `call()`; records, callable (ileride) | 03 |
| Data / Model | `typedef Json`, mapper typedef; patterns ile JSON doğrulama (ileride) | 02 |
| Data / DataSource | streams (WebSocket, `async*`), `StreamController`, `StreamGroup`, isolate ile ağır parse | 07 · 08 · 09 |
| Data / RepositoryImpl | Future hataları, paralel istek + timeout, `firstWhereOrNull` → `Result` | 06 · 05 |
| Application / state sınıfı (düz Dart) | sealed UI state, stream abonelik/iptal, `CancelableOperation` | 03 · 07 · 08 |
| Presentation | typedef callback, grapheme ile metin kırpma; dot shorthands (ileride) | 02 · 01 |
| Koleksiyonlar | `dart:collection` + `package:collection` (Equality, groupBy, PriorityQueue, değiştirilemez görünüm) | 05 |
| Paket / modül sınırı | library privacy, `export` barrel, `part`, metadata, language versioning | 04 |

## 3. Reference dizini

Numara = öğrenme sırası. Yeni konu yazıldıkça **sıradaki numarayı** alır (boşluk bırakılmaz).

| # | Reference | Konu |
| --- | --- | --- |
| 00 | (ortak iskelet; kodu §1'de gömülü) | `Result<T>`, `Failure`, UseCase, Repository |
| 01 | [references/01-builtin-types.md](references/01-builtin-types.md) | Built-in types ve sık atlanan temeller |
| 02 | [references/02-typedefs.md](references/02-typedefs.md) | Typedefs |
| 03 | [references/03-class-modifiers.md](references/03-class-modifiers.md) | Class modifiers |
| 04 | [references/04-libraries-metadata.md](references/04-libraries-metadata.md) | Libraries, imports, `part`, metadata |
| 05 | [references/05-collection.md](references/05-collection.md) | `dart:collection` + `package:collection` |
| 06 | [references/06-event-loop-future.md](references/06-event-loop-future.md) | Event loop ve Future |
| 07 | [references/07-streams.md](references/07-streams.md) | Streams |
| 08 | [references/08-async-package.md](references/08-async-package.md) | `package:async` |
| 09 | [references/09-isolates.md](references/09-isolates.md) | Isolates ve compute |

**İleride (henüz reference yok):** Generics ve tip sistemi · Null safety ve type promotion ·
Records · Patterns · Enhanced enums · Extension methods · Extension types · Callable objects ve mixins ·
Constructors ve modern sözdizimi (dot shorthands, primary constructors) · Hata yönetimi ·
Iterables ve `sync*` · Effective Dart: Design · `dart:convert` codec'leri + `typed_data` ·
Zones + `package:stack_trace` · `dart:core` araçları (Uri, DateTime, RegExp) · diğer core paketler.

**Reference yoksa** (durum ≠ hazır): tahmin etme. İlgili dart.dev sayfasını
çek (`https://raw.githubusercontent.com/dart-lang/site-www/main/src/content/<path>.md`)
ve oradaki kurala göre yaz.

## 4. Görev modu: kullanıcı bir şey YAPTIRMAK istediğinde

1. §0 SDK kontrolü.
2. **Tarifi bul:** ilgili reference'ta yalnız `## Skill ile üret` bölümünü oku (dosyanın tamamını okuma).
3. **Modeli bul:** tarifteki model dosya adı `x.dart` ise aynı reference'ta `snippet: NN_konu/x` satırını ara
   (`grep -n "snippet: NN_konu/x"`); hemen altındaki kod bloğu modelin tamamıdır. Model başka bir tipe
   dayanıyorsa (ör. entity) onun snippet'ini de aynı yolla bul. `examples/lib/...` yolları yalnız bu repoda
   geçerlidir, başka projede o dosyaları arama.
4. **Ortak tipler:** kod `Result` / `Failure` gerektiriyorsa önce projede ara (`sealed class Result`,
   `sealed class Failure`). Yoksa §1'deki tanımları `lib/core/result.dart` dosyasına ekle; `Failure`'ın yalnız
   kodun ve testin kullandığı alt tiplerini yaz.
   **Eksik katmanlar:** model başka katmanlara dayanıyorsa (entity, repository, UseCase) ve projede yoksa yalnız
   domain tiplerini yaz (entity + `abstract interface` repository + gerekiyorsa UseCase). Data katmanını
   (DataSource, RepositoryImpl) istenmedikçe yazma; kaynağı testte fake ile ver.
5. **Yaz:** kullanıcının alanına uyarla (modeldeki isimleri kopyalama):
   - bir dosya = bir kavram, ≤ 50 satır; özellik klasörü (`lib/<özellik>/`);
   - yorum yalnız public API'de tek satır `///`;
   - iç içe en fazla 3 seviye; erken `return`, switch expression;
   - kullanıcıya görünen metinler kullanıcının yazdığı dilde.
   - Proje şablon dosyalarına (`dart create` çıktısı) dokunma.
6. **Test:** tarifin kabul kriterini kanıtlayan testi `test/<özellik>/` altına yaz. Kriter bir **derleme hatası**
   ise (ör. "yeni alt tip eklenince switch derlenmez") geçici olarak alt tipi ekle, `dart analyze` hatasını göster,
   sonra geri al; bunu raporda belirt.
7. `dart format`, `dart analyze` (sıfır sorun) ve `dart test` çalıştır; çıktıyı göster.
8. Kısa özet: seçilen tarif, oluşturulan dosyalar, katman, min. dil sürümü.

## 5. Kurallar

- API detayları için hafızaya güvenme; dart.dev ve api.dart.dev resmi kaynaktır.
- "Flutter'da gerçek kullanım" iddiaları reference'taki permalink'lere dayanır
  (flutter/flutter, sabit stable tag). Uydurma örnek framework kodu yazma.
- Daha basit yapı yetiyorsa ileri özelliği zorlama; her reference'ta
  "ne zaman **gerekmez**" bölümü vardır, ona uy.

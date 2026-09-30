---
name: dartadvance
description: "Advanced Dart language guidance — what each feature does, when to use it and where it fits in a layered (Clean Architecture) app, backed by tested examples. Use when writing or reviewing Dart that involves typedefs, generics/type system, null safety & type promotion, records, patterns/switch expressions, sealed/final/base/interface class modifiers, enhanced enums, extension methods, extension types (typed IDs, value objects), callable use cases, mixins, constructors, dot shorthands, null-aware elements, primary constructors, Future/event loop, Streams/StreamController/async*, isolates/compute/Isolate.run, error handling and stack traces, Result<T>/Failure modeling, iterables/sync*, dart:collection & package:collection (firstWhereOrNull, groupBy, sortedBy, DeepCollectionEquality/ListEquality, PriorityQueue, UnmodifiableListView, SplayTreeMap), package:async (CancelableOperation, AsyncMemoizer, AsyncCache, StreamGroup, StreamQueue, StreamSplitter, FutureGroup, Result name clash), package:characters, libraries/exports/part/part of/library privacy/deferred imports/metadata annotations (@immutable, @useResult, @protected), built-in types (int vs double vs num, web number semantics, String length vs runes vs grapheme clusters, Symbols), final vs const vs late, wildcard _, null-aware cascade ?.., ~/ and other overlooked operators, keywords, Never/Object?/dynamic, Effective Dart API design."
---

# dartadvance

İleri seviye Dart dili + Dart ekibinin core paketleri (collection, async, characters, meta). Her özellik için:
**ne olduğu, ne zaman kullanılacağı, ne zaman gerekmediği** ve testli **tek dosyalık** bir model.
State management ve framework konu dışı.

## Nasıl çalışır

Kullanıcı bir özelliği gösterdiyse ya da "bunu advance kurala göre geliştir / yaz" dediyse:

1. **SDK kontrolü:** hedef paketin `pubspec.yaml` → `environment: sdk:` alt sınırını oku; aşağıdaki tabloda
   alt sınırın üstündeki özelliği önerme.
2. **Kuralı bul:** konuyu [dizinden](#dizin) seç; o dosyada yalnız ilgili `## N.` bölümünü oku
   (`grep -n "^## " rules/NN-*.md`, sonra o bölümü). Dosyanın tamamını okuma.
3. **Modeli uyarla:** bölümdeki kod bloğu modeldir; kullanıcının alanına uyarla, isimleri kopyalama.
4. **Yaz:** bir dosya = bir kavram, ≤ 50 satır, yorum en az, iç içe en fazla 3 seviye, metinler kullanıcının dilinde.
   `dart create` şablon dosyalarına dokunma.
5. **Kanıtla:** bölümdeki **Kabul** satırını test eder. Kabul bir derleme hatasıysa geçici olarak ihlal et,
   `dart analyze` hatasını göster, geri al.
6. `dart format` · `dart analyze` (sıfır sorun) · `dart test`; çıktıyı göster. Sonunda 3 satır özet:
   hangi kural, hangi dosyalar, min. sürüm.

Daha basit yapı yetiyorsa ileri özelliği zorlama; her bölümdeki **Gerekmez** satırına uy.
Kural dosyası yoksa tahmin etme; dart.dev sayfasını oku
(`https://raw.githubusercontent.com/dart-lang/site-www/main/src/content/<yol>.md`).

## Dizin

| # | Kural dosyası | Konu |
| --- | --- | --- |
| 01 | [rules/01-builtin-types.md](rules/01-builtin-types.md) | String uzunluğu, int/double, final/const/late, `_`, `?..` |
| 02 | [rules/02-typedefs.md](rules/02-typedefs.md) | Typedef ve yeni tip olmadığı |
| 03 | [rules/03-class-modifiers.md](rules/03-class-modifiers.md) | `sealed`, `final`, `base`, `interface`, `mixin class` |
| 04 | [rules/04-libraries-metadata.md](rules/04-libraries-metadata.md) | Library gizliliği, `export`, `part`, `@immutable`/`@useResult` |
| 05 | [rules/05-collection.md](rules/05-collection.md) | `dart:collection` ve `package:collection` |
| 06 | [rules/06-event-loop-future.md](rules/06-event-loop-future.md) | Event loop, `Future.wait`, timeout |
| 07 | [rules/07-streams.md](rules/07-streams.md) | Stream, broadcast, `async*`, abonelik |
| 08 | [rules/08-async-package.md](rules/08-async-package.md) | `CancelableOperation`, `AsyncMemoizer`, `AsyncCache`, `StreamQueue` |
| 09 | [rules/09-isolates.md](rules/09-isolates.md) | `Isolate.run`, port'lar |

Yeni konu sıradaki numarayı alır, boşluk bırakılmaz.

## SDK tablosu

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

## Hata modeli (ortak)

Bir kural hata döndürmeyi gerektiriyorsa `Result<T>` kullan (dartz yok). Projede yoksa `lib/core/result.dart`
dosyasına ekle; `Failure`'ın yalnız kullanılan alt tiplerini yaz.

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

Union/state hiyerarşisi → native `sealed`. `copyWith`/JSON gereken veri sınıfı → `freezed` 3
(sürümü `pubspec.lock`'tan doğrula). 1–3 alanlı davranışsız veri → record. Tek değerli ID → extension type.

## Kaynak

API detayı için hafızaya güvenme: dart.dev ve api.dart.dev. "Flutter'da gerçek kullanım" iddiaları kural
dosyasındaki sabit tag'li permalink'lere dayanır.

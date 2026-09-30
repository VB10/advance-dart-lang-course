# Müfredat: dartadvance

**Amaç:** temiz, ileri seviye Dart bilgisi. Her özelliğin ne olduğu, ne zaman kullanıldığı ve ne zaman
**gerekmediği**, katmanlı bir uygulamada hangi problemi çözdüğü. Her konu testli örneklerle kanıtlanır ve
pekiştirme alıştırmalarıyla biter.

**Kapsam:** Dart dili + onu tamamlayan Dart ekibi core paketleri (`dart-lang/core`). Framework, state management
ve tooling konu dışı. Flutter kaynağı yalnızca "gerçek hayatta böyle kullanılıyor" **kanıtı** olarak geçer.

---

## 1. Konular

Toplam **239** test (`verify --all`). Numara = öğrenme sırası = video sırası. Yeni konu yazıldıkça **sıradaki numarayı** alır.

| # | Konu | Test (alıştırmalar dahil) | Öne çıkan |
| --- | --- | --- | --- |
| 00 | Ortak iskelet: `Result<T>`, `Failure`, UseCase, Repository | 4 | Diğer konuların kullandığı temel |
| 01 | Built-in types ve sık atlanan temeller | 42 | `'👋🏽'.length == 4`, `-7 ~/ 2 == -3`, web'de `1.0 is int` |
| 02 | Typedefs | 16 | Typedef yeni tip değildir; Flutter'da 411 typedef |
| 03 | Class modifiers | 23 | `sealed` alt tiplere geçmez; kısıtlar library bazında |
| 04 | Libraries, imports, `part`, metadata | 22 | Privacy library bazında; docs'ta `part` bölümü yok |
| 05 | `dart:collection` + `package:collection` | 31 | `firstOrNull` core'da, `firstWhereOrNull` pakette |
| 06 | Event loop ve Future | 31 | sync → microtask → `Timer.run` → `Future()` |
| 07 | Streams | 19 | Cancel sonrası bile ikinci listen `StateError` |
| 08 | `package:async` | 36 | Future iptal edilemez → `CancelableOperation` |
| 09 | Isolates ve compute | 15 | Web'de isolate yok; `compute` = `Isolate.run` (native) |

**İleride** (önerilen sıra):
1. Generics ve tip sistemi
2. Null safety ve type promotion
3. Records
4. Patterns
5. Enhanced enums
6. Extension methods
7. Extension types
8. Callable objects ve mixins
9. Constructors ve modern sözdizimi (dot shorthands 3.10, primary constructors 3.13)
10. Hata yönetimi
11. Iterables ve `sync*`
12. Effective Dart: Design
13. `dart:convert` codec'leri + `typed_data`
14. Zones + `package:stack_trace`
15. `dart:core` araçları (Uri, DateTime, RegExp)
16. Diğer core paketler (path, logging, args…)

## 2. Her konunun yapısı

`skills/dartadvance/references/NN-*.md` hep aynı iskeleti izler:

1. Başlık: dart.dev kaynakları + min. dil sürümü
2. Ne zaman kullan / ne zaman **gerekmez**
3. Mimarideki yeri (Domain / Data / state sınıfı / Presentation)
4. Doğrulanmış örnekler (`<!-- snippet: id -->` → `examples/lib/NN_*`)
5. Flutter'daki gerçek kullanımlar (permalink, tag 3.47.5)
6. Lint'ler
7. Kontrol listesi
8. **Skill ile üret:** konudaki her yapı için bir tarif (demo promptu, model dosya, adımlar, kabul kriteri).
   Videoda örneği gösterip anlattıktan sonra, paralelde skill aynı yapıyı başka bir alanda sıfırdan kurar.
9. **Pekiştirme:** 3 alıştırma (kolay → orta: mimaride kullanım → zor: önceki bir konuyla birleştirme).
   Çözümler `examples/lib/NN_*/practice/exN_*.dart`, testleri `examples/test/NN_*/practice/`.

### Kod stili ("ekran kodu"): `examples/` ve skill'in ürettiği kod aynı kurala uyar

1. **Bir dosya = bir kavram.** Dosya adı kavramın adı (`broadcast_stream.dart`, `latest_search.dart`).
   Hedef ≤ 50 satır, üst sınır 80.
2. **Region yalnız gerekiyorsa.** Dosya tek kavramsa snippet id dosyanın kendisidir (`07_streams/broadcast_stream`).
3. **Yorum az:** açıklama reference'ta (Türkçe) durur. Kodda yalnız public API'de tek satır `///`,
   o da koddan anlaşılmayan tek noktayı söylüyorsa. Hedef yorum oranı < %10.
4. **İç içe en fazla 3 seviye.** Erken `return`, switch expression, küçük private yardımcı fonksiyon.
5. **İsimler anlatsın:** kısaltma yok; test adları davranışı cümle olarak söyler.
6. **İddialar korunur:** reference'ta söylenen her şey testle kanıtlı kalır.

## 3. dart.dev/language kapsam haritası

| Sayfa | Konu | Genelde atlanan |
| --- | --- | --- |
| [variables](https://dart.dev/language/variables) | 01 | `final` vs `const` (canonicalization), `late` initializer, wildcard `_` (3.7) |
| [operators](https://dart.dev/language/operators) | 01 | `?..`, `~/`, `??=`, `is!`, `>>>` (2.14) |
| [built-in-types](https://dart.dev/language/built-in-types) | 01 | Web'de int, `length` = UTF-16, grapheme, digit separators (3.6) |
| [keywords](https://dart.dev/language/keywords) | 01 | 4 tür: `sealed`, `on`, `show` identifier olabilir |
| [typedefs](https://dart.dev/language/typedefs) | 02 | Fonksiyon olmayan typedef (2.13), yeni tip değildir |
| [class-modifiers](https://dart.dev/language/class-modifiers) · [for APIs](https://dart.dev/language/class-modifiers-for-apis) · [reference](https://dart.dev/language/modifier-reference) | 03 | `sealed` alt tiplere geçmez, base transitivity |
| [libraries](https://dart.dev/language/libraries) · [metadata](https://dart.dev/language/metadata) · [versioning](https://dart.dev/language/versioning) | 04 | Privacy library bazında, `part` (sayfada yok!), `// @dart=` |
| [concurrency](https://dart.dev/language/concurrency) · [async](https://dart.dev/language/async) | 06 · 07 | Microtask kuyruğu sayfada yok; async ilk `await`'e kadar senkron |
| [isolates](https://dart.dev/language/isolates) | 09 | Robust ports, closure capture |
| [functions](https://dart.dev/language/functions) | 02 · 07 · ileride | Tear-off, generator'lar (`async*` → 07, `sync*` → ileride) |
| records, patterns, branches, generics, type-system, enums, extension-methods, extension-types, mixins, callable-objects, constructors, primary-constructors, dot-shorthands, error-handling, loops, null-safety | ileride | — |

## 4. Core kütüphaneler ve paketler

Kaynak: dart.dev [libraries](https://dart.dev/libraries) ve [useful-packages](https://dart.dev/resources/useful-packages)
("Packages that expand on Dart core libraries"); paketlerin reposu [dart-lang/core](https://github.com/dart-lang/core/tree/main/pkgs).
**Ana ders:** hangi API SDK'dan, hangisi paketten geliyor, her zaman belirtilir.

| SDK kütüphanesi | Tamamlayan paket | Konu | Flutter'da import |
| --- | --- | --- | --- |
| `dart:collection` | `package:collection` | 05 | 11 |
| `dart:async` | `package:async` | 06 · 07 · 08 | 0 |
| String / grapheme | `package:characters` | 01 | 5 |
| Anotasyonlar | `package:meta` | 04 | 11 |
| `dart:isolate` | — | 09 | — |
| `dart:convert`, `dart:typed_data` | `package:convert`, `package:typed_data` | ileride | 0 |
| Zones, stack trace | `package:stack_trace` | ileride | — |

## 5. Resmi dokümandaki boşluklar

| Konu | Bulgu | Gerçek kaynak |
| --- | --- | --- |
| `part` / `part of` | Language tour'da bölümü yok | `tools/pub/create-packages`, Effective Dart usage, SDK CHANGELOG 2.0 |
| Microtask kuyruğu | concurrency#event-loop'ta geçmiyor | api.dart.dev: `scheduleMicrotask` |
| Extension types min. sürüm | Sayfada version-note yok | SDK CHANGELOG 3.3.0 |
| "Enhanced parts" | CHANGELOG'da yok, yani çıkmadı | — |
| Zones, converters & codecs | Sayfa var, nav menüsünde yok | `libraries/async/zones`, `libraries/convert/converters-and-codecs` |

## 6. Sabit kararlar

| Konu | Karar |
| --- | --- |
| Hata modeli | `sealed class Result<T>` (`Ok` / `Err`) + sealed `Failure`; dartz yok |
| Union mu veri sınıfı mı | Varyantlar arası `switch` → native `sealed`; copyWith/JSON → freezed 3 |
| SDK | Her özellik min. dil sürümüyle etiketli; skill önce projenin `sdk` alt sınırını okur |
| Dil | Açıklamalar Türkçe; kod, identifier ve skill tetikleyicileri İngilizce |

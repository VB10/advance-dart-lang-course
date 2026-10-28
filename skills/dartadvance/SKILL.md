---
name: dartadvance
description: "Advanced Dart language rules with tested single-file examples: built-in types (money as int cents, % vs remainder, ~/ and %, num from JSON, tryParse, grapheme-safe truncation via package:characters, Turkish-safe slugs with raw-string RegExp, records as map keys, DateTime UTC/toLocal, late final vs getter, cascade and null-aware cascade), typedefs, class design (modifiers sealed/final/base/interface/mixin class, package:meta annotations @immutable/@useResult/@protected/@mustCallSuper, library privacy and part/part of), package:collection (firstWhereOrNull, groupBy, Equality, slices, sortedBy, PriorityQueue), fast_immutable_collections IList, null-aware elements, event loop and Future (Future.wait, timeout, unawaited), Streams (broadcast, async*, StreamController, subscriptions), package:async (CancelableOperation, AsyncMemoizer, AsyncCache, StreamQueue, StreamGroup), isolates (Isolate.run, ports). Use when the user asks to audit or fix their project against one of these Dart features, or invokes /dartadvance."
---

# dartadvance

İleri seviye Dart dili + Dart ekibinin core paketleri (collection, async, characters, meta). Her özellik için:
**ne olduğu, ne zaman kullanılacağı, ne zaman gerekmediği** ve testli **tek dosyalık** bir model.
State management ve framework konu dışı.

## Nasıl çalışır

İki kullanım var; kural dosyasındaki her bölümde ikisi için de bir prompt örneği bulunur:

- **Düzelt:** "Projemde … yerleri bul, … ile düzelt." Mevcut kodu kurala göre refactor et.
- **Üret:** "Bana … yaz." Kullanıcı kuralı söylemese bile yeni kodu kurala göre yaz.

Adımlar:

1. **SDK kontrolü:** hedef paketin `pubspec.yaml` → `environment: sdk:` alt sınırını oku; aşağıdaki tabloda
   alt sınırın üstündeki özelliği önerme.
2. **Kuralı bul:** konuyu [dizinden](#dizin) seç; o dosyada yalnız ilgili `## N.` bölümünü oku
   (`grep -n "^## " rules/NN-*.md`, sonra o bölümün başından sonraki `## `'ye kadar, **Kabul** satırı dahil).
   Dosyanın tamamını okuma. Birden çok bölüm uygulanıyorsa her birinin Kabul'unu ayrı doğrula.
3. **Düzelt ise:** önce projede ilgili kalıbı ara (`grep`), bulduğun her yeri listele, sonra tek tek düzelt.
   Bulamazsan "bulunamadı" de; kural uygulanacak yer uydurma. Düzeltme dönüş tipini değiştirirse
   (ör. `first` → nullable) çağıranları da güncelle. Projenin kendi hata tipi (`Result` vb.) varsa modeli ona uyarla.
   Bölümdeki `xxxWrong` metotları ve `// ✗` işaretli satırlar yanlış örnektir; modele kopyalama.
   **Üret ise:** bölümdeki kod bloğunu model al; kullanıcının alanına uyarla, isimleri kopyalama.
4. **Yaz:** bir dosya = bir kavram, ≤ 50 satır, yorum en az, iç içe en fazla 3 seviye, metinler kullanıcının dilinde.
   `dart create` şablon dosyalarına dokunma.
5. **Kanıtla:** bölümdeki **Kabul** satırını test et ve sonucu göster. Kabul bir derleme hatası içeriyorsa geçici olarak ihlal et,
   `dart analyze` hatasını göster, geri al. Kabul bir test ise o testin geçtiğini göster.
6. `dart format` · `dart analyze` (sıfır sorun) · `dart test`; çıktıyı göster. Sonunda 3 satır özet:
   hangi kural, hangi dosyalar, min. sürüm.

Daha basit yapı yetiyorsa ileri özelliği zorlama; her bölümdeki **Gerekmez** satırına uy.
Kural dosyası yoksa tahmin etme; dart.dev sayfasını oku
(`https://raw.githubusercontent.com/dart-lang/site-www/main/src/content/<yol>.md`).

## Kural bölümü nasıl kurulur

Her `## N.` bölümü gerçek bir Flutter ekranındaki tek hatayı anlatır. Yeni bölüm yazarken ya da örnek üretirken aynı kalıp:

- **Senaryo:** bir ekran ve bir iş (grup adı alanı, sepet özeti, OTP butonu, PATCH gövdesi). Sayı oyunu ya da "demo" yok.
- **Aynı girdi, iki metot:** `xxxWrong` (olumsuz, üstünde `// ✗` ve ekranda ne olduğu) ve `xxx` (olumlu). "naive" adı kullanılmaz.
- **Olumsuz sonuç ekranda görünür:** kapalı buton, alan hatası, yanlış dilde metin, silinen alan, çalışma anı hatası.
  İki taraf aynı sonucu veriyorsa o bölüm yazılmaz; "aynı sonuç, daha az kod" bölümü yok.
- **Hata başlıktaki özellikten gelir:** başlık `late final` diyorsa bozulmayı `late final` yapar, başka bir şey değil.
- Sonra **Tuzak** (testin adıyla), **Düzelt**, **Üret**, **Kabul**. Kaynak link dart.dev başlığına gider.
- Müşteri projelerinin adı ya da kodu yazılmaz; yalnız kalıp.

Her bölüm `examples/lib/NN_*/<ekran>.dart` dosyasından snippet olarak gelir ve `examples/test/NN_*` ile kanıtlanır;
aynı kural `examples/dart_advance_example` uygulamasında bozuk ve düzgün ekran olarak yan yana çizilir.

## Dizin

| # | Kural dosyası | Konu |
| --- | --- | --- |
| 01 | [rules/01-builtin-types.md](rules/01-builtin-types.md) | Kuruş `int`, `%`, `~/`, JSON `num`, `tryParse`, `characters`, Türkçe slug + raw `RegExp`, record anahtar, UTC `toLocal`, `late final`/getter, cascade, `?..` |
| 02 | [rules/02-typedefs.md](rules/02-typedefs.md) | Typedef ve yeni tip olmadığı |
| 03 | [rules/03-class-design.md](rules/03-class-design.md) | `sealed`, `final`, `base`, `interface`, `mixin class`; `@immutable`, `@useResult`, `@protected`, `@mustCallSuper`; `_` gizliliği, `part` |
| 04 | [rules/04-collection.md](rules/04-collection.md) | `firstWhereOrNull`, `groupBy`, Equality, `slices`, `sortedBy`, `PriorityQueue`, `IList`, `?` element |
| 05 | [rules/05-event-loop-future.md](rules/05-event-loop-future.md) | Event loop, `Future.wait`, timeout |
| 06 | [rules/06-streams.md](rules/06-streams.md) | Stream, broadcast, `async*`, abonelik |
| 07 | [rules/07-async-package.md](rules/07-async-package.md) | `CancelableOperation`, `AsyncMemoizer`, `AsyncCache`, `StreamQueue` |
| 08 | [rules/08-isolates.md](rules/08-isolates.md) | `Isolate.run`, port'lar |

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

## Veri tipi seçimi

Union/state hiyerarşisi → native `sealed`. `copyWith`/JSON gereken veri sınıfı → `freezed` 3
(sürümü `pubspec.lock`'tan doğrula). 1–3 alanlı davranışsız veri → record. Tek değerli ID → extension type.

## Kaynak

API detayı için hafızaya güvenme: dart.dev ve api.dart.dev. "Flutter'da gerçek kullanım" iddiaları kural
dosyasındaki sabit tag'li permalink'lere dayanır.

# 01 · Built-in types
> Kaynak: https://dart.dev/language/built-in-types · https://dart.dev/language/variables · https://dart.dev/language/operators · https://dart.dev/libraries/dart-core#numbers · https://dart.dev/effective-dart/usage#avoid-late-variables-if-you-need-to-check-whether-they-are-initialized · Min. sürüm: 3.7 (wildcard `_`), diğerleri her sürüm

Neden bu konu: Dart'ın temel tipleri sessiz hatalara açıktır (metin uzunluğu, bölme, değişmezlik); bu konu UI'da gösterilen metin, State'teki sayaçlar ve Domain sabitleri katmanlarında bu hataları önler.

## 1. Grapheme uzunluğu (`package:characters`)
**Ne:** `String.length` UTF-16 kod birimi sayar; kullanıcının gördüğü karakter için `characters` kullanılır. **Ne zaman:** karakter sınırı, kırpma, sayaç gösteren her UI metni. **Gerekmez:** yalnızca ASCII olduğu kesin olan kimlikler/kodlar.
<!-- snippet: 01_builtin_types/grapheme_length -->
```dart
// Düzelt: /dartadvance Projemde kullanıcıya görünen metni `length` ya da `substring` ile
//   sayan veya kesen yerleri bul, `characters` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana ürün başlığını en fazla 20 karakterle kısaltıp sonuna … ekleyen
//   ve karakter sayacı gösteren bir fonksiyon yaz.
import 'package:characters/characters.dart';

const wave = '👋🏽';

int codeUnitLength(String text) => text.length; // wave: 4

int visibleLength(String text) => text.characters.length; // wave: 1

String truncateBio(String bio, int maxCharacters) {
  final characters = bio.characters;
  if (characters.length <= maxCharacters) return bio;
  return '${characters.take(maxCharacters)}…';
}
```
**Tuzak:** `'👋🏽'.length` 4'tür, `substring` emojiyi ortadan bölüp yalnız bir surrogate bırakır (test: "substring by code units splits...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde kullanıcıya görünen metni `length` ya da `substring` ile sayan veya kesen yerleri bul, `characters` ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün başlığını en fazla 20 karakterle kısaltıp sonuna … ekleyen ve karakter sayacı gösteren bir fonksiyon yaz."
**Kabul:** `String.length`/`runes`/`substring` kullanılmaz (`characters.length` serbest); `'👨‍👩‍👦'` 1 karakter sayılır; kırpma testi tam sınırda (metin = sınır ve sınır + 1) yapılır; `dart analyze` temiz.

## 2. Tamsayı bölme ve kalan
**Ne:** `~/` `int` döndürür ve sıfıra doğru keser; `%` asla negatif olmaz, `remainder` bölünenin işaretini korur. **Ne zaman:** sayfalama, döngüsel indeks, saat/dakika hesabı. **Gerekmez:** ondalıklı sonuç isteniyorsa `/`.
<!-- snippet: 01_builtin_types/integer_division -->
```dart
// Düzelt: /dartadvance Projemde `/` sonucunu `toInt()`/`ceil()` ile tamsayıya çeviren ve
//   negatif değerde `%` kullanan yerleri bul, `~/` ve `remainder` ile düzelt, test yaz.
// Üret: /dartadvance Bana sipariş sayısı ve sayfa boyutundan toplam sayfa sayısını bulan ve
//   sayfalar arasında döngüsel ileri/geri giden fonksiyonlar yaz.

// Naive: goes through double just to get an int back.
int pagesNaive(int items, int size) => (items / size).ceil();

int pages(int items, int size) => (items + size - 1) ~/ size;

int truncatedHalf(int value) => value ~/ 2; // -7: -3

/// `%` is never negative, so it wraps a cyclic index.
int wrapIndex(int offset, int length) => offset % length; // (-1, 5): 4

/// `remainder` keeps the sign of the dividend.
int signedRemainder(int offset, int length) => offset.remainder(length); // (-1, 5): -1
```
Web'de `int` ve `double` aynı JS number semantiğini paylaşır (`1.0 is int` web'de true olur; [dart.dev](https://dart.dev/language/built-in-types#numbers)); testler VM'de koştuğu için burada test edilmez.
**Tuzak:** `-7 ~/ 2` değeri -3'tür (Python'daki gibi -4 değil) ve `(-1).remainder(5)` -1 verirken `-1 % 5` 4 verir (testler: "~/ truncates toward zero...", "% is never negative...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde `/` sonucunu `toInt()`/`ceil()` ile tamsayıya çeviren ve negatif değerde `%` kullanan yerleri bul, `~/` ve `remainder` ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş sayısı ve sayfa boyutundan toplam sayfa sayısını bulan ve sayfalar arasında döngüsel ileri/geri giden fonksiyonlar yaz."
**Kabul:** `double` dönüşümü kalmaz; `-7 ~/ 2` -3, `(-1) % 5` 4, `(-1).remainder(5)` -1 testle doğrulanır; `dart analyze` temiz.

## 3. `final` / `const` / `late final`
**Ne:** `final` bir kez atanır ama nesne değişebilir; `const` derleme zamanı sabiti ve derin değişmezdir; `late final` ilk okumada hesaplanır. **Ne zaman:** sabit liste/model için `const`, pahalı türetilmiş veri için `late final`. **Gerekmez:** `late`, constructor initializer list ile çözülebiliyorsa.
<!-- snippet: 01_builtin_types/variable_kinds -->
```dart
// Düzelt: /dartadvance Projemde değişmemesi gereken listeleri ve her okumada yeniden
//   hesaplanan getter'ları bul, `const` ve `late final` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana desteklenen para birimleri listesini ve faturaların müşteri adı
//   indeksini yalnızca bir kez hesaplayan bir sınıf yaz.

final recentSearches = <String>['dart']; // add works: final is not deep

const supportedLocales = ['en', 'tr']; // add throws UnsupportedError

final class ProductCatalog {
  ProductCatalog(this.names);
  final List<String> names;
  int indexBuilds = 0;

  // Naive: rebuilds the index on every read.
  Set<String> get indexEveryRead => _buildIndex();

  late final Set<String> lowercaseIndex = _buildIndex(); // builds once

  Set<String> _buildIndex() {
    indexBuilds++;
    return {for (final name in names) name.toLowerCase()};
  }

  bool contains(String query) => lowercaseIndex.contains(query.toLowerCase());
}
```
**Tuzak:** `final` liste `add` kabul eder, `const` liste `UnsupportedError` fırlatır (test: "a final list can still be mutated...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde değişmemesi gereken listeleri ve her okumada yeniden hesaplanan getter'ları bul, `const` ve `late final` ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana desteklenen para birimleri listesini ve faturaların müşteri adı indeksini yalnızca bir kez hesaplayan bir sınıf yaz."
**Kabul:** sabit liste `add`'de `UnsupportedError` verir; `late final` alanın hesaplama sayacı iki okumadan sonra 1; `dart analyze` temiz.

## 4. Wildcard `_` ve null-aware cascade (3.7)
**Ne:** `_` kullanılmayan değeri yok sayar ve artık birden fazla olabilir; `?..` cascade'i yalnızca alıcı null değilse çalıştırır; `...?` null listeyi boş sayar. **Ne zaman:** kullanılmayan callback parametreleri, opsiyonel nesneyi yapılandırma, opsiyonel liste birleştirme. **Gerekmez:** değer gerçekten kullanılıyorsa anlamlı isim ver.
<!-- snippet: 01_builtin_types/wildcards_and_null_aware -->
```dart
// Düzelt: /dartadvance Projemde `if (x != null)` ile null kontrolü yapıp atama veya liste
//   birleştirme yapan yerleri bul, `?..` ve `...?` ile sadeleştir, her biri için test yaz.
// Üret: /dartadvance Bana null olabilen bir Playlist'e başlık atayan ve null olabilen şarkı
//   listesini mevcut listeyle birleştiren bir fonksiyon yaz.

final class Cart {
  String? note;
}

Cart? withNoteVerbose(Cart? cart, String note) {
  if (cart != null) cart.note = note;
  return cart;
}

Cart? withNote(Cart? cart, String note) => cart?..note = note; // null in: null out

List<String> allTags(List<String> base, List<String>? extra) => [
  ...base,
  ...?extra, // null extra adds nothing
];

// Since Dart 3.7, several `_` parameters can coexist.
void Function(int, String) ignoreBoth = (_, _) {};

/// Since 3.7 the loop variable can be a wildcard when only the count matters.
String repeatLabel(String label, List<Object> items) {
  var out = '';
  for (final _ in items) {
    out += label;
  }
  return out;
} // ('x', [1, 2, 3]): xxx
```
**Tuzak:** `cart?..note = x` null alıcıda null döner, yeni nesne üretmez (test: "?.. skips the cascade on null...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde `if (x != null)` ile null kontrolü yapıp atama veya liste birleştirme yapan yerleri bul, `?..` ve `...?` ile sadeleştir, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana null olabilen bir Playlist'e başlık atayan ve null olabilen şarkı listesini mevcut listeyle birleştiren bir fonksiyon yaz."
**Kabul:** null girdide sonuç null, null liste boş sayılır; kullanılmayan parametreler `_` olur; `dart analyze` temiz.

## Flutter'da kanıt
- `TextField` uzunluğu `text.characters.length` ile sayar: [material/text_field.dart#L1185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/text_field.dart#L1185)
- `EditableText.onChanged` doc'u `string.length` kullanma der (👨‍👩‍👦: 8 / 5 / 1): [widgets/editable_text.dart#L1440](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/editable_text.dart#L1440)
- `LengthLimitingTextInputFormatter.truncate` grapheme sınırında keser: [services/text_formatter.dart#L543](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/text_formatter.dart#L543)
- `late final` controller (`this`'e ihtiyaç duyar): [cupertino/sliding_segmented_control.dart#L594](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/cupertino/sliding_segmented_control.dart#L594)
- `?..` kullanımı: [rendering/proxy_box.dart#L118](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/proxy_box.dart#L118)

## Kontrol listesi
- [ ] Kullanıcıya gösterilen metin uzunluğu `characters` ile sayılıyor.
- [ ] Bölme sonucu tamsayı lazımsa `~/` kullanıldı (`/` + `toInt()` değil).
- [ ] Negatif olabilecek indekste `%` ile `remainder` bilinçli seçildi.
- [ ] Sabit veri `const`, tek seferlik atama `final`.
- [ ] `late` yalnızca pahalı/`this` gerektiren başlatmada kullanıldı.
- [ ] Kullanılmayan değişken/parametre `_` ile işaretlendi.

## Pekiştirme
- **Kolay:** `clipTitle(String title, int max)` yaz; "Kahve ☕️🇹🇷" gibi bir başlık için testin emojiyi bölmediğini göstermesi yeterli.
- **Zor:** `Order?` alan, `?..` ile not ve etiket atayan, `...?` ile opsiyonel etiketleri birleştiren bir fonksiyon yaz; null girdi, boş ve dolu liste için üç test geçmeli.

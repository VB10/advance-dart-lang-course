# 01 · Built-in types
> Kaynak: https://dart.dev/language/built-in-types · https://dart.dev/language/variables · https://dart.dev/language/operators · https://dart.dev/libraries/dart-core#numbers · https://dart.dev/effective-dart/usage#avoid-late-variables-if-you-need-to-check-whether-they-are-initialized · Min. sürüm: 3.7 (wildcard `_`), diğerleri her sürüm

Dart'ın temel tipleri sessiz hatalara açıktır (metin uzunluğu, bölme, değişmezlik); bu konu UI'da gösterilen metin, State'teki sayaçlar ve Domain sabitleri katmanlarında bu hataları önler.

## 1. Grapheme uzunluğu (`package:characters`)
**Ne:** `String.length` UTF-16 kod birimi sayar; kullanıcının gördüğü karakter için `characters` kullanılır. **Ne zaman:** karakter sınırı, kırpma, sayaç gösteren her UI metni. **Gerekmez:** yalnızca ASCII olduğu kesin olan kimlikler/kodlar.
<!-- snippet: 01_builtin_types/grapheme_length -->
```dart
import 'package:characters/characters.dart';

/// What the user sees, not UTF-16 code units: '👋🏽'.length is 4.
int visibleLength(String text) => text.characters.length;

String truncateBio(String bio, int maxCharacters) {
  final characters = bio.characters;
  if (characters.length <= maxCharacters) return bio;
  return '${characters.take(maxCharacters)}…';
}
```
**Tuzak:** `'👋🏽'.length` 4'tür, `substring` emojiyi ortadan bölüp yalnız bir surrogate bırakır (test: "substring by code units splits...").
**Skill'e ver:** > "Bir ürün yorumu için 280 karakterlik sınır koyan `remainingCharacters(String review)` ve sınırı aşınca emoji bölmeden kesen `clipReview` yaz."
**Kabul:** `length`/`runes`/`substring` kullanılmaz; `'👨‍👩‍👦'` 1 karakter sayılır; `dart analyze` temiz.

## 2. Tamsayı bölme ve kalan
**Ne:** `~/` `int` döndürür ve sıfıra doğru keser; `%` asla negatif olmaz, `remainder` bölünenin işaretini korur. **Ne zaman:** sayfalama, döngüsel indeks, saat/dakika hesabı. **Gerekmez:** ondalıklı sonuç isteniyorsa `/`.
<!-- snippet: 01_builtin_types/integer_division -->
```dart
({int pages, int lastPageItems}) paginate(int itemCount, int pageSize) => (
  // `~/` truncates toward zero and returns an int, unlike `/`.
  pages: (itemCount + pageSize - 1) ~/ pageSize,
  lastPageItems: itemCount % pageSize == 0 ? pageSize : itemCount % pageSize,
);

/// `%` is never negative; `remainder` keeps the dividend's sign.
({int modulo, int remainder}) wrapOffset(int offset, int length) => (
  modulo: offset % length,
  remainder: offset.remainder(length),
);

int truncatedHalf(int value) => value ~/ 2;
```
**Tuzak:** `-7 ~/ 2` değeri -3'tür (Python'daki gibi -4 değil) ve `(-1).remainder(5)` -1 verirken `-1 % 5` 4 verir (testler: "~/ truncates toward zero...", "% is never negative...").
**Skill'e ver:** > "Bir sepetteki ürünleri kutulara `boxSize` adetlik gruplayan `boxesNeeded(int items, int boxSize)` yaz; `double` ve `.ceil()` kullanma."
**Kabul:** sonuç `int`; 0 ürün 0 kutu, 25 ürün ve 10'luk kutu 3 kutu verir; `dart analyze` temiz.

## 3. `final` / `const` / `late final`
**Ne:** `final` bir kez atanır ama nesne değişebilir; `const` derleme zamanı sabiti ve derin değişmezdir; `late final` ilk okumada hesaplanır. **Ne zaman:** sabit liste/model için `const`, pahalı türetilmiş veri için `late final`. **Gerekmez:** `late`, constructor initializer list ile çözülebiliyorsa.
<!-- snippet: 01_builtin_types/variable_kinds -->
```dart
final recentSearches = <String>['dart'];

const supportedLocales = ['en', 'tr'];

final class ProductCatalog {
  ProductCatalog(this.names);
  final List<String> names;
  int indexBuilds = 0;

  // Runs once, on first read, because it is `late`.
  late final Set<String> lowercaseIndex = _buildIndex();

  Set<String> _buildIndex() {
    indexBuilds++;
    return {for (final name in names) name.toLowerCase()};
  }

  bool contains(String query) => lowercaseIndex.contains(query.toLowerCase());
}
```
**Tuzak:** `final` liste `add` kabul eder, `const` liste `UnsupportedError` fırlatır (test: "a final list can still be mutated...").
**Skill'e ver:** > "Bir `Invoice` sınıfı yaz: KDV oranı `const`, satırlardan hesaplanan `total` ilk okumada bir kez hesaplanan `late final` olsun."
**Kabul:** hesaplama sayacı iki okumadan sonra 1; `const` liste değiştirilemez; `dart analyze` temiz.

## 4. Wildcard `_` ve null-aware cascade (3.7)
**Ne:** `_` kullanılmayan değeri yok sayar ve artık birden fazla olabilir; `?..` cascade'i yalnızca alıcı null değilse çalıştırır; `...?` null listeyi boş sayar. **Ne zaman:** kullanılmayan callback parametreleri, opsiyonel nesneyi yapılandırma, opsiyonel liste birleştirme. **Gerekmez:** değer gerçekten kullanılıyorsa anlamlı isim ver.
<!-- snippet: 01_builtin_types/wildcards_and_null_aware -->
```dart
final class Cart {
  final List<String> items = [];
  String? note;
}

// `?..` runs the cascade only when the cart is not null.
Cart? withNote(Cart? cart, String note) => cart?..note = note;

// `...?` spreads nothing when the list is null.
List<String> allTags(List<String> base, List<String>? extra) => [...base, ...?extra];

int countItems(List<Cart> carts) {
  var count = 0;
  for (final _ in carts) {
    count++;
  }
  return count;
}

// Since Dart 3.7, several `_` parameters can coexist.
void Function(int, String) ignoreBoth = (_, _) {};
```
**Tuzak:** `cart?..note = x` null alıcıda null döner, yeni nesne üretmez (test: "?.. skips the cascade on null...").
**Skill'e ver:** > "Nullable bir `UserProfile?` alıp `?..` ile `displayName` atayan ve `(_, _)` kullanan bir `onTap` callback'i yazan küçük bir örnek üret."
**Kabul:** null girdide sonuç null; `for (final _ in ...)` ve `(_, _)` derlenir; `dart analyze` temiz.

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

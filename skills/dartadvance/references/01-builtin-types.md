# 01 · Built-in types ve sık atlanan temel kavramlar

> Kaynak: https://dart.dev/language/built-in-types ·
> https://dart.dev/resources/language/number-representation ·
> https://dart.dev/libraries/dart-core#numbers ·
> https://dart.dev/language/variables ·
> https://dart.dev/language/operators ·
> https://dart.dev/language/keywords ·
> https://dart.dev/null-safety/understanding-null-safety#top-and-bottom
> Effective Dart: https://dart.dev/effective-dart/design#avoid-using-dynamic-unless-you-want-to-disable-static-checking,
> https://dart.dev/effective-dart/usage#avoid-late-variables-if-you-need-to-check-whether-they-are-initialized,
> https://dart.dev/effective-dart/usage#dont-use-late-when-a-constructor-initializer-list-will-do,
> https://dart.dev/effective-dart/usage#do-use-adjacent-strings-to-concatenate-string-literals
> Min. dil sürümü: çoğu her sürümde; **`>>>` 2.14**, **digit separators (`1_000_000`) 3.6**,
> **wildcard `_` 3.7** (her biri docs'ta `:::version-note` ile belirtilmiş).

Bu reference "herkesin bildiği" temellerin **docs'ta yazan ama çoğu zaman atlanan**
ayrıntılarını toplar: başlangıç anlatımı değildir. Her iddia bir dart.dev
cümlesine ve `examples/test/01_builtin_types/` altında bir teste dayanır.

## Sık yapılan yanlış varsayımlar (docs ne diyor)

| Yaygın varsayım | Docs | Kaynak |
|---|---|---|
| `int` her yerde 64-bit | Native'de −2⁶³…2⁶³−1; **web'de JS number**, güvenli aralık −2⁵³…2⁵³−1 | [#numbers](https://dart.dev/language/built-in-types#numbers) |
| `1.0 is int` her yerde false | Web'de **true**; `identical(1.0, 1)` web'de true, native'de false | [#types-and-type-checking](https://dart.dev/resources/language/number-representation#types-and-type-checking), [#identity](https://dart.dev/resources/language/number-representation#identity) |
| `1.0.toString()` her yerde `"1.0"` | Web'de `"1"` | [#string-representation](https://dart.dev/resources/language/number-representation#string-representation) |
| `~/` floor bölmesi yapar | Sıfıra doğru **keser**: `-7 ~/ 2 == -3`; `%` ise Öklid modu (hiç negatif değil) | [api: `~/`](https://api.dart.dev/dart-core/num/operator_truncate_divide.html), [api: `%`](https://api.dart.dev/dart-core/num/operator_modulo.html) |
| `String.length` karakter sayısıdır | **UTF-16 code unit** sayısıdır; `'👨‍👩‍👦'.length == 8`, `runes.length == 5` | [#strings](https://dart.dev/language/built-in-types#strings), [#runes-and-grapheme-clusters](https://dart.dev/language/built-in-types#runes-and-grapheme-clusters) |
| Görünüşü aynı iki string `==` | `==` **code unit dizisini** karşılaştırır; `'café' != 'café'` | [#strings](https://dart.dev/language/built-in-types#strings) (note) |
| Top-level/static değişken için lazy init `late` ister | Top-level ve class (static) değişkenler **zaten lazy**: ilk kullanımda çalışır | [#default-value](https://dart.dev/language/variables#default-value) |
| `final` liste değişmez | Referans değişmez, **içerik değişir**; yalnızca `const` nesne ve alanları immutable | [#final-and-const](https://dart.dev/language/variables#final-and-const) |
| `a?.b.c` için `c`'ye de `?.` gerekir | Null-shorting: alıcı null ise **zincirin tamamı** atlanır | [#smarter-null-aware-methods](https://dart.dev/null-safety/understanding-null-safety#smarter-null-aware-methods) |
| `sealed`, `on`, `show` isim olarak kullanılamaz | Bunlar **kısıtsız** keyword; her yerde identifier olabilir | [keywords](https://dart.dev/language/keywords) |

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| Hem tam sayı hem ondalık kabul eden değer (JSON sayısı) → `num`, sonra `.toDouble()`/`.toInt()` | Değer her zaman tam sayıysa → `int`; `num` yalnızca sınırda |
| Kullanıcı girdisi → `int.tryParse` (hata `null`) | Girdi bir sözleşmeyse ve bozuksa hata *olmalı* → `int.parse` (`FormatException`) |
| Kullanıcının gördüğü karakter (uzunluk, kırpma, maxLength) → `characters` paketi | Protokol/ID/ASCII string'i → `length`/`substring` yeterli |
| Her zaman fırlatan yardımcı → dönüş tipi `Never` | Hata bir `Result`/`Failure` olarak modellenecekse fırlatma yok (SKILL.md: `Result<T>`) |
| Her değeri kabul eden API → `Object?` (null hariç: `Object`) | `dynamic` → yalnızca statik kontrolü **bilerek** kapatmak için |
| Pahalı, belki hiç okunmayan ya da `this` isteyen alan → `late final x = ...` | Constructor initializer list yetiyorsa `late` gerekmez; "yüklendi mi?" sorusu varsa nullable alan |
| Derleme zamanında bilinen değer → `const` (canonical, deeply immutable) | Runtime'da hesaplanan tek atamalı değer → `final` |
| Kullanılmayan parametre/değişken → `_` (3.7+) | 3.7 altı SDK'da `_`, `__` isim olarak bağlanır |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Domain / Entity | Kesin tutar gerekiyorsa `int` minor unit (kuruş) — **tasarım önerisi**; docs yalnızca `double`'ın IEEE 754 64-bit kayan nokta olduğunu söyler |
| Data / Model | `jsonDecode` sonucu `Object?` üzerinde pattern: tam sayı alan `int x`, ondalık alan `num x` → `.toDouble()`. Bozuk veri → `Never` dönen `fail()` |
| Data / RepositoryImpl | `Never fail(...)` sonrası flow analysis tipi daraltır; `as` yerine pattern/`is` (fırlatmaz) |
| Application / state sınıfı (düz Dart) | "Henüz yüklenmedi" durumu → nullable alan veya sealed state; `late` değil (Effective Dart) |
| Presentation | Uzunluk sayacı, kırpma, `maxLength` → `characters`; `const` constructor'lı widget'lar (Flutter lint'i `prefer_const_constructors_in_immutables`) |
| Paylaşılan sabitler | `const` top-level; `static const` (sınıf seviyesinde) |

## Doğrulanmış örnekler

Tüm kod `examples/lib/01_builtin_types/` altında, testleri
`examples/test/01_builtin_types/` altında
(`dart run dartadvance_tool:dartadvance verify 01_builtin_types`). Testler VM'de
koşar; web davranışı yalnızca metinde, docs tablolarından aktarılır.

### Sayılar

[Numbers](https://dart.dev/language/built-in-types#numbers): `int` ve `double`,
`num`'un alt tipleridir; int literal gerektiğinde double'a çevrilir.

<!-- snippet: 01_builtin_types/num_type -->
```dart
num total = 1;
double ratio = 1; // Stored as 1.0: an int literal becomes a double here.

void addHalf() => total += 2.5;
```

`/` her zaman `double`, `~/` `int` döner. `~/` sıfıra doğru keser
([api](https://api.dart.dev/dart-core/num/operator_truncate_divide.html)); `%`
Öklid modudur ve işareti hep pozitiftir, `remainder` bölünenin işaretini korur
([api](https://api.dart.dev/dart-core/num/remainder.html)).

<!-- snippet: 01_builtin_types/integer_division -->
```dart
// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Model: Integer Division)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    -7 ~/ 2; // -3 döner (Python'daki // gibi -4 değil!)
//    Dart'ın ~/ operatörü tabana değil sıfıra yuvarlar.
//    Ayrıca: -7 % 2 == 1 (asla negatif olmaz) iken (-7).remainder(2) == -1 döner!
//
// 🎯 AMAÇ:
//    Dart'taki 5 farklı bölme ve kalan operatörünün davranışını tek bir
//    tip güvenli record ile kanıtlamak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana iki tamsayı için /, ~/, negatif tilde, modulo (%) ve remainder
//     hesaplayıp isimli bir record dönen divide fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/integer_division.dart
//    Test:  dart test test/01_builtin_types/division_test.dart
// ============================================================================

({double slash, int tilde, int negativeTilde, int modulo, int remainder}) divide(int a, int b) => (
  slash: a / b,
  tilde: a ~/ b,
  negativeTilde: -a ~/ b, // Truncates toward zero: -3, not -4.
  modulo: -a % b, // Euclidean: never negative.
  remainder: (-a).remainder(b), // Keeps the sign of the dividend.
);
```

Digit separator (3.6+) ve sabit aritmetik: sayı literal'leri ve operandları sabit
olan aritmetik ifadeler compile-time constant'tır.

<!-- snippet: 01_builtin_types/digit_separators -->
```dart
const oneMillion = 1_000_000;
const tiny = 0.000_000_000_01;
const macAddress = 0x00_14_22_01_23_45;
```

<!-- snippet: 01_builtin_types/const_arithmetic -->
```dart
const millisecondsPerSecond = 1000;
const secondsUntilRetry = 5;
const millisecondsUntilRetry = secondsUntilRetry * millisecondsPerSecond;
```

[Parsing](https://dart.dev/libraries/dart-core#numbers): `int.parse('0x42') == 66`,
`num.parse` mümkünse `int` üretir, `radix` tabanı belirler;
[`int.tryParse`](https://api.dart.dev/dart-core/int/tryParse.html) `parse`'ın
fırlatacağı yerde `null` döner.

<!-- snippet: 01_builtin_types/number_parsing -->
```dart
int? parseQuantity(String input) => int.tryParse(input.trim());

int parseHexColor(String hex) => int.parse(hex, radix: 16);
```

**Web farkları** ([Numbers in Dart](https://dart.dev/resources/language/number-representation)) —
docs "platforma özgü ve değişebilir" der:

| İfade | Native | Web | Bölüm |
|---|---|---|---|
| `math.pow(2, 53) + 1` | `9007199254740993` | `9007199254740992` | [#precision](https://dart.dev/resources/language/number-representation#precision) |
| `identical(1.0, 1)` | `false` | `true` | [#identity](https://dart.dev/resources/language/number-representation#identity) |
| `1.0 is int` / `double.infinity is int` | `false` / `false` | `true` / `true` | [#types-and-type-checking](https://dart.dev/resources/language/number-representation#types-and-type-checking) |
| `-1 >> 0` | `-1` | `4294967295` | [#bitwise-operations](https://dart.dev/resources/language/number-representation#bitwise-operations) |
| `1.0.toString()` | `"1.0"` | `"1"` | [#string-representation](https://dart.dev/resources/language/number-representation#string-representation) |

Docs önerileri ([#what-should-you-do](https://dart.dev/resources/language/number-representation#what-should-you-do)):
sayı içeren string'leri test ederken `"${20.0} cows"` gibi platformdan bağımsız yaz;
bit işlemlerinde 32-bit parçalarla çalış (`int.toSigned(32)`); hassasiyet gerekiyorsa
`BigInt` veya [`fixnum`](https://pub.dev/packages/fixnum) (daha büyük/yavaş kod).
Testler native sütununu doğrular (`numbers_test.dart`: `the VM matches the native column ...`).

### String'ler

Interpolation (`$x`, `${expr}`) ve **adjacent literal** birleştirme (`+` gerekmez,
satır sonlarını da aşar):

<!-- snippet: 01_builtin_types/string_interpolation -->
```dart
String greeting(String name, int unread) =>
    'Hi $name, you have ${unread + 1} new '
    'messages.'; // Adjacent literals: joined at compile time, no `+`.
```

Raw string (`r'...'`): `\` özel anlam taşımaz — RegExp için doğal seçim.

<!-- snippet: 01_builtin_types/raw_strings -->
```dart
final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
const rawNewline = r'\n'; // Two characters: `\` and `n`.
```

String literal, interpolasyondaki her ifade null/sayı/string/bool **sabiti** ise
compile-time constant'tır (sabit bir `List` interpolasyonu buna dahil değil):

<!-- snippet: 01_builtin_types/const_strings -->
```dart
const appName = 'Shop';
const buildNumber = 42;
const isBeta = true;

const userAgent = '$appName/$buildNumber beta=$isBeta';
```

### Runes ve grapheme cluster'lar

Dart string'i UTF-16 code unit dizisidir. [`String.length`](https://api.dart.dev/dart-core/String/length.html)
code unit, [`runes`](https://api.dart.dev/dart-core/String/runes.html) Unicode code
point sayar; **kullanıcının gördüğü karakter** (extended grapheme cluster) ikisi de
değildir. `==` da code unit karşılaştırır.

<!-- snippet: 01_builtin_types/code_units -->
```dart
const precomposed = 'café'; // é as one code point
const decomposed = 'café'; // e + combining acute accent

({int codeUnits, int runes}) measure(String text) =>
    (codeUnits: text.length, runes: text.runes.length);
```

| String | `length` | `runes.length` | Kullanıcı görür |
|---|---|---|---|
| `'Dart'` | 4 | 4 | 4 |
| `'\u{1D11E}'` (𝄞) | 2 | 1 | 1 |
| `'👋🏽'` (el + ten rengi) | 4 | 2 | 1 |
| `'👨‍👩‍👦'` | 8 | 5 | 1 |
| `'Hi 🇩🇰'` | 7 | 5 | 4 |

`'Hi 🇩🇰'.substring(hi.length - 1)` yarım bir surrogate döner (docs'taki `???`
çıktısı; test: `lone low surrogate`). Kullanıcı metnini saymak/kırpmak için
[`characters`](https://pub.dev/packages/characters) paketi (Dart ekibinin
`dart-lang/core` reposundaki paketlerden; Flutter framework'ü de kullanır, aşağıdaki tablo):

<!-- snippet: 01_builtin_types/grapheme_length -->
```dart
// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Model: Grapheme Length)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int count = '👋🏽'.length; // 4 döner!
//    text.substring(0, 3); // Emojiyi ortadan ikiye yarar, UI'da '' basar!
//
// 🎯 AMAÇ:
//    Görsel karakterleri (Grapheme Clusters) saymak ve metni kullanıcı
//    algısına uygun biçimde emojileri bozmadan güvenle kırpmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana package:characters kullanarak metnin ekranda görünen karakter
//     sayısını veren ve maxCharacters sınırına göre emojiyi bölmeden sonuna '…'
//     ekleyerek kesen bir truncate fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/grapheme_length.dart
//    Test:  dart test test/01_builtin_types/grapheme_test.dart
// ============================================================================

import 'package:characters/characters.dart';

int visibleLength(String text) => text.characters.length;

String truncate(String text, int maxCharacters) {
  final characters = text.characters;
  if (characters.length <= maxCharacters) return text;
  return '${characters.take(maxCharacters)}…';
}
```

Test: `visibleLength('👨‍👩‍👦') == 1`, `truncate('Hi 🇩🇰!', 4) == 'Hi 🇩🇰…'`.

### Booleans, special types, symbols

[Booleans](https://dart.dev/language/built-in-types#booleans): truthiness yok,
`if (nonBooleanValue)` derlenmez; boş string, sıfır, null, NaN açıkça kontrol edilir.

<!-- snippet: 01_builtin_types/explicit_booleans -->
```dart
bool shouldShowBadge(String label, int count, Object? error, double ratio) =>
    label.isNotEmpty && count != 0 && error == null && !ratio.isNaN;
```

Built-in types sayfasının "özel rolü olan tipler" listesi: `Object` (Null hariç tüm
sınıfların üst sınıfı), `Enum`, `Future`/`Stream`, `Iterable`, `Never`, `dynamic`,
`void` ("değer asla kullanılmaz", genelde dönüş tipi). `Object?` Dart'ın **top**,
`Never` **bottom** tipidir ([top-and-bottom](https://dart.dev/null-safety/understanding-null-safety#top-and-bottom)).

`Never`: ifade asla normal bitmez. `Never` dönen yardımcı, flow analysis'e sonraki
kodun erişilemez olduğunu söyler — `if (x is! T) fail(...)` sonrası `x` `T`'ye
daralır ([never-for-unreachable-code](https://dart.dev/null-safety/understanding-null-safety#never-for-unreachable-code)).
`Never` her tipin alt tipi olduğundan `bool`/`double` bekleyen yerde de kullanılabilir.

<!-- snippet: 01_builtin_types/never_helper -->
```dart
Never fail(String message) => throw FormatException(message);

int readCount(Object? raw) {
  if (raw is! int) fail('count must be an int, got $raw');
  return raw; // Promoted to int: `fail` never returns.
}
```

`Object?` vs `dynamic`: ikisi de her değeri kabul eder; `dynamic` ayrıca **her
işlemi** kabul eder ve hatayı runtime'a taşır (test: `unsafeLength(3)` →
`NoSuchMethodError`). Effective Dart: statik kontrolü bilerek kapatmıyorsan `Object?`/`Object`.

<!-- snippet: 01_builtin_types/object_vs_dynamic -->
```dart
String describeValue(Object? value) => switch (value) {
  null => 'nothing',
  String text => 'text of ${text.length} code units',
  int number => 'int $number',
  _ => value.toString(),
};

int unsafeLength(dynamic value) => value.length as int; // Compiles; fails at runtime for an int.
```

[Symbols](https://dart.dev/language/built-in-types#symbols): `#` + identifier,
compile-time constant; minification identifier adını değiştirir ama symbol'ü
değiştirmez. Çoğu uygulama kodunda gerekmez.

<!-- snippet: 01_builtin_types/symbols -->
```dart
int parseWithApply(String source, int radix) =>
    Function.apply(int.parse, [source], {#radix: radix}) as int;
```

### Değişkenler

[`final` vs `const`](https://dart.dev/language/variables#final-and-const): `const`
compile-time constant'tır (implicitly final); instance değişkeni `const` olamaz
(`static const` olur). `const` nesne ve alanları immutable'dır ve eşit sabit
ifadeler **tek canonical instance**'a çözülür ([`identical`](https://api.dart.dev/dart-core/identical.html)):
`identical(const [1], const [1])` true, `identical([1], [1])` false.

<!-- snippet: 01_builtin_types/final_vs_const -->
```dart
final recentSearches = <String>['dart'];

const supportedLocales = ['en', 'tr'];

final class Money {
  const Money(this.minorUnits, this.currency);
  final int minorUnits;
  final String currency;
}

const zeroTry = Money(0, 'TRY');
```

[Default value](https://dart.dev/language/variables#default-value): nullable
değişkenler `null` ile başlar (sayılar dahil, çünkü her şey nesnedir). Top-level
ve class değişkenleri **`late` olmadan da** lazy'dir:

<!-- snippet: 01_builtin_types/lazy_top_level -->
```dart
int configReads = 0;

int _loadConfig() {
  configReads++;
  return 30;
}

final class AppConfig {
  static final int timeoutSeconds = _loadConfig(); // Lazy without `late`.
}
```

[`late`](https://dart.dev/language/variables#late-variables) + initializer: ilk
okumada, bir kez çalışır ve `this`'e erişebilir
([lazy-initialization](https://dart.dev/null-safety/understanding-null-safety#lazy-initialization)).
Başlatılmamış `late` okunursa runtime hatası.

<!-- snippet: 01_builtin_types/late_initializer -->
```dart
final class SearchIndex {
  SearchIndex(this.items);
  final List<String> items;
  int builds = 0;

  late final Set<String> _lowercased = _build();

  Set<String> _build() {
    builds++;
    return {for (final item in items) item.toLowerCase()};
  }

  bool contains(String query) => _lowercased.contains(query.toLowerCase());
}
```

Dart `late` değişkenin başlatılıp başlatılmadığını sorgulamanın yolunu sunmaz; bu
soru gerekiyorsa nullable alan daha açıktır (Effective Dart):

<!-- snippet: 01_builtin_types/late_vs_nullable -->
```dart
final class ProfileCache {
  String? _name;

  bool get isLoaded => _name != null;
  String get name => _name ?? 'Guest';
  void load(String name) => _name = name;
}
```

[Wildcard `_`](https://dart.dev/language/variables#wildcard-variables) (3.7+):
bağlanmaz, initializer yine çalışır, aynı scope'ta birden fazla `_` olabilir.
Top-level veya library privacy'yi etkileyen üyelerde geçersizdir.

<!-- snippet: 01_builtin_types/wildcards -->
```dart
int countCallbacks(List<void Function(int, String)> callbacks) {
  var calls = 0;
  for (final _ in callbacks) {
    calls++;
  }
  return calls;
}

final List<int> sizes = ['a', 'bb'].map((_) => 0).toList();

void Function(int, String) ignoreBoth = (_, _) {};
```

### Operatörler

[`??` / `??=`](https://dart.dev/language/operators#conditional-expressions): sağ
taraf yalnızca sol taraf null ise değerlendirilir; `??=` yalnızca null iken atar
([assignment-operators](https://dart.dev/language/operators#assignment-operators)).

<!-- snippet: 01_builtin_types/if_null -->
```dart
String playerName(String? name) => name ?? 'Guest';

final class ThemeCache {
  String? _mode;
  int loads = 0;

  String get mode => _mode ??= _load();

  String _load() {
    loads++;
    return 'dark';
  }
}
```

`?.` null-shorting; `!` null ise runtime'da fırlatır
([other-operators](https://dart.dev/language/operators#other-operators)).

<!-- snippet: 01_builtin_types/null_shorting -->
```dart
final class Address {
  const Address(this.city);
  final String city;
}

final class Customer {
  const Customer(this.address);
  final Address address;
}

int? cityLength(Customer? customer) => customer?.address.city.length; // One `?.` is enough.
```

[Cascade](https://dart.dev/language/operators#cascade-notation): `..` alıcıyı
döndürür (bu yüzden `void` dönen `write` zincirlenebilir; `sb.write('a')..write('b')`
ise derlenmez). `?..` ilk işlemde kullanılırsa null alıcıda **hiçbir** cascade
işlemi denenmez.

<!-- snippet: 01_builtin_types/cascades -->
```dart
String buildQuery(Map<String, String> params) {
  final buffer = StringBuffer()..write('?');
  params.forEach(
    (key, value) => buffer
      ..write(key)
      ..write('=')
      ..write(value)
      ..write('&'),
  );
  return buffer.toString();
}

List<String>? appendDone(List<String>? log) => log
  ?..add('done')
  ..add('closed');
```

[Type test](https://dart.dev/language/operators#type-test-operators): `as`
yalnızca tipten eminsen; değilse `is`/`is!` ya da pattern — fırlatmazlar.

<!-- snippet: 01_builtin_types/type_tests -->
```dart
int castLength(Object value) => (value as String).length;

int? safeLength(Object value) => value is String ? value.length : null;

bool isNotText(Object value) => value is! String;

int? patternLength(Object value) => switch (value) {
  String(:final length) => length,
  _ => null,
};
```

[Spread](https://dart.dev/language/operators#spread-operators) gerçek bir operatör
değil, collection literal sözdizimidir; `...?` null koleksiyonda hiçbir şey eklemez.

<!-- snippet: 01_builtin_types/null_aware_spread -->
```dart
List<String> tags(List<String> base, List<String>? extra) => [...base, ...?extra];
```

[`>>>`](https://dart.dev/language/operators#bitwise-and-shift-operators) (2.14+)
işaretsiz sağa kaydırma. Docs örneği: `-value >> 4 == -0x03` yalnızca native'de;
web'de operandlar 32-bit'e kesildiği için sonuç farklıdır.

<!-- snippet: 01_builtin_types/shifts -->
```dart
const flags = 0x22;

int signedShift(int value) => value >> 4;

int unsignedShift(int value) => value >>> 4;
```

### Keywords

[Keywords](https://dart.dev/language/keywords) sayfası (veri: `site-www/src/data/keywords.yml`):

| Tür | Kural | Örnekler |
|---|---|---|
| Reserved (34 giriş) | Identifier **olamaz** | `class`, `const`, `final`, `is`, `new`, `var`, `void`, `with` |
| Built-in identifier (², 24) | Tip (class, mixin, enum, extension type, typedef), extension adı veya import prefix'i **olamaz**; başka her yerde olabilir | `type`, `get`, `set`, `required`, `late`, `dynamic`, `Function`, `interface`, `mixin` |
| Contextual (¹, 2) | Bağlama göre identifier olabilir | `await`, `yield` |
| Kısıtsız (³, 9) | Her yerde identifier olabilir | `async`, `base`, `hide`, `of`, `on`, `sealed`, `show`, `sync`, `when` |

Docs: izin verilse bile keyword'ü identifier yapmak okuyanı şaşırtır ve kaçınılmalıdır.
Pratikte JSON alan adları (`type`, `show`) model alanına dönüştüğünde işe yarar:

<!-- snippet: 01_builtin_types/keyword_identifiers -->
```dart
final class NotificationModel {
  const NotificationModel({required this.type, required this.show, required this.on});

  final String type; // Built-in identifier: fine as a field, not as a type name.
  final bool show;
  final DateTime on;
}
```

### Katmanlarda

Entity (kesin tutar için `int` minor unit — tasarım önerisi):

<!-- snippet: 01_builtin_types/product -->
```dart
final class Product {
  const Product({required this.id, required this.name, required this.priceMinor, this.rating});
  final int id;
  final String name;
  final int priceMinor; // Exact amount in kuruş/cents, not a double.
  final double? rating;
}
```

Model: tam sayı alan `int`, ondalık olabilen alan `num` → `.toDouble()`, bozuk veri
→ `Never`. Not: web'de `100.0 is int` true olduğundan (yukarıdaki tablo) `"price_minor": 100.0`
native'de reddedilir, web'de kabul edilir.

<!-- snippet: 01_builtin_types/product_json -->
```dart
import 'dart:convert';

import 'never_helper.dart';
import 'product.dart';

Product productFromJson(String source) {
  final Object? decoded = jsonDecode(source);
  if (decoded case {
    'id': int id,
    'name': String name,
    'price_minor': int priceMinor,
    'rating': num? rating,
  }) {
    return Product(id: id, name: name, priceMinor: priceMinor, rating: rating?.toDouble());
  }
  fail('Malformed product: $source'); // Never: no `return` needed after it.
}
```

<!-- snippet: 01_builtin_types/price_format -->
```dart
String formatPrice(int minorUnits) {
  final whole = minorUnits ~/ 100;
  final cents = (minorUnits % 100).toString().padLeft(2, '0');
  return '$whole,$cents ₺';
}
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib`
(`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`).

| Kullanım | Ne gösteriyor | Kaynak |
|---|---|---|
| `text.characters.length` (`TextField._currentLength`); `\.characters` **31** satır | Kullanıcı metni uzunluğu grapheme cluster ile sayılır | [material/text_field.dart#L1185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/text_field.dart#L1185) |
| `EditableText.onChanged` doc'u | "`string.length` veya `string.runes.length` kullanma"; 👨‍👩‍👦 için 8 / 5 / 1 | [widgets/editable_text.dart#L1440](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/editable_text.dart#L1440) |
| `LengthLimitingTextInputFormatter.truncate` | `CharacterRange` ile grapheme sınırında kırpma | [services/text_formatter.dart#L543](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/text_formatter.dart#L543) |
| `Never _unsupported() => throw UnsupportedError(...)`; `Never` dönen bildirim **6** (`^ *(static )?Never [a-zA-Z_]+\(`) | `Never` dönen yardımcı `bool`/`double`/`int` getter'larında kullanılıyor (bottom tip) | [painting/_web_image_info_io.dart#L38](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/_web_image_info_io.dart#L38) |
| `Never scale(double fontSize) => throw UnimplementedError();` | Override'da `double` yerine `Never` dönüş (kovaryant dönüş) | [widgets/media_query.dart#L2466](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/media_query.dart#L2466) |
| `const double precisionErrorTolerance = 1e-10`; **55** satır | Double karşılaştırmalarında tolerans sabiti | [foundation/constants.dart#L71](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/constants.dart#L71) |
| `const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop')`; **110** satır | Web'e özgü davranış için compile-time sabit | [foundation/constants.dart#L83](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/constants.dart#L83) |
| `late final AnimationController thumbController = AnimationController(vsync: this, ...)`; `late final ` **324** satır, initializer'lı **186** (`late final [A-Za-z<>?, ]+ [a-zA-Z_]+ = `) | Docs'taki "initializer `this`'e ihtiyaç duyuyor" durumu | [cupertino/sliding_segmented_control.dart#L594](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/cupertino/sliding_segmented_control.dart#L594) |
| `(child?..layout(constraints, parentUsesSize: true))?.size ?? ...`; `?..` **7** satır | Null-aware cascade alıcıyı döndürür, sonra `?.`/`??` ile devam | [rendering/proxy_box.dart#L118](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/proxy_box.dart#L118) |
| `(hash >>> bitIndex) & hashBitsPerLevelMask`; ` >>> ` **3** satır | İşaretsiz kaydırma (hash trie indeksi) | [foundation/persistent_hash_map.dart#L67](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/persistent_hash_map.dart#L67) |
| `final int? year = int.tryParse(inputParts[2], radix: 10)`; `int\.tryParse\(` **5** satır | Kullanıcı tarih girdisi: `tryParse` + null kontrolü | [material/material_localizations.dart#L915](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/material_localizations.dart#L915) |

Ek sayım: `^  const [A-Z][A-Za-z0-9_]*(\.[a-zA-Z_]+)?\(\{` (named parametreli const
constructor) **926** satır.

## Lint'ler

| Lint | Set | Ne yapar |
|---|---|---|
| [prefer_adjacent_string_concatenation](https://dart.dev/tools/linter-rules/prefer_adjacent_string_concatenation) | recommended | Literal'leri `+` yerine yan yana yaz |
| [prefer_interpolation_to_compose_strings](https://dart.dev/tools/linter-rules/prefer_interpolation_to_compose_strings) | recommended | String + değer için interpolation |
| [unnecessary_string_interpolations](https://dart.dev/tools/linter-rules/unnecessary_string_interpolations) | recommended | `'$s'` gibi gereksiz interpolation |
| [unnecessary_null_aware_assignments](https://dart.dev/tools/linter-rules/unnecessary_null_aware_assignments) | recommended | `x ??= null` gibi anlamsız atama |
| [prefer_if_null_operators](https://dart.dev/tools/linter-rules/prefer_if_null_operators) | recommended | `x != null ? x : y` yerine `??` |
| [prefer_is_not_operator](https://dart.dev/tools/linter-rules/prefer_is_not_operator) | recommended | `!(x is T)` yerine `is!` |
| [avoid_init_to_null](https://dart.dev/tools/linter-rules/avoid_init_to_null) | recommended | Nullable zaten `null` başlar; `= null` yazma |
| [unnecessary_late](https://dart.dev/tools/linter-rules/unnecessary_late) | recommended | Initializer'lı top-level/static'te `late` gereksiz (zaten lazy) |
| [unnecessary_underscores](https://dart.dev/tools/linter-rules/unnecessary_underscores) | recommended | `__`, `___` yerine tek wildcard `_` |
| [no_wildcard_variable_uses](https://dart.dev/tools/linter-rules/no_wildcard_variable_uses) | core (→ recommended) | `_` isimli değişkeni okumayı yasaklar |
| [prefer_const_constructors](https://dart.dev/tools/linter-rules/prefer_const_constructors) | hiçbiri (opsiyonel) | Const constructor'ı `const` ile çağır |
| [prefer_const_declarations](https://dart.dev/tools/linter-rules/prefer_const_declarations) | hiçbiri (opsiyonel) | Sabit değerli `final` yerine `const` |
| [prefer_const_constructors_in_immutables](https://dart.dev/tools/linter-rules/prefer_const_constructors_in_immutables) | flutter_lints | `@immutable` sınıflarda const constructor |
| [avoid_dynamic_calls](https://dart.dev/tools/linter-rules/avoid_dynamic_calls) | hiçbiri (opsiyonel) | `dynamic` hedefte metot/property erişimini işaretler |
| [avoid_double_and_int_checks](https://dart.dev/tools/linter-rules/avoid_double_and_int_checks) | hiçbiri (opsiyonel) | Web'de yanıltıcı `is int`/`is double` dallanması |

## Kontrol listesi

- [ ] Web hedefi var mı? `int` > 2⁵³, bit işlemleri, `is int`/`is double`, sayı→string testleri platform farkı yaratır.
- [ ] Negatif sayıda `~/` (sıfıra doğru) ve `%` (Öklid) sonucunu biliyor musun?
- [ ] Kullanıcı metninde uzunluk/kırpma `characters` ile mi? (`length`/`substring` değil)
- [ ] Kullanıcı girdisi `tryParse`, sözleşme verisi `parse`.
- [ ] JSON sayısı: tam sayı alan `int`, ondalık alan `num` → `.toDouble()`.
- [ ] `dynamic` yerine `Object?`/`Object`; `as` yerine pattern/`is`.
- [ ] Her zaman fırlatan yardımcı `Never` dönüyor.
- [ ] `late` yerine initializer list ya da nullable alan düşünüldü; top-level/static zaten lazy.
- [ ] Derleme zamanı sabitler `const`; `final` koleksiyonun içeriği hâlâ değişebilir.
- [ ] `_` (3.7+) ve digit separator (3.6+) için SDK alt sınırı yeterli.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: Kesin tutarlı entity ve fiyat biçimleme
- **Demo promptu:** "Fatura satırı için tutarı kuruş olarak tutan bir entity ve ekranda `12,05 ₺` biçiminde gösteren bir fonksiyon yaz."
- **Model:** [`examples/lib/01_builtin_types/product.dart`](../../../examples/lib/01_builtin_types/product.dart), [`examples/lib/01_builtin_types/price_format.dart`](../../../examples/lib/01_builtin_types/price_format.dart)
- **Katman:** Domain / Entity + Presentation
- **Adımlar:** 1. Entity'yi `final class` yap; tutarı `double` değil `int` minor unit alanı olarak tut. 2. Ondalık olabilen, kesinlik gerektirmeyen alanları (puan vb.) `double?` bırak. 3. Biçimlendirmeyi ayrı bir Presentation fonksiyonuna koy: tam kısım `~/ 100`, küsurat `% 100` + `padLeft(2, '0')`. 4. Negatif tutar olasılığı varsa `~/`'ın sıfıra doğru kestiğini testte göster.
- **Kabul kriteri:** `0.1 + 0.2` tipi kayıp yok: `7` minor unit `0,07` olarak, `4550` `45,50` olarak biçimlenir; entity'de `double` tutar alanı yoktur.
- **Min. sürüm:** her sürüm (`final class` için 3.0)

### Tarif: JSON sayılarını doğru tipe çeviren Model
- **Demo promptu:** "Kargo JSON'undan ağırlığı (`4` veya `4.5` gelebilir) ve adet bilgisini (`int`) okuyan, bozuk veride `Never` dönen `fail` ile duran bir `fromJson` yaz."
- **Model:** [`examples/lib/01_builtin_types/product_json.dart`](../../../examples/lib/01_builtin_types/product_json.dart), [`examples/lib/01_builtin_types/never_helper.dart`](../../../examples/lib/01_builtin_types/never_helper.dart)
- **Katman:** Data / Model
- **Adımlar:** 1. `jsonDecode` sonucunu `Object?` değişkene al; `dynamic` ve `as` kullanma. 2. `if (decoded case {...})` map pattern'i ile her alanı tipiyle eşleştir: tam sayı alan `int`, ondalık olabilen alan `num` → `.toDouble()`. 3. Eşleşme yoksa `Never` dönen bir `fail(...)` yardımcısı çağır; ardından `return` yazma. 4. JSON'daki `type`, `show`, `on` gibi alan adları model alanına aynen dönüşebilir (kısıtsız keyword / built-in identifier).
- **Kabul kriteri:** Tam sayı ondalık alan (`4`) `double` olarak döner; `int` beklenen alanda `45.5` `FormatException` fırlatır; `null` izinli alan `null` kalır.
- **Min. sürüm:** 3.0 (patterns)

### Tarif: Fırlatan parse'ı `Result`'a saran Data fonksiyonu
- **Demo promptu:** "Sipariş JSON metnini `Result<Order>` olarak çözen, bozuk JSON'da ve yanlış tipte alanda çökmeyip `Err` dönen bir fonksiyon yaz."
- **Model:** [`examples/lib/01_builtin_types/practice/ex3_decode_product.dart`](../../../examples/lib/01_builtin_types/practice/ex3_decode_product.dart)
- **Katman:** Data / RepositoryImpl sınırı
- **Adımlar:** 1. Eşleşmeyi `switch` expression'lı küçük private bir `_match(Object?)` yardımcısına taşı (eşleşmezse `null`). 2. Ana fonksiyonda `try` içinde `jsonDecode` + `_match`; `null` ise `Never` dönen `fail` çağır. 3. `on FormatException catch (error, stackTrace)` ile `Err(UnexpectedFailure(...))` dön. 4. Başarıda `Ok(...)`.
- **Kabul kriteri:** Geçersiz JSON metni ve `int` alanda ondalık değer `Err<UnexpectedFailure>` döner, hata `FormatException` taşır; test hiçbir durumda exception görmez.
- **Min. sürüm:** 3.0

### Tarif: Grapheme'e göre sayan ve kırpan metin state'i
- **Demo promptu:** "Ürün yorumu alanı için 280 karakter sınırlı, emoji ve bayrakları tek karakter sayan ve kırparken bölmeyen bir state sınıfı yaz."
- **Model:** [`examples/lib/01_builtin_types/practice/ex2_comment_draft.dart`](../../../examples/lib/01_builtin_types/practice/ex2_comment_draft.dart), [`examples/lib/01_builtin_types/grapheme_length.dart`](../../../examples/lib/01_builtin_types/grapheme_length.dart)
- **Katman:** Application / state sınıfı (düz Dart) + Presentation
- **Adımlar:** 1. `package:characters` bağımlılığını ekle. 2. Sayacı `text.characters.length` ile hesapla; `length`/`runes` kullanma. 3. Sınır aşılınca `characters.take(max)` ile kırp. 4. Testte bir ZWJ aile emoji'si ve bir bayrak kullan.
- **Kabul kriteri:** `'👨‍👩‍👦'` bir karakter sayılır (`length` 8 olsa da); bayrak içeren metin sınırda kırpıldığında bayrak yarım kalmaz.
- **Min. sürüm:** her sürüm (`characters` paketi)

### Tarif: Güvenli girdi okuma ve negatif sayıda bölme
- **Demo promptu:** "Takvim ekranı için kullanıcının yazdığı gün farkını `tryParse` ile okuyan ve negatif farkta da 0..6 hafta günü indeksi veren yardımcıları yaz."
- **Model:** [`examples/lib/01_builtin_types/number_parsing.dart`](../../../examples/lib/01_builtin_types/number_parsing.dart), [`examples/lib/01_builtin_types/practice/ex1_floor_division.dart`](../../../examples/lib/01_builtin_types/practice/ex1_floor_division.dart)
- **Katman:** Presentation (girdi) + Domain (hesap)
- **Adımlar:** 1. Kullanıcı girdisini `int.tryParse(input.trim())` ile oku; `null` = geçersiz. 2. Sözleşme verisinde (bozuksa hata olmalı) `int.parse` kullan. 3. Döngüsel indeks için `%` (Öklid) kullan; `remainder` değil. 4. Aşağı yuvarlayan bölme gerekiyorsa `(a - a % b) ~/ b`; pozitif olmayan bölende `ArgumentError`.
- **Kabul kriteri:** `-1` gün farkı `6` verir; `-7` için aşağı bölme `-4`, `~/` `-3`; `'x'` girdisi `null` döner, exception yok.
- **Min. sürüm:** her sürüm

### Tarif: Sabitler, tembel alanlar ve null-aware okuma
- **Demo promptu:** "Bildirim ayarları için derleme zamanı sabitlerini, ilk okumada bir kez hesaplanan bir önbelleği ve 'yüklendi mi?' sorusunu cevaplayan bir alanı olan sınıflar yaz."
- **Model:** [`examples/lib/01_builtin_types/final_vs_const.dart`](../../../examples/lib/01_builtin_types/final_vs_const.dart), [`examples/lib/01_builtin_types/late_initializer.dart`](../../../examples/lib/01_builtin_types/late_initializer.dart), [`examples/lib/01_builtin_types/late_vs_nullable.dart`](../../../examples/lib/01_builtin_types/late_vs_nullable.dart), [`examples/lib/01_builtin_types/if_null.dart`](../../../examples/lib/01_builtin_types/if_null.dart)
- **Katman:** Paylaşılan sabitler + Application / state sınıfı
- **Adımlar:** 1. Derleme zamanında bilinen değerleri `const` yap (büyük sayılarda digit separator, 3.6+); runtime değerleri `final`. 2. Pahalı, belki hiç okunmayan alanı `late final x = _build();` yap; top-level/static alana `late` ekleme (zaten lazy). 3. "Yüklendi mi?" sorusu varsa `late` değil nullable alan + `??` varsayılanı. 4. Tek seferlik önbellek için `_value ??= _load()`. 5. Null zincirde tek `?.` (null-shorting), null liste için `...?`, kullanılmayan parametre için `_` (3.7+).
- **Kabul kriteri:** Initializer sayaçla ölçülür: ilk okumadan önce 0, iki okumadan sonra 1; `const` koleksiyona ekleme `UnsupportedError`; nullable alan başta `null`.
- **Min. sürüm:** 3.6 (digit separator), 3.7 (`_`); diğerleri her sürüm

## Pekiştirme

### Alıştırma 1 · Negatif sayıda bölme ve mod (kolay)
`int floorDiv(int a, int b)` yaz: pozitif bölen için **aşağı yuvarlayan** bölme
(`floorDiv(-7, 2) == -4`, oysa `-7 ~/ 2 == -3`); bölen pozitif değilse
`ArgumentError` fırlatsın. Ardından `int weekdayIndex(int offset)` yaz: bir
Pazartesi'den `offset` gün sonraki günün 0..6 indeksini döndürsün; "dün"
(`offset == -1`) için `6` dönmeli, `-1` değil.

**İpucu:** `~/` sıfıra doğru keser, `%` Öklid modudur ve hiç negatif olmaz; bu ikisini birleştir ([api: `~/`](https://api.dart.dev/dart-core/num/operator_truncate_divide.html), [api: `%`](https://api.dart.dev/dart-core/num/operator_modulo.html)).

<details><summary>Çözüm</summary>

<!-- snippet: 01_builtin_types/practice/ex1_floor_division -->
```dart
// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 1)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int day = -7 ~/ 2; // Sonuç: -3 döner! Beklenen: -4.
//    Dart'ın ~/ operatörü tabana (floor) değil sıfıra doğru yuvarlar (truncate).
//    Takvimde 7 gün geriye gitmek istediğinizde gün Pazar yerine Cumartesiye kayar!
//
// 🎯 AMAÇ:
//    Negatif sayıları da matematiksel olarak tabana yuvarlayan (floor division)
//    ve haftanın gün ofsetini (0-6) asla kaydırmayan güvenli bir takvim yardımcısı.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana negatif sayıları da güvenle tabana yuvarlayan (floor division)
//     ve haftalık gün ofsetini (0-6) doğru hesaplayan bir takvim fonksiyonu yaz.
//     Örnek: floorDiv(-7, 2) == -4 olmalı ve negatif böleni reddetmeli."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex1_floor_division.dart
//    Test:  dart test test/01_builtin_types/practice/ex1_floor_division_test.dart
// ============================================================================

int floorDiv(int a, int b) {
  if (b <= 0) throw ArgumentError.value(b, 'b', 'must be positive');
  return (a - a % b) ~/ b; // `%` is never negative, so this rounds down.
}

int weekdayIndex(int offset) => offset % 7;
```

</details>

### Alıştırma 2 · Yorum alanı sayacı (orta)
Application katmanında düz Dart bir `CommentDraft` state sınıfı yaz:
`maxLength`, `text`, ekrandaki sayaç için `remaining` ve metni güncelleyen
`update(String)`. `'Hi 👨‍👩‍👦'` 4 karakter sayılmalı (`length` 11 olsa da), limit
aşıldığında kırpma bir bayrağı veya emoji'yi **ortadan bölmemeli**
(`maxLength: 4` ile `'Hi 🇩🇰!'` → `'Hi 🇩🇰'`).

**İpucu:** Kullanıcının gördüğü karakter `length` da `runes` da değildir; bkz. yukarıdaki "Runes ve grapheme cluster'lar" ve [#runes-and-grapheme-clusters](https://dart.dev/language/built-in-types#runes-and-grapheme-clusters).

<details><summary>Çözüm</summary>

<!-- snippet: 01_builtin_types/practice/ex2_comment_draft -->
```dart
// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 2)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int remaining = maxLength - _text.length;
//    Kullanıcı tek bir emoji ('👋🏽') girdiğinde Dart `.length == 4` sayar!
//    Kullanıcı ekranda 1 karakter görürken sistem 4 karakter harcar;
//    SMS sınırı veya tweet sınırı vaktinden önce dolar, kullanıcı çıldırır!
//
// 🎯 AMAÇ:
//    Grapheme cluster (`package:characters`) kullanarak kullanıcı gözündeki
//    gerçek karakterleri sayan ve sınırı aşan kısmı emojiyi parçalamadan kesen
//    temiz bir `CommentDraft` form state sınıfı yazmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana package:characters kullanarak emojileri tek karakter sayan,
//     maxLength sınırını aşan girdiyi doğru noktadan kesen ve remaining
//     kalan karakter sayısını hesaplayan bir CommentDraft sınıfı yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex2_comment_draft.dart
//    Test:  dart test test/01_builtin_types/practice/ex2_comment_draft_test.dart
// ============================================================================

import 'package:characters/characters.dart';

final class CommentDraft {
  CommentDraft({required this.maxLength});

  final int maxLength;
  String _text = '';

  String get text => _text;

  int get remaining => maxLength - _text.characters.length;

  void update(String input) {
    final characters = input.characters;
    _text = characters.length <= maxLength ? input : characters.take(maxLength).toString();
  }
}
```

</details>

### Alıştırma 3 · JSON'dan `Result<Product>` (zor)
Data katmanında `Result<Product> decodeProduct(String source)` yaz (`product.dart`'taki
`Product` entity'si ve `00_architecture` `Result`). `dynamic` ve `as` yok:
`jsonDecode` sonucu `Object?` üzerinde pattern kullan. `price_minor` yalnızca
`int` kabul etsin (`19.99` → `Err`), `rating` `4` gelse de `double` `4.0`
olsun, `null` kalabilsin. Bozuk JSON metni ve eşleşmeyen alanlar fırlatmak yerine
`Err(UnexpectedFailure(...))` dönsün.

**İpucu:** Ondalık olabilen alan `num` → `.toDouble()`; `Never` dönen `fail()` sonrası `return` gerekmez, fırlattığı `FormatException`'ı sınırda yakala ([never-for-unreachable-code](https://dart.dev/null-safety/understanding-null-safety#never-for-unreachable-code)).

<details><summary>Çözüm</summary>

<!-- snippet: 01_builtin_types/practice/ex3_decode_product -->
```dart
// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 3)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    final rating = json['rating'] as double;
//    Backend'den puan 4.5 gelince çalışan kod, tam puan 4 (int) gelince patlar:
//    "type 'int' is not a subtype of type 'double' in type cast" crash'i gelir!
//    Çünkü Dart'ta (native VM) int, double'ın alt tipi değildir.
//
// 🎯 AMAÇ:
//    JSON sayılarını pattern matching ile `num?` olarak yakalayıp `.toDouble()`
//    ile dönüştürmek ve sonucu Clean Architecture `Result<Product>` içine sarmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana JSON string'ini güvenle parse eden, rating alanı int veya double
//     gelebilen, hata durumunda UnexpectedFailure ile Result<Product> dönen
//     bir decodeProduct fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex3_decode_product.dart
//    Test:  dart test test/01_builtin_types/practice/ex3_decode_product_test.dart
// ============================================================================

import 'dart:convert';

import '../../00_architecture/result.dart';
import '../never_helper.dart';
import '../product.dart';

Product? _match(Object? json) => switch (json) {
  {
    'id': int id,
    'name': String name,
    'price_minor': int priceMinor,
    'rating': num? rating,
  } =>
    Product(id: id, name: name, priceMinor: priceMinor, rating: rating?.toDouble()),
  _ => null,
};

Result<Product> decodeProduct(String source) {
  try {
    final product = _match(jsonDecode(source));
    if (product == null) fail('Malformed product: $source');
    return Ok(product);
  } on FormatException catch (error, stackTrace) {
    return Err(UnexpectedFailure(error, stackTrace));
  }
}
```

</details>

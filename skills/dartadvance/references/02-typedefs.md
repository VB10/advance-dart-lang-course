# 02 · Typedefs

> Kaynak: https://dart.dev/language/typedefs ·
> Effective Dart: https://dart.dev/effective-dart/design#dont-use-the-legacy-typedef-syntax,
> https://dart.dev/effective-dart/design#prefer-inline-function-types-over-typedefs
> Min. dil sürümü: fonksiyon typedef'leri her sürümde; **fonksiyon olmayan tipler için typedef 2.13**;
> record tipine typedef 3.0 (records).

Typedef (type alias) bir tipe **yeni bir isim** verir, **yeni bir tip yaratmaz**.
Bütün kararlar bu cümleden çıkar.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
| --- | --- |
| Uzun veya sık tekrarlanan tip: `Map<String, Object?>` → `Json` | Tek yerde geçen fonksiyon tipi → **inline** yaz (`void Function(String)`) |
| Bir widget'ın/sınıfın dışarıya verdiği **callback sözleşmesi** (`ValueChanged<T>` tarzı) | Tip güvenli ID/value object → **extension type** (ileride: Extension types). `typedef UserId = int` her `int`'i kabul eder |
| Çok yerde kullanılan generic fonksiyon tipi (`Mapper<S, T>`) | Davranış veya invariant gerekiyorsa → **class** |
| Private yardımcı fonksiyonların record dönüşüne isim (`_Partition`) | Katmanlar arası public API'de record alias → sınıf/entity tercih et (ileride: Records) |

## Mimarideki yeri

| Katman | Kullanım |
| --- | --- |
| Data / Model, DataSource | `typedef Json = Map<String, Object?>`, `JsonList`; generic `Mapper<S, T>` |
| Data (private helper) | `typedef _X = ({...})` record alias (yalnızca dosya içi) |
| Domain / Repository | Çok parametreli fonksiyon tipleri tekrar ediyorsa (nadiren) |
| Presentation | Widget callback'leri: `typedef UserTapCallback = void Function(UserId id)` |

`dynamic` yerine `Object?`: `strict-casts` açıkken her okuma ya kontrol edilir ya
pattern ile eşleşir. JSON doğrulaması için bkz. ileride Patterns konusu.

## Doğrulanmış örnekler

Tüm kod `examples/lib/02_typedefs/` altında, testleri `examples/test/02_typedefs/`
altında (`dart run dartadvance_tool:dartadvance verify 02_typedefs`).

### Resmi örnekler (dart.dev)

<!-- snippet: 02_typedefs/int_list -->
```dart
typedef IntList = List<int>;
IntList il = [1, 2, 3];
```

<!-- snippet: 02_typedefs/list_mapper -->
```dart
typedef ListMapper<X> = Map<X, List<X>>;
Map<String, List<String>> m1 = {}; // Verbose.
ListMapper<String> m2 = {}; // Same thing but shorter and clearer.
```

Fonksiyon typedef'i: bir fonksiyon, imzası uyan typedef'in örneğidir (`sort is Compare<int>` → true).

<!-- snippet: 02_typedefs/compare_function -->
```dart
typedef Compare<T> = int Function(T a, T b);

int sort(int a, int b) => a - b;
```

### Data: JSON tip adları

`dynamic` değil `Object?`: `strict-casts` açıkken her okuma kontrol edilir ya da pattern ile eşleşir.

<!-- snippet: 02_typedefs/json_alias -->
```dart
typedef Json = Map<String, Object?>;
typedef JsonList = List<Json>;
```

### Data: generic mapper typedef

<!-- snippet: 02_typedefs/generic_mapper -->
```dart
typedef Mapper<S, T> = T Function(S source);

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source),
];
```

### Data: private record alias

Flutter'ın `list_tile.dart`'taki `_Sizes`'ı ile aynı hamle: alias dosya içinde kalır, katman sınırını geçmez.

<!-- snippet: 02_typedefs/private_record_alias -->
```dart
import '../00_architecture/user_feature.dart' show User, UserId;
import 'generic_mapper.dart';
import 'json_alias.dart';

typedef _Partition = ({JsonList valid, int skipped});

_Partition _partition(JsonList rows) {
  final valid = [
    for (final row in rows)
      if (row case {'id': int(), 'name': String()}) row,
  ];
  return (valid: valid, skipped: rows.length - valid.length);
}

User _toUser(Json row) => User(id: UserId(row['id']! as int), name: row['name']! as String);

List<User> parseUsers(JsonList rows) {
  final (:valid, :skipped) = _partition(rows);
  if (skipped > 0) print('parseUsers: skipped $skipped malformed row(s)');
  return mapAll(valid, _toUser);
}
```

### Presentation: callback sözleşmeleri

Flutter'ın `ValueChanged<T>` / `FormFieldValidator<T>` tarzı: widget'ın üst katmana verdiği isimli sözleşme.

<!-- snippet: 02_typedefs/callback_typedefs -->
```dart
import '../00_architecture/user_feature.dart' show UserId;

typedef UserTapCallback = void Function(UserId id);
typedef Validator<T> = String? Function(T? value);

final class UserListController {
  UserListController({required this.onTap, this.validateQuery});

  final UserTapCallback onTap;
  final Validator<String>? validateQuery;

  String? search(String? query) => validateQuery?.call(query);
}
```

### Gerekmediği yerler

Tek kullanımlık fonksiyon tipi (inline yaz):

<!-- snippet: 02_typedefs/inline_function_type -->
```dart
final class Debouncer {
  Debouncer(this._onFire);
  final void Function(String query) _onFire; // Used once: no typedef needed.

  void fire(String query) => _onFire(query);
}
```

Typedef yeni tip değildir; ID için extension type kullan:

<!-- snippet: 02_typedefs/alias_not_new_type -->
```dart
typedef OrderIdAlias = int;

OrderIdAlias nextOrder(OrderIdAlias id) => id + 1; // Accepts any int.
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde `^typedef ` ile başlayan
**411** satır var (`dart run dartadvance_tool:dartadvance flutter-src grep --count '^typedef '`);
bunların 13'ü record tipine alias (`^typedef \w+(<...>)? = \(`).

| Typedef | Ne gösteriyor | Kaynak |
| --- | --- | --- |
| `ValueChanged<T> = void Function(T value)` | Framework'ün temel generic callback sözleşmesi | [foundation/basic_types.dart#L17](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/basic_types.dart#L17) |
| `ValueGetter<T> = T Function()` | Parametresiz generic üretici | [foundation/basic_types.dart#L39](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/basic_types.dart#L39) |
| `WidgetBuilder = Widget Function(BuildContext context)` | En sık kullanılan builder sözleşmesi | [widgets/framework.dart#L5733](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L5733) |
| `AsyncWidgetBuilder<T>` | `FutureBuilder`/`StreamBuilder`'ın builder tipi (generic + snapshot) | [widgets/async.dart#L326](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/async.dart#L326) |
| `FormFieldValidator<T> = String? Function(T? value)` | Nullable dönüş ile validasyon sözleşmesi | [widgets/form.dart#L477](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/form.dart#L477) |
| `LayoutCallback<T extends Constraints>` | **Bounded** tip parametresi olan typedef | [rendering/object.dart#L951](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/object.dart#L951) |
| `PageRouteFactory = PageRoute<T> Function<T>(...)` | **Generic fonksiyon tipi**: `T` typedef'in değil, fonksiyonun parametresi | [widgets/app.dart#L254](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/app.dart#L254) |
| `ComputeCallback<M, R> = FutureOr<R> Function(M message)` | `compute()`'un isolate'e gönderilen fonksiyon tipi (bkz. [09 · Isolates](09-isolates.md)) | [foundation/isolates.dart#L19](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/isolates.dart#L19) |
| `_Sizes = ({double titleY, BoxConstraints textConstraints, Size tileSize})` | Private **record alias**, layout hesabının çoklu dönüşü | [material/list_tile.dart#L43](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/list_tile.dart#L43) |
| `_EnsureVisibleResults = (List<Future<void>>, ScrollableState)` | Positional record alias | [widgets/scrollable.dart#L69](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/scrollable.dart#L69) |
| `_TypeOf<T> = T` | Tip literal'i yazılamayan yerde tip ifadesi elde etme: `runtimeType == _TypeOf<ValueKey<T>>` ([L158](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/key.dart#L158)) | [foundation/key.dart#L165](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/key.dart#L165) |

Not: `VoidCallback` `dart:ui`'da tanımlıdır, `packages/flutter/lib` içinde değil.

## Lint'ler

| Lint | Set | Ne yapar |
| --- | --- | --- |
| [prefer_generic_function_type_aliases](https://dart.dev/tools/linter-rules/prefer_generic_function_type_aliases) | core (→ recommended) | Eski `typedef int F(int a);` sözdizimini yasaklar |
| [use_function_type_syntax_for_parameters](https://dart.dev/tools/linter-rules/use_function_type_syntax_for_parameters) | recommended | `bool predicate(T e)` yerine `bool Function(T) predicate` |
| [avoid_private_typedef_functions](https://dart.dev/tools/linter-rules/avoid_private_typedef_functions) | hiçbiri (opsiyonel) | Private fonksiyon typedef'i yerine inline tip önerir |

## Kontrol listesi

- [ ] Yeni tip mi gerekiyor (güvenlik/invariant)? → typedef değil, extension type/class.
- [ ] Fonksiyon tipi tek yerde mi? → inline.
- [ ] Eski sözdizimi yok (`typedef R Name(args)`).
- [ ] JSON alias'ı `Object?` ile, `dynamic` değil.
- [ ] Record alias public API'ye sızmıyor.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: Uzun tipe isim veren alias (JSON)
- **Demo promptu:** "Kargo API'sinin Data katmanı için JSON nesnesi ve JSON listesi tip adlarını tanımla ve bir DataSource imzasında kullan."
- **Model:** [`examples/lib/02_typedefs/json_alias.dart`](../../../examples/lib/02_typedefs/json_alias.dart)
- **Katman:** Data / Model, DataSource
- **Adımlar:** 1. `typedef Json = Map<String, Object?>;` biçiminde alias yaz; `dynamic` kullanma. 2. Liste için ikinci alias'ı ilkinin üzerine kur. 3. Alias'ı yalnızca Data katmanında kullan; Domain'e sızdırma. 4. Testte alias'ın orijinal tiple aynı tip olduğunu göster.
- **Kabul kriteri:** Test `Json == Map<String, Object?>` eşitliğini doğrular; alias'tan okunan değer kontrol/pattern olmadan kullanılamaz (`strict-casts` açıkken `dart analyze` temiz).
- **Min. sürüm:** 2.13 (fonksiyon olmayan typedef)

### Tarif: Generic fonksiyon typedef'i (mapper)
- **Demo promptu:** "Fatura Model'lerini Entity'lere çeviren tüm mapper'lar için tek bir generic fonksiyon tipi ve listeyi çeviren yardımcıyı yaz."
- **Model:** [`examples/lib/02_typedefs/generic_mapper.dart`](../../../examples/lib/02_typedefs/generic_mapper.dart)
- **Katman:** Data / Model → Entity dönüşümü
- **Adımlar:** 1. `typedef Mapper<S, T> = T Function(S source);` gibi yeni sözdizimiyle generic typedef yaz (eski `typedef T Name(S s)` yok). 2. Koleksiyonu çeviren generic yardımcı bu typedef'i parametre tipi olarak alsın. 3. Somut mapper'ı ayrı, adı olan bir fonksiyon olarak ver (tear-off).
- **Kabul kriteri:** Tipi uyan her fonksiyon typedef'in örneğidir (`isA<Mapper<...>>()` veya `mapAll` ile çağrı derlenir); liste sırası korunur.
- **Min. sürüm:** her sürüm

### Tarif: Private record alias ile iç yardımcı
- **Demo promptu:** "Sipariş satırlarını geçerli ve atlanan olarak ayıran dosya içi bir yardımcı yaz; ara sonucu private bir record alias taşısın, public dönüş bir sınıf olsun."
- **Model:** [`examples/lib/02_typedefs/private_record_alias.dart`](../../../examples/lib/02_typedefs/private_record_alias.dart), [`examples/lib/02_typedefs/practice/ex3_rating_summary.dart`](../../../examples/lib/02_typedefs/practice/ex3_rating_summary.dart)
- **Katman:** Data (private helper)
- **Adımlar:** 1. Alias'ı `_` ile başlat (`typedef _Partition = ({...});`), yalnızca bu dosyada kullan. 2. Yardımcıyı küçük private fonksiyon olarak yaz, record döndürsün. 3. Public fonksiyonda record'u `final (:a, :b) = ...` ile parçala. 4. Katman dışına çıkan sonucu `final class` yap, record alias değil.
- **Kabul kriteri:** Bozuk satırlar atlanır ve sayısı raporlanır; public API'de record alias yoktur (test yalnızca public sınıfı/entity'yi görür).
- **Min. sürüm:** 3.0 (records)

### Tarif: Callback / validator sözleşmesi
- **Demo promptu:** "Kupon kodu alanı için `null` = geçerli dönen bir validator typedef'i, iki validator ve bunları sırayla çalıştırıp ilk hatayı veren birleştiriciyle bir form state sınıfı yaz."
- **Model:** [`examples/lib/02_typedefs/callback_typedefs.dart`](../../../examples/lib/02_typedefs/callback_typedefs.dart), [`examples/lib/02_typedefs/practice/ex2_validators.dart`](../../../examples/lib/02_typedefs/practice/ex2_validators.dart)
- **Katman:** Presentation + Application / state sınıfı
- **Adımlar:** 1. Birden çok yerde kullanılan callback için generic typedef yaz (`FormFieldValidator<T>` tarzı). 2. Validator'ları top-level fonksiyon veya fonksiyon döndüren fabrika olarak yaz. 3. Birleştirici listeyi sırayla dolaşıp ilk hatada erken `return` yapsın. 4. State sınıfı validator'ı constructor'dan alsın, sonucu bir alanda tutsun.
- **Kabul kriteri:** `isA<Validator<String>>()` doğru; birleştirici ilk hatayı döner, hepsi geçerse `null`; state sınıfı hatayı ekrana verecek alanda tutar.
- **Min. sürüm:** her sürüm

### Tarif: Typedef yerine inline tip (ve ID için typedef değil)
- **Demo promptu:** "Arama kutusu için yalnızca bir yerde kullanılan bir `onSubmit` callback alanı olan sınıf yaz ve ürün ID'si için typedef'in neden güvenlik sağlamadığını testle göster."
- **Model:** [`examples/lib/02_typedefs/inline_function_type.dart`](../../../examples/lib/02_typedefs/inline_function_type.dart), [`examples/lib/02_typedefs/alias_not_new_type.dart`](../../../examples/lib/02_typedefs/alias_not_new_type.dart), [`examples/lib/02_typedefs/practice/ex1_unit_aliases.dart`](../../../examples/lib/02_typedefs/practice/ex1_unit_aliases.dart)
- **Katman:** tüm katmanlar (karar kuralı)
- **Adımlar:** 1. Tek yerde geçen fonksiyon tipini alanın tipine inline yaz (`void Function(String query)`). 2. ID/birim için `typedef X = int` yazma; typedef'in yeni tip olmadığını testte göster. 3. Tip güvenliği gerekiyorsa extension type'a yönlendir (ileride: Extension types).
- **Kabul kriteri:** Test, alias tipinin altta yatan tipe eşit olduğunu (`OrderIdAlias == int`) ve alias parametresine sıradan bir `int`/yanlış birimin derlenip kabul edildiğini gösterir.
- **Min. sürüm:** 2.13

## Pekiştirme

### Alıştırma 1 · Birim alias'ı tuzağı (kolay)
`typedef Celsius = double;` ve `typedef Fahrenheit = double;` tanımla,
`Fahrenheit toFahrenheit(Celsius c)` yaz (`100` → `212`). Sonra bir `Fahrenheit`
değerini `toFahrenheit`'e veren `convertTwice` yaz ve derlendiğini gör. Testte
`Celsius == double` ve `Fahrenheit == Celsius` olduğunu doğrula: alias neden
yanlış birimi yakalamaz?

**İpucu:** Typedef yeni tip değil yeni isimdir; bkz. "Gerekmediği yerler" ve [typedefs](https://dart.dev/language/typedefs).

<details><summary>Çözüm</summary>

<!-- snippet: 02_typedefs/practice/ex1_unit_aliases -->
```dart
typedef Celsius = double;
typedef Fahrenheit = double;

Fahrenheit toFahrenheit(Celsius celsius) => celsius * 9 / 5 + 32;

Fahrenheit convertTwice(Fahrenheit fahrenheit) => toFahrenheit(fahrenheit); // Compiles.
```

</details>

### Alıştırma 2 · Validator sözleşmesi ve form state'i (orta)
Presentation için `typedef Validator<T> = String? Function(T? value)` tanımla
(`null` = geçerli). `requiredText`, `minLength(int)` ve validator listesini sırayla
çalıştırıp **ilk** hatayı döndüren generic `combine<T>` yaz. Düz Dart bir
`LoginFormState` state sınıfı `submit(password)` ile `passwordError`'u doldursun.
Testte `requiredText is Validator<String>` doğru olmalı.

**İpucu:** İmzası uyan her fonksiyon typedef'in örneğidir (`sort is Compare<int>`); bkz. "Resmi örnekler" ve "Presentation: callback sözleşmeleri".

<details><summary>Çözüm</summary>

<!-- snippet: 02_typedefs/practice/ex2_validators -->
```dart
typedef Validator<T> = String? Function(T? value);

String? requiredText(String? value) => (value == null || value.isEmpty) ? 'Required' : null;

Validator<String> minLength(int min) =>
    (value) => (value ?? '').length < min ? 'At least $min characters' : null;

Validator<T> combine<T>(List<Validator<T>> validators) => (value) {
  for (final validate in validators) {
    final error = validate(value);
    if (error != null) return error;
  }
  return null;
};

final class LoginFormState {
  LoginFormState({required this.validatePassword});

  final Validator<String> validatePassword;
  String? passwordError;

  bool submit(String? password) {
    passwordError = validatePassword(password);
    return passwordError == null;
  }
}
```

</details>

### Alıştırma 3 · Puan özeti: private record alias + JSON sayıları (zor)
Data katmanında `RatingSummary summarize(JsonList rows)` yaz. Ara toplamı dosya
içi bir **private record alias** (`typedef _Totals = (...)`) taşısın; public dönüş
bir `final class RatingSummary` olsun. `'score'` `4` (int) veya `4.5` (double)
gelebilir, ikisi de sayılsın; string veya eksik skor `skipped` sayılsın.
Ortalama tüm skorlar int olsa bile `double` olmalı, boş listede `0.0`
(Built-in types konusu ile birlikte).

**İpucu:** JSON sayısı `int` veya `double` gelir → pattern'de `num`; `/` her zaman `double` döner ([01 · Built-in types](01-builtin-types.md), [#numbers](https://dart.dev/language/built-in-types#numbers)).

<details><summary>Çözüm</summary>

<!-- snippet: 02_typedefs/practice/ex3_rating_summary -->
```dart
import '../json_alias.dart';

typedef _Totals = ({num sum, int count, int skipped});

_Totals _collect(JsonList rows) {
  num sum = 0;
  var count = 0;
  for (final row in rows) {
    if (row case {'score': num score}) {
      sum += score;
      count++;
    }
  }
  return (sum: sum, count: count, skipped: rows.length - count);
}

final class RatingSummary {
  const RatingSummary({required this.average, required this.count, required this.skipped});
  final double average;
  final int count;
  final int skipped;
}

RatingSummary summarize(JsonList rows) {
  final (:sum, :count, :skipped) = _collect(rows);
  return RatingSummary(average: count == 0 ? 0 : sum / count, count: count, skipped: skipped);
}
```

</details>

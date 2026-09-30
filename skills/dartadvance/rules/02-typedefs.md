# 02 · Typedefs
> Kaynak: https://dart.dev/language/typedefs · https://dart.dev/effective-dart/design#dont-use-the-legacy-typedef-syntax · https://dart.dev/effective-dart/design#prefer-inline-function-types-over-typedefs · Min. sürüm: 2.13 (fonksiyon olmayan typedef), 3.3 (extension type)

Typedef uzun ya da tekrar eden bir tipe **yeni bir isim** verir, yeni tip yaratmaz; Data katmanında JSON tipleri ve mapper'lar, State/UI katmanında callback ve validator sözleşmeleri için kullanılır.

## 1. Fonksiyon typedef'i: mapper ve validator (her sürüm)
**Ne:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.
**Ne zaman:** Aynı imza birden çok yerde geçiyorsa (`Mapper<S, T>`, `Validator<T>`).
**Gerekmez:** Tek yerde geçen fonksiyon tipi için inline yaz: `void Function(String query)`.
<!-- snippet: 02_typedefs/function_typedefs -->
```dart
typedef Mapper<S, T> = T Function(S source);
typedef Validator<T> = String? Function(T? value);

class OrderDto {
  const OrderDto(this.id, this.total);
  final int id;
  final double total;
}

class Order {
  const Order(this.id, this.total);
  final int id;
  final double total;
}

Order orderFromDto(OrderDto dto) => Order(dto.id, dto.total);

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source),
];

String? couponRule(String? code) =>
    (code == null || code.length < 4) ? 'Coupon is too short' : null;

class CouponField {
  CouponField({required this.validator});
  final Validator<String> validator; // Any function with this shape fits.

  String? error;
  void submit(String? code) => error = validator(code);
}
```
**Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz. Düz fonksiyon `isA<Mapper<...>>()` ile doğrulanır.
**Skill'e ver:**
> "Fatura Model'lerini Entity'lere çeviren generic bir `Mapper<S, T>` typedef'i, listeyi çeviren `mapAll` yardımcısı ve kupon alanı için `String? Function(String?)` tipinde bir validator typedef'i ile form state sınıfı yaz."
**Kabul:** Somut mapper ve validator düz fonksiyon olarak verilir; `isA<Mapper<...>>()` / `isA<Validator<String>>()` geçer; liste sırası korunur; `dart analyze` temiz.

## 2. Fonksiyon olmayan typedef: Json ve generic alias (2.13)
**Ne:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir.
**Ne zaman:** Data katmanında JSON nesnesi/listesi, `Map<String, List<T>>` gibi tekrar eden koleksiyon tipleri.
**Gerekmez:** Katmanlar arası public API'de: Domain'e `Json` sızdırma, entity/sınıf döndür.
<!-- snippet: 02_typedefs/json_alias -->
```dart
typedef Json = Map<String, Object?>;
typedef JsonList = List<Json>;
typedef Cache<T> = Map<String, List<T>>; // Generic alias: Cache<int> is a Map.

class Product {
  const Product(this.name, this.price);
  final String name;
  final double price;
}

Product productFromJson(Json json) =>
    Product(json['name']! as String, (json['price']! as num).toDouble());

List<Product> productsFromJson(JsonList rows) => [
  for (final row in rows) productFromJson(row),
];

Json productToJson(Product product) => {
  'name': product.name,
  'price': product.price,
};

Cache<Product> groupByFirstLetter(List<Product> products) {
  final cache = <String, List<Product>>{};
  for (final product in products) {
    (cache[product.name[0]] ??= []).add(product);
  }
  return cache;
}
```
**Tuzak:** Alias orijinal tiple birebir aynıdır (`Json == Map<String, Object?>`); `dynamic` değil `Object?` kullan, yoksa `strict-casts` bile seni koruyamaz. JSON sayısı `int` de gelebilir: `(x as num).toDouble()`.
**Skill'e ver:**
> "Kargo API'sinin Data katmanı için `Json` ve `JsonList` alias'ları, `Shipment` sınıfı, `fromJson`/`toJson` fonksiyonları ve `Map<String, List<Shipment>>` için generic bir `ByCity<T>` alias'ı yaz."
**Kabul:** Test `Json == Map<String, Object?>` ve generic alias eşitliğini doğrular; `int` ve `double` ağırlık değerleri kabul edilir; `dynamic` yok.

## 3. Typedef yeni tip değildir: ID için extension type (3.3)
**Ne:** `typedef UserIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder.
**Ne zaman:** Alias okunabilirlik içindir; tip güvenliği gerekiyorsa `extension type`.
**Gerekmez:** Extension type, sıfır maliyetli sarmalayıcıdır; yalnızca gerçekten karışabilecek ID/birim değerlerinde gerekir.
<!-- snippet: 02_typedefs/alias_not_new_type -->
```dart
typedef UserIdAlias = int;

extension type const UserId(int value) {}

String describeAlias(UserIdAlias id) => 'user #$id';
String describeTyped(UserId id) => 'user #${id.value}';

// A product count is also an int, so the alias accepts it silently.
UserIdAlias productCount() => 42;

String loadProfileWithAlias() => describeAlias(productCount());

// describeTyped(productCount()) is rejected by the analyzer.
String loadProfileWithTyped() => describeTyped(const UserId(7));
```
**Tuzak:** `UserIdAlias == int` ve alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder; `UserId` alan fonksiyona `int` vermeyi analyzer reddeder (testlenemez, yalnızca prose).
**Skill'e ver:**
> "Sipariş ID'si ve ürün ID'si için iki ayrı extension type yaz; ikisini de alias ile yapınca karışmanın derlendiğini, extension type ile analyzer'ın reddettiğini testle ve prose ile göster."
**Kabul:** Test alias'ın `int`'e eşit olduğunu ve yanlış değerin kabul edildiğini gösterir; extension type `.value` ile sarılı değeri verir; yanlış ID için derleme hatasının analyzer tarafından verildiği yorumda yazılıdır.

## Flutter'da kanıt
- `ValueChanged<T> = void Function(T value)`: framework'ün temel callback sözleşmesi, [basic_types.dart#L17](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/basic_types.dart#L17).
- `FormFieldValidator<T> = String? Function(T? value)`: `null` = geçerli, [form.dart#L477](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/form.dart#L477).
- `WidgetBuilder = Widget Function(BuildContext context)`: en sık builder tipi, [framework.dart#L5733](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L5733).
- `_Sizes` private record alias: alias dosya içinde kalır, [list_tile.dart#L43](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/list_tile.dart#L43).

## Kontrol listesi
- [ ] Yeni tip gerekiyorsa (güvenlik/invariant) typedef değil extension type/class.
- [ ] Tek yerde geçen fonksiyon tipi inline yazıldı.
- [ ] Eski sözdizimi (`typedef R Name(args)`) yok.
- [ ] JSON alias'ı `Object?` ile, `dynamic` ile değil.
- [ ] `Json` Domain'e sızmıyor, entity döndürülüyor.

## Pekiştirme
- **Kolay:** `typedef Celsius = double; typedef Fahrenheit = double;` ile `toFahrenheit(Celsius)` yaz; testte bir `Fahrenheit`'ı ona vermenin derlendiğini ve `Celsius == Fahrenheit` olduğunu göster. Bitti = test yeşil.
- **Zor:** Aynı iki birimi extension type yap; yanlış birimi vermenin analyzer'da hata olduğunu yorumla belirt ve dönüşüm fonksiyonlarını yaz. Bitti = `toFahrenheit(const Celsius(100)).value == 212`.

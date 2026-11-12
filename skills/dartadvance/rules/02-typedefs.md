# 02 · Typedefs
> Kaynak: https://dart.dev/language/typedefs · https://dart.dev/effective-dart/design#dont-use-the-legacy-typedef-syntax · https://dart.dev/effective-dart/design#prefer-inline-function-types-over-typedefs · Min. sürüm: 2.13 (fonksiyon olmayan typedef), 3.3 (extension type)
Neden bu konu: Flutter'da `ValueChanged`, `FormFieldValidator`, `Map<String, dynamic>` her yerde; typedef'in yeni tip yaratmadığını bilmeden ID karışıklıkları sessizce derlenir.

Typedef uzun ya da tekrar eden bir tipe **yeni bir isim** verir, yeni tip yaratmaz; Data katmanında JSON tipleri ve mapper'lar, State/UI katmanında callback ve validator sözleşmeleri için kullanılır.

## 1. Fonksiyon typedef'i: mapper ve validator (her sürüm)
**Ne:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.
**Ne zaman:** Aynı imza birden çok yerde geçiyorsa (`Mapper<S, T>`, `Validator<T>`).
**Gerekmez:** Tek yerde geçen fonksiyon tipi için inline yaz: `void Function(String query)`.
<!-- snippet: 02_typedefs/function_typedefs -->
```dart
// Düzelt: /dartadvance Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback
//    ve validator tiplerini bul, `typedef` ile adlandır, test yaz.
// Üret: /dartadvance Bana ürün adı, adet ve fiyat alanlarını aynı imzalı doğrulayıcılarla
//    kontrol eden bir sipariş formu yaz.
typedef Mapper<S, T> = T Function(S source);
typedef Validator<T> = String? Function(T? value);

List<int> mapInline(List<String> items, int Function(String) map) => [
  for (final item in items) map(item), // Signature repeated at every use.
];

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source), // Named once, reused everywhere.
];

int wordCount(String text) => text.split(' ').length;

String? couponRule(String? code) =>
    (code == null || code.length < 4) ? 'Coupon is too short' : null; // 'ab': error

class CouponField {
  CouponField({required this.validator});
  final Validator<String> validator; // Any function with this shape fits.

  String? error;
  void submit(String? code) => error = validator(code);
}
```
**Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz. Düz fonksiyon `isA<Mapper<...>>()` ile doğrulanır.
**Düzelt (mevcut proje):** > "/dartadvance Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback ve validator tiplerini bul, `typedef` ile adlandır, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün adı, adet ve fiyat alanlarını aynı imzalı doğrulayıcılarla kontrol eden bir sipariş formu yaz."
**Kabul:** Her tekrar eden imza tek bir typedef'e iner; somut fonksiyonlar düz fonksiyon olarak verilir; `isA<Mapper<...>>()` / `isA<Validator<String>>()` geçer; inline ve typedef'li sürüm aynı sonucu verir; `dart analyze` temiz.

## 2. Fonksiyon olmayan typedef: Json ve generic alias (2.13)
**Ne:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir.
**Ne zaman:** Data katmanında JSON nesnesi/listesi, `Map<String, List<T>>` gibi tekrar eden koleksiyon tipleri.
**Gerekmez:** Katmanlar arası public API'de: Domain'e `Json` sızdırma, entity/sınıf döndür.
<!-- snippet: 02_typedefs/json_alias -->
```dart
// Düzelt: /dartadvance Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı
//    yerlerini bul, `typedef` alias ile düzelt, test yaz.
// Üret: /dartadvance Bana API'den gelen fatura satırları JSON listesini okuyup tekrar
//    JSON'a çeviren bir Data sınıfı yaz.
typedef Json = Map<String, Object?>;
typedef JsonList = List<Json>;
typedef Cache<T> = Map<String, List<T>>; // Cache<int> == Map<String, List<int>>

class Product {
  const Product(this.name, this.price);
  final String name;
  final double price;
}

// ✗ Map<String, dynamic> json  // analyzer (strict-casts): dynamic can't be assigned to String
Product fromJsonWrong(Map<String, Object?> json) =>
    Product(json['name']! as String, json['price']! as double); // 4: TypeError

Product productFromJson(Json json) =>
    Product(json['name']! as String, (json['price']! as num).toDouble()); // 4 -> 4.0

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
**Düzelt (mevcut proje):** > "/dartadvance Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı yerlerini bul, `typedef` alias ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana API'den gelen fatura satırları JSON listesini okuyup tekrar JSON'a çeviren bir Data sınıfı yaz."
**Kabul:** Test `Json == Map<String, Object?>` ve generic alias eşitliğini doğrular; `int` ve `double` değerler kabul edilir (`as double` kullanan olumsuz sürüm `int`'te `TypeError` verir); `dynamic` kalmaz; Domain'e `Json` sızmaz.

## 3. Typedef yeni tip değildir: ID için extension type (3.3)
**Ne:** `typedef UserIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder.
**Ne zaman:** Alias okunabilirlik içindir; tip güvenliği gerekiyorsa `extension type`.
**Gerekmez:** Extension type, sıfır maliyetli sarmalayıcıdır; yalnızca gerçekten karışabilecek ID/birim değerlerinde gerekir.
<!-- snippet: 02_typedefs/alias_not_new_type -->
```dart
// Düzelt: /dartadvance Projemde `typedef X = int` gibi alias'la ID ya da birim tipi
//    tanımlayan yerleri bul, `extension type` ile dönüştür, test yaz.
// Üret: /dartadvance Bana sipariş numarası ile müşteri numarasının karışmasını derleme
//    anında engelleyen bir fatura servisi yaz.
typedef UserIdAlias = int; // Just another name for int.

extension type const UserId(int value) {}

String describeAlias(UserIdAlias id) => 'user #$id';
String describeTyped(UserId id) => 'user #${id.value}';

int productCount() => 42;

String loadWithAlias() => describeAlias(productCount()); // user #42: wrong ID accepted

// describeTyped(productCount()) is rejected by the analyzer.
String loadWithTyped() => describeTyped(const UserId(7)); // user #7
```
**Tuzak:** `UserIdAlias == int` ve alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder; `UserId` alan fonksiyona `int` vermeyi analyzer reddeder (testlenemez, yalnızca prose).
**Düzelt (mevcut proje):** > "/dartadvance Projemde `typedef X = int` gibi alias'la ID ya da birim tipi tanımlayan yerleri bul, `extension type` ile dönüştür, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş numarası ile müşteri numarasının karışmasını derleme anında engelleyen bir fatura servisi yaz."
**Kabul:** Test eski alias'ın `int`'e eşit olduğunu ve yanlış değerin kabul edildiğini gösterir; extension type `.value` ile sarılı değeri verir; yanlış ID için derleme hatasının analyzer tarafından verildiği yorumda yazılıdır.

## 4. Record alias: isimli alanlı typedef (3.0)
**Ne:** Bir record tipine isim verir; alanlar isimliyse `p.lat` okunur, sıra karışması anlam karıştırmaz.
**Ne zaman:** Aynı birkaç değer birden çok imzada ya da callback'te tek parça dolaşıyorsa; fonksiyondan birden fazla değer dönerken. Davranış ya da 3'ten fazla alan varsa class (kart 7), tek değer ve karışmaması gerekiyorsa extension type (kart 3), çağrıda okunurluk için named parametre (kart 5).
**Gerekmez:** Tek yerde geçen küçük record için alias yazma.
<!-- snippet: 02_typedefs/record_alias -->
```dart
// Düzelt: /dartadvance Projemde konum, boyut ya da aralık için `(double, double)` gibi
//    konumsal record kullanan yerleri bul, isimli alanlı `typedef` ile düzelt, test yaz.
// Üret: /dartadvance Bana mağaza seçme ekranı için konumu ve seçim callback'ini typedef ile
//    adlandıran bir harita sınıfı yaz.
typedef Point = ({double lat, double lng});
typedef OnPicked = void Function(Point point);

(double, double) storeWrong() => (29.0, 41.0); // lng first by mistake: still compiles
double latWrong() => storeWrong().$1; // 29.0: not a latitude

Point store() => (lng: 29.0, lat: 41.0); // Names, not order, decide the meaning.
String pinLabel(Point point) => '${point.lat}, ${point.lng}'; // 41.0, 29.0

class MapScreen {
  MapScreen({required this.onPicked});
  final OnPicked onPicked; // One name for the callback shape.

  void tapStore() => onPicked(store());
}
```
**Tuzak:** Konumsal `(double, double)` içinde `lng`, `lat` yerine yazılsa da derlenir; `.$1` enlem diye boylamı okur.
**Düzelt (mevcut proje):** > "/dartadvance Projemde konum, boyut ya da aralık için `(double, double)` gibi konumsal record kullanan yerleri bul, isimli alanlı `typedef` ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana mağaza seçme ekranı için konumu ve seçim callback'ini typedef ile adlandıran bir harita sınıfı yaz."
**Kabul:** Konumsal record kalmaz; `store().lat == 41.0`; `OnPicked` callback'i `Point` alır; `dart analyze` temiz.

## 5. Fonksiyon typedef'inde isimli parametre
**Ne:** Aynı türden parametreleri olan typedef'te parametreleri isimli (`required`) yaz; çağıran da fonksiyon da adıyla eşleşir.
**Ne zaman:** Aynı türden iki ya da daha fazla parametre varsa (`String from, String to`).
**Gerekmez:** Tek parametreli ya da farklı türlü kısa callback'te gerekmez.
<!-- snippet: 02_typedefs/named_params -->
```dart
// Düzelt: /dartadvance Projemde aynı türden konumsal parametreleri olan callback ve typedef
//    tiplerini bul, parametrelere isim ver (`required` isimli), test yaz.
// Üret: /dartadvance Bana havale ekranı için gönderen, alıcı ve kuruş alan isimli bir
//    typedef ve onu kullanan bir fonksiyon yaz.
typedef TransferWrong = String Function(String, String, int);
typedef Transfer = String Function({required String from, required String to, required int cents});

String moveWrong(String to, String from, int cents) => '$from -> $to: $cents'; // Order swapped
String sendWrong(TransferWrong run) => run('ali', 'veli', 5000); // veli -> ali: wrong way

String transfer({required String from, required String to, required int cents}) =>
    '$from -> $to: $cents';
String send(Transfer run) => run(from: 'ali', to: 'veli', cents: 5000); // ali -> veli

// send(moveWrong) is rejected by the analyzer: its parameters are not named from/to/cents.
```
**Tuzak:** `String Function(String, String, int)` sırası ters yazılmış bir fonksiyonu da kabul eder; havale ters yönde gider. İsimli typedef bunu analyzer'a reddettirir.
**Düzelt (mevcut proje):** > "/dartadvance Projemde aynı türden konumsal parametreleri olan callback ve typedef tiplerini bul, parametrelere isim ver (`required` isimli), test yaz."
**Üret (yeni kod):** > "/dartadvance Bana havale ekranı için gönderen, alıcı ve kuruş alan isimli bir typedef ve onu kullanan bir fonksiyon yaz."
**Kabul:** Typedef'te aynı türden konumsal parametre kalmaz; `send(transfer) == 'ali -> veli: 5000'`; sırası ters fonksiyon analyzer'da reddedilir.

## 6. AsyncResult: Future<Result<T>> için alias
**Ne:** `typedef AsyncResult<T> = Future<Result<T>>` her repository imzasında tekrar eden tipi bir isme indirir.
**Ne zaman:** Repository ve servis katmanında hata fırlatmayan metotlar çoğunluktaysa.
**Gerekmez:** Tek metotluk serviste inline yaz.
<!-- snippet: 02_typedefs/async_result -->
```dart
// Düzelt: /dartadvance Projemde `Future<Result<T>>` imzasını her repository metodunda tekrar
//    eden yerleri bul, `typedef AsyncResult<T>` ile adlandır, test yaz.
// Üret: /dartadvance Bana stok ve fiyat sorgulayan, hata fırlatmayıp sonuç dönen bir
//    repository yaz; dönüş tipi tek bir typedef olsun.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}

typedef AsyncResult<T> = Future<Result<T>>; // Named once, reused in every signature.

Future<Result<int>> stockWrong(String sku) async => // Signature spelled out each time.
    sku == 'x' ? const Err('Stok yok') : const Ok(12);

AsyncResult<int> stock(String sku) async => sku == 'x' ? const Err('Stok yok') : const Ok(12);
AsyncResult<double> price(String sku) async => const Ok(24.5);

String describe(Result<int> result) => switch (result) {
  Ok(:final value) => 'Stok: $value',
  Err(:final message) => 'Hata: $message',
};
```
**Tuzak:** Alias yeni tip değildir: `AsyncResult<int> == Future<Result<int>>`, sonuç aynıdır; kazanç imzayı tek yerden değiştirebilmektir.
**Düzelt (mevcut proje):** > "/dartadvance Projemde `Future<Result<T>>` imzasını her repository metodunda tekrar eden yerleri bul, `typedef AsyncResult<T>` ile adlandır, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana stok ve fiyat sorgulayan, hata fırlatmayıp sonuç dönen bir repository yaz; dönüş tipi tek bir typedef olsun."
**Kabul:** Repository imzalarında `Future<Result<` kalmaz; `AsyncResult<int> == Future<Result<int>>`; `switch` ile `Ok`/`Err` ayrılır; `dart analyze` temiz.

## 7. Record alias ne zaman class olur
**Ne:** Alias okunabilirliği çözer, anlamı çözmez; aynı türden 3'ten fazla alan ya da davranış gerekiyorsa class kullan.
**Ne zaman:** Alan sayısı arttıkça ya da toplam gibi türetilmiş değer gerekince.
**Gerekmez:** İki üç farklı türlü kısa, geçici değer için record yeterlidir.
<!-- snippet: 02_typedefs/record_vs_class -->
```dart
// Düzelt: /dartadvance Projemde 3'ten fazla alanlı ya da aynı türden alanları olan record
//    alias'larını bul, sınıfa çevir, alanları isimlendir, test yaz.
// Üret: /dartadvance Bana sepet satırını (ad, adet, kuruş, indirim) tutan ve satır toplamını
//    hesaplayan bir sınıf yaz.
typedef LineWrong = (String, int, int, int); // name, qty, cents, discount: three ints in a row

LineWrong wrongLine() => ('Kalem', 3, 450, 50);
int totalWrong(LineWrong line) => line.$2 * line.$4; // qty * discount: 150, not 1300

final class CartLine {
  const CartLine({
    required this.name,
    required this.qty,
    required this.cents,
    required this.discount,
  });
  final String name;
  final int qty;
  final int cents;
  final int discount;

  int get total => qty * cents - discount; // 3 * 450 - 50 = 1300
}
```
**Tuzak:** `(String, int, int, int)` içinde `$2 * $4` adet ile indirimi çarpar; derlenir, toplam `150` çıkar, doğrusu `1300`.
**Düzelt (mevcut proje):** > "/dartadvance Projemde 3'ten fazla alanlı ya da aynı türden alanları olan record alias'larını bul, sınıfa çevir, alanları isimlendir, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sepet satırını (ad, adet, kuruş, indirim) tutan ve satır toplamını hesaplayan bir sınıf yaz."
**Kabul:** Aynı türden art arda alan içeren record alias kalmaz; `CartLine(...).total == 1300`; `dart analyze` temiz.

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
- [ ] Aynı türden parametreli function typedef'te parametreler isimli.
- [ ] Konumsal record alias yok; 3'ten fazla alan ya da davranış varsa class.

## Pekiştirme
- **Kolay:** `typedef Celsius = double; typedef Fahrenheit = double;` ile `toFahrenheit(Celsius)` yaz; testte bir `Fahrenheit`'ı ona vermenin derlendiğini ve `Celsius == Fahrenheit` olduğunu göster. Bitti = test yeşil.
- **Zor:** Aynı iki birimi extension type yap; yanlış birimi vermenin analyzer'da hata olduğunu yorumla belirt ve dönüşüm fonksiyonlarını yaz. Bitti = `toFahrenheit(const Celsius(100)).value == 212`.

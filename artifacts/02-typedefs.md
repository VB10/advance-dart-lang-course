# Bölüm 02 · Typedefs

Typedef uzun ya da tekrar eden bir tipe **yeni bir isim** verir, yeni tip yaratmaz. Data katmanında JSON tipleri için, State/UI katmanında callback ve validator sözleşmeleri için kullanılır.

**Neden bu sırada:** Küçük, hızlı kazanım. `Json` ve callback tipleri sonraki konularda geçer.

Uygulama: `examples/dart_advance_example/lib/features/02_typedefs/` (7 kart, aynı sırada, aynı başlıklarla).
Dart dosyaları: `examples/lib/02_typedefs/` · Kural: `skills/dartadvance/rules/02-typedefs.md` · Çekim notu: `docs/FILMING.md`

---

## 1) Fonksiyon typedef'i

**Söyle:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.

**Ekranda (sipariş formu):** ürün adı, adet ve fiyat doğrulayıcıları.

| | Kod | Sonuç |
| --- | --- | --- |
| Bozuk | Her parametrede `String? Function(int?)` yeniden yazılır | Aynı sonuç, daha çok kod; imza değişince her yer elle güncellenir |
| Düzgün | `typedef Validator<T> = String? Function(T? value);` | Aynı sonuç, imza bir kez adlandırılır |

**Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz.
**Gerekmez:** Tek yerde geçen fonksiyon tipi için inline yaz: `void Function(String query)`.
**Flutter'da kanıt:** `ValueChanged<T>`, `FormFieldValidator<T>`, `WidgetBuilder`.

**Düzelt:**
```
/dartadvance Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback ve validator tiplerini bul, `typedef` ile adlandır, test yaz.
```
**Üret:**
```
/dartadvance Bana ürün adı, adet ve fiyat alanlarını aynı imzalı doğrulayıcılarla kontrol eden bir sipariş formu yaz.
```
**Kabul:** Her tekrar eden imza tek bir typedef'e iner; inline ve typedef'li sürüm aynı sonucu verir; `dart analyze` temiz.

Model: `features/02_typedefs/model/order_form.dart` · Örnek: `examples/lib/02_typedefs/function_typedefs.dart`

---

## 2) Json alias

**Söyle:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir (Dart 2.13).

**Ekranda (fatura):** API'den gelen satırlar `{'name': 'Kalem', 'price': 4}` ve `{'name': 'Defter', 'price': 12.5}`.

| | Kod | Sonuç |
| --- | --- | --- |
| Bozuk | `row['price']! as double` | JSON'daki `4` `int` gelir, çalışma anında `TypeError` ile toplam hesaplanamaz |
| Düzgün | `typedef Json = Map<String, Object?>;` ve `row['price']! as num` | `4 + 12.5 = 16.5` |

**Tuzak:** `Json == Map<String, Object?>` birebir aynıdır. `dynamic` değil `Object?` kullan. JSON sayısı `int` de gelebilir: `(x as num).toDouble()`.
**Gerekmez:** Katmanlar arası public API'de. Domain'e `Json` sızdırma, entity döndür.

**Düzelt:**
```
/dartadvance Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı yerlerini bul, `typedef` alias ile düzelt, test yaz.
```
**Üret:**
```
/dartadvance Bana API'den gelen fatura satırları JSON listesini okuyup tekrar JSON'a çeviren bir Data sınıfı yaz.
```
**Kabul:** `Json == Map<String, Object?>` doğrulanır; `int` ve `double` değerler kabul edilir; `dynamic` kalmaz; Domain'e `Json` sızmaz.

Model: `features/02_typedefs/model/invoice_lines.dart` · Örnek: `examples/lib/02_typedefs/json_alias.dart`

---

## 3) Alias yeni tip değildir

**Söyle:** `typedef OrderIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder (Dart 3.3 ile `extension type`).

**Ekranda (fatura başlığı):** sipariş no `7`, müşteri no `1042`.

| | Kod | Sonuç |
| --- | --- | --- |
| Bozuk | `typedef OrderIdAlias = int; typedef CustomerIdAlias = int;` | İki ID de `int`; sırayı değiştirince de derlenir, numaralar karışır |
| Düzgün | `extension type const OrderId(int value)` ve `CustomerId(int value)` | Ayrı tipler; yanlış sırayı analyzer reddeder, başlık doğru yazılır |

**Tuzak:** Alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder.
**Gerekmez:** Extension type sıfır maliyetli sarmalayıcıdır; yalnızca gerçekten karışabilecek ID ve birim değerlerinde gerekir.

**Düzelt:**
```
/dartadvance Projemde `typedef X = int` gibi alias'la ID ya da birim tipi tanımlayan yerleri bul, `extension type` ile dönüştür, test yaz.
```
**Üret:**
```
/dartadvance Bana sipariş numarası ile müşteri numarasının karışmasını derleme anında engelleyen bir fatura servisi yaz.
```
**Kabul:** Eski alias'ın `int`'e eşit olduğu ve yanlış değerin kabul edildiği gösterilir; extension type `.value` ile sarılı değeri verir.

Model: `features/02_typedefs/model/invoice_service.dart` · Örnek: `examples/lib/02_typedefs/alias_not_new_type.dart`

---

## 4) Record alias: isimli alanlı typedef (3.0)

**Söyle:** Bir record tipine isim verir; alanlar isimliyse `p.lat` okunur, sıra karışması anlam karıştırmaz.

**Tuzak:** Konumsal `(double, double)` içinde `lng`, `lat` yerine yazılsa da derlenir; `.$1` enlem diye boylamı okur.
**Ne zaman:** Aynı birkaç değer birden çok imzada ya da callback'te tek parça dolaşıyorsa; fonksiyondan birden fazla değer dönerken. Davranış ya da 3'ten fazla alan varsa class (kart 7), tek değer ve karışmaması gerekiyorsa extension type (kart 3), çağrıda okunurluk için named parametre (kart 5).
**Gerekmez:** Tek yerde geçen küçük record için alias yazma.

**Düzelt:**
```
/dartadvance Projemde konum, boyut ya da aralık için `(double, double)` gibi konumsal record kullanan yerleri bul, isimli alanlı `typedef` ile düzelt, test yaz.
```
**Üret:**
```
/dartadvance Bana mağaza seçme ekranı için konumu ve seçim callback'ini typedef ile adlandıran bir harita sınıfı yaz.
```
**Kabul:** Konumsal record kalmaz; `store().lat == 41.0`; `OnPicked` callback'i `Point` alır; `dart analyze` temiz.

Model: `features/02_typedefs/model/record_point.dart` · Örnek: `examples/lib/02_typedefs/record_alias.dart`

---

## 5) Fonksiyon typedef'inde isimli parametre

**Söyle:** Aynı türden parametreleri olan typedef'te parametreleri isimli (`required`) yaz; çağıran da fonksiyon da adıyla eşleşir.

**Tuzak:** `String Function(String, String, int)` sırası ters yazılmış bir fonksiyonu da kabul eder; havale ters yönde gider. İsimli typedef bunu analyzer'a reddettirir.
**Ne zaman:** Aynı türden iki ya da daha fazla parametre varsa (`String from, String to`).
**Gerekmez:** Tek parametreli ya da farklı türlü kısa callback'te gerekmez.

**Düzelt:**
```
/dartadvance Projemde aynı türden konumsal parametreleri olan callback ve typedef tiplerini bul, parametrelere isim ver (`required` isimli), test yaz.
```
**Üret:**
```
/dartadvance Bana havale ekranı için gönderen, alıcı ve kuruş alan isimli bir typedef ve onu kullanan bir fonksiyon yaz.
```
**Kabul:** Typedef'te aynı türden konumsal parametre kalmaz; `send(transfer) == 'ali -> veli: 5000'`; sırası ters fonksiyon analyzer'da reddedilir.

Model: `features/02_typedefs/model/transfer.dart` · Örnek: `examples/lib/02_typedefs/named_params.dart`

---

## 6) AsyncResult: Future<Result<T>> için alias

**Söyle:** `typedef AsyncResult<T> = Future<Result<T>>` her repository imzasında tekrar eden tipi bir isme indirir.

**Tuzak:** Alias yeni tip değildir: `AsyncResult<int> == Future<Result<int>>`, sonuç aynıdır; kazanç imzayı tek yerden değiştirebilmektir.
**Ne zaman:** Repository ve servis katmanında hata fırlatmayan metotlar çoğunluktaysa.
**Gerekmez:** Tek metotluk serviste inline yaz.

**Düzelt:**
```
/dartadvance Projemde `Future<Result<T>>` imzasını her repository metodunda tekrar eden yerleri bul, `typedef AsyncResult<T>` ile adlandır, test yaz.
```
**Üret:**
```
/dartadvance Bana stok ve fiyat sorgulayan, hata fırlatmayıp sonuç dönen bir repository yaz; dönüş tipi tek bir typedef olsun.
```
**Kabul:** Repository imzalarında `Future<Result<` kalmaz; `AsyncResult<int> == Future<Result<int>>`; `switch` ile `Ok`/`Err` ayrılır; `dart analyze` temiz.

Model: `features/02_typedefs/model/stock_service.dart` · Örnek: `examples/lib/02_typedefs/async_result.dart`

---

## 7) Record alias ne zaman class olur

**Söyle:** Alias okunabilirliği çözer, anlamı çözmez; aynı türden 3'ten fazla alan ya da davranış gerekiyorsa class kullan.

**Tuzak:** `(String, int, int, int)` içinde `$2 * $4` adet ile indirimi çarpar; derlenir, toplam `150` çıkar, doğrusu `1300`.
**Ne zaman:** Alan sayısı arttıkça ya da toplam gibi türetilmiş değer gerekince.
**Gerekmez:** İki üç farklı türlü kısa, geçici değer için record yeterlidir.

**Düzelt:**
```
/dartadvance Projemde 3'ten fazla alanlı ya da aynı türden alanları olan record alias'larını bul, sınıfa çevir, alanları isimlendir, test yaz.
```
**Üret:**
```
/dartadvance Bana sepet satırını (ad, adet, kuruş, indirim) tutan ve satır toplamını hesaplayan bir sınıf yaz.
```
**Kabul:** Aynı türden art arda alan içeren record alias kalmaz; `CartLine(...).total == 1300`; `dart analyze` temiz.

Model: `features/02_typedefs/model/cart_line.dart` · Örnek: `examples/lib/02_typedefs/record_vs_class.dart`

---

## Kontrol listesi
- [ ] Yeni tip gerekiyorsa (güvenlik, invariant) typedef değil extension type ya da class.
- [ ] Tek yerde geçen fonksiyon tipi inline yazıldı.
- [ ] Eski sözdizimi (`typedef R Name(args)`) yok.
- [ ] JSON alias'ı `Object?` ile, `dynamic` ile değil.
- [ ] Aynı türden parametreli function typedef'te parametreler isimli.
- [ ] Konumsal record alias yok; 3'ten fazla alan ya da davranış varsa class.

## Pekiştirme
- **Kolay:** `typedef Celsius = double; typedef Fahrenheit = double;` ile `toFahrenheit(Celsius)` yaz; bir `Fahrenheit`'ı ona vermenin derlendiğini göster.
- **Zor:** Aynı iki birimi extension type yap; `toFahrenheit(const Celsius(100)).value == 212` olsun.

Kaynak: https://dart.dev/language/typedefs

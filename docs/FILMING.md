# Çekim notları

Her özellik aynı döngü: **Aç** (tek dosya, başında iki prompt yazıyor) → **Söyle** (2 cümle) → izleyiciye iki yolu göster:
**Düzelt** (mevcut projede refactor) ve **Üret** (yeni kod isteği) → **Kıyasla** (Kabul satırı).
Skill çıktısı birebir aynı olmaz; canlıdan önce promptları kendi projende bir kez dene.
`// ✗` ile işaretli satırlar analyzer'ın reddettiği yanlış örneklerdir; dosyada yorum olarak durur.

Hazırlık: `dart pub get` · `dart run dartadvance_tool:dartadvance verify --all`. Dosyalar `examples/lib/NN_*/`, testler `examples/test/NN_*/`;
test: `cd examples && dart test test/NN_*`. Konu sırası ve gerekçesi: [KONULAR.md](KONULAR.md).
Bölüm sonunda kural dosyasındaki **Pekiştirme** iki alıştırmasını ver; çözümü sonraki bölümün başında skill ile birlikte yap.


---

## Bölüm 01 · Built-in types

**Neden:** Bildiğini sandığın tipler. Sayı, metin, record, tarih ve cascade her satırda var; buradaki hatalar derlenir, testte görünmez, kullanıcının ekranında çıkar. Her bölüm gerçek bir Flutter ekranındaki hatayı ve düzeltmesini gösterir.

### 1. Fiyat: `double` değil kuruş `int`
- **Aç:** `examples/lib/01_builtin_types/product_price.dart`
- **Söyle:** `double.toString` ekran için değildir: `.0` ve tek haneli kuruş bırakır, toplamada kuruş kaçırır. Fiyat kuruş `int` tutulur; `~/ 100` lira, `% 100` kuruş, `replaceAllMapped` binlik nokta.
- **Tuzak:** ürün kartı `24999.9 ₺` ve `29999.0 ₺` gösterir (test: "double toString shows a raw number").
- **Düzelt:** "/dartadvance Projemde fiyatı double tutan ya da ekrana $price, toString veya toStringAsFixed ile yazan yerleri bul. Kuruş int'e çevir, ~/ 100, % 100 ve binlik nokta ile yazdır, 2499990 girdisiyle test yaz."
- **Üret:** "/dartadvance Bana ürün kartı için fiyat etiketi yaz: kuruş int alsın, 24.999,90 ₺ biçiminde yazsın, eski fiyatı da göstersin."
- **Kıyasla:** fiyat `int` kuruş; `2499990` → `'24.999,90 ₺'`, `5` → `'0,05 ₺'`; `dart analyze` temiz.

### 2. Döngüsel indeks: `remainder` değil `%`
- **Aç:** `examples/lib/01_builtin_types/photo_gallery.dart`
- **Söyle:** Dart'ın `%` operatörü Öklid kalanıdır: sonuç her zaman `0` ile `n - 1` arasında. `remainder` bölünenin işaretini alır: `(-1).remainder(5)` → `-1`.
- **Tuzak:** ilk fotoğrafta "geri" `-1` verir, `photos[-1]` `RangeError` atar ve galeri açılmaz (test: "remainder keeps the sign...").
- **Düzelt:** "/dartadvance Projemde sayfa, sekme ya da gün indeksini remainder ile veya if (i < 0) i = len - 1 gibi elle saran yerleri bul. % ile düzelt, index 0 için test yaz."
- **Üret:** "/dartadvance Bana ürün galerisi için ileri/geri gezinen bir sınıf yaz: ilk fotoğraftan geri son fotoğrafa, sondan ileri ilk fotoğrafa dönsün."
- **Kıyasla:** `previous(0)` → `count - 1`; elle `if (i < 0)` sarma kalmaz; `dart analyze` temiz.

### 3. Geri sayım: `~/` ve `%`
- **Aç:** `examples/lib/01_builtin_types/resend_countdown.dart`
- **Söyle:** `/` her zaman `double` verir; `~/` tam bölümü, `%` kalanı `int` olarak verir.
- **Tuzak:** `(150 / 60).round()` 3 olur, buton `3:30` yazar; padLeft'siz `125 % 60` `2:5` yazar (test: "/ with round shows 3:30 and 2:5").
- **Düzelt:** "/dartadvance Projemde süreyi dakika:saniye ya da saat:dakika yazan yerleri bul. / ile bölüp round/toInt yapanları ve padLeft'siz % kullananları ~/, % ve padLeft(2, '0') ile düzelt, 125 sn girdisiyle test yaz."
- **Üret:** "/dartadvance Bana doğrulama kodu ekranı için \"Kodu tekrar gönder (m:ss)\" metnini üreten bir geri sayım sınıfı yaz."
- **Kıyasla:** `/` + `round`/`toInt` kalmaz; 150 → `2:30`, 125 → `2:05`, 59 → `0:59`; `dart analyze` temiz.

### 4. `num`: JSON tam sayıyı `int` verir
- **Aç:** `examples/lib/01_builtin_types/store_location.dart`
- **Söyle:** `int` ve `double` ikisi de `num`'un alt tipidir; `int`, `double`'ın alt tipi değildir. `jsonDecode` `41`'i `int`, `29.0`'ı `double` çözer.
- **Tuzak:** `json['latitude'] as double` derlenir, `41` gelince `type 'int' is not a subtype of type 'double'` ile çalışma anında patlar (test: "as double throws when JSON sends a whole number").
- **Düzelt:** "/dartadvance Projemde JSON'dan okunan sayıları as double ile cast eden yerleri bul (konum, fiyat, puan, oran). (x as num).toDouble() ile düzelt, tam sayı gelen JSON ile test yaz."
- **Üret:** "/dartadvance Bana API'den gelen mağaza listesini (ad, enlem, boylam, puan) okuyan bir fromJson yaz; sayılar int de gelebilir."
- **Kıyasla:** JSON alanında `as double` kalmaz; tam sayı içeren JSON ile test geçer; `dart analyze` temiz.

### 5. Sayı okuma: `parse` değil `tryParse`
- **Aç:** `examples/lib/01_builtin_types/dimension_field.dart`
- **Söyle:** `int.parse`/`double.parse` geçersiz metinde `FormatException` fırlatır; `tryParse` `null` döner. `double.parse` yalnız noktayı tanır.
- **Tuzak:** Türkçe klavye `12,5` yazar; `double.parse` fırlatır ve Kaydet çöker (test: "double.parse throws on a decimal comma...").
- **Düzelt:** "/dartadvance Projemde kullanıcı girdisini ya da sunucudan gelen metni int.parse / double.parse ile okuyan yerleri bul. tryParse ile düzelt, virgüllü ve hatalı girdide alan hatası göster, test yaz."
- **Üret:** "/dartadvance Bana ürün ölçüsü formu yaz: genişlik ve yükseklik cm, Türkçe klavyede virgülle girilebilsin, hatalı girdide alanın altında hata yazsın."
- **Kıyasla:** girdi okuyan yerde `parse` kalmaz; `'12,5'` → 12.5, `'12a'` → alan hatası; `dart analyze` temiz.

### 6. Metni kesmek: `substring` değil `characters` (`package:characters`)
- **Aç:** `examples/lib/01_builtin_types/chat_preview.dart`
- **Söyle:** `String` UTF-16 birimi dizisidir; 👨‍👩‍👧 ekranda tek karakter, bellekte 8 birim. `substring`, `length`, `[i]` birimle çalışır; `characters` kullanıcının gördüğü karakterle (grapheme).
- **Tuzak:** sohbet önizlemesinde aile emojisi 👨‍👩'ye bölünür; yarım surrogate'ta Flutter'ın `Text`'i `string is not well-formed UTF-16` hatası fırlatır (test: "substring splits the family emoji").
- **Düzelt:** "/dartadvance Projemde kullanıcıya görünen metni length, substring ya da [0] ile sayan, kesen veya baş harfini alan yerleri bul (önizleme, sayaç, avatar). characters ile düzelt, emojili girdiyle test yaz."
- **Üret:** "/dartadvance Bana sohbet listesi için son mesaj önizlemesi yaz: 22 karakterde kessin, emojiyi bölmesin."
- **Kıyasla:** görünen metinde `length`/`substring`/`[i]` kalmaz; kesilen metin emojiyi bütün tutar; `dart analyze` temiz.

### 7. Türkçe harf: silme, çevir (raw `RegExp`)
- **Aç:** `examples/lib/01_builtin_types/category_slug.dart`
- **Söyle:** `[^a-z0-9]` ve `\w` yalnız İngilizce harfleri tanır; Türkçe harfler "özel karakter" sayılıp silinir. Önce Latin karşılığına çevrilir (`replaceAllMapped`), sonra temizlenir. Desen raw string (`r'...'`) ile yazılır: normal string'de `\d` kaçış değil `d` harfidir. Büyük/küçük harfte de aynı: `toUpperCase` i → I yapar, önce i → İ çevrilir.
- **Tuzak:** `'Öne Çıkan Ürünler'` → `'ne-kan-r-nler'` (test: "[^a-z0-9] removes Turkish letters").
- **Düzelt:** "/dartadvance Projemde slug, dosya adı, analytics olay adı ya da snake_case anahtar üreten ve [^a-z0-9], [^\w] gibi desenle özel karakter silen yerleri bul. Türkçe harfleri önce Latin karşılığına çevir, 'Öne Çıkan Ürünler' girdisiyle test yaz."
- **Üret:** "/dartadvance Bana kategori başlığından paylaşım linki parçası üreten bir sınıf yaz: Türkçe harfleri çevirsin, boşluk ve özel karakterleri tire yapsın."
- **Kıyasla:** `'Öne Çıkan Ürünler'` → `'one-cikan-urunler'`; her `RegExp` deseni `r'...'`; `dart analyze` temiz.

### 8. Önbellek anahtarı: `List` değil record (3.0)
- **Aç:** `examples/lib/01_builtin_types/pin_address_cache.dart`
- **Söyle:** `List`, `Set`, `Map` eşitliği referansa bakar: `[1, 2] == [1, 2]` false. Record içerik eşitliği ve `hashCode` ile gelir; `(lat, lng)` doğrudan Map anahtarı, Set elemanı olur.
- **Tuzak:** aynı pine 3 dokunuş 3 sunucu isteği yapar, önbellek hiç tutmaz (test: "a List key never hits...").
- **Düzelt:** "/dartadvance Projemde Map anahtarı ya da Set elemanı olarak List, ya da '$a-$b' gibi birleştirilmiş String kullanan yerleri bul. Record ile düzelt, aynı anahtarla iki çağrıda tek istek gittiğini test et."
- **Üret:** "/dartadvance Bana haritada pin adresini (lat, lng) anahtarlı önbellekte tutan bir sınıf yaz; aynı pine ikinci dokunuşta sunucuya gitmesin."
- **Kıyasla:** Map/Set anahtarında `List` ya da birleştirilmiş String kalmaz; aynı `(lat, lng)` ile 3 çağrıda 1 istek; `dart analyze` temiz.

### 9. API saati UTC: `toLocal`
- **Aç:** `examples/lib/01_builtin_types/event_time.dart`
- **Söyle:** `Z` ile biten ISO metnini `DateTime.parse` UTC olarak tutar (`isUtc` true); `hour` UTC saatidir. Ekrana yazmadan önce `toLocal()`, sunucuya gönderirken `toUtc().toIso8601String()`.
- **Tuzak:** `'2026-11-02T17:30:00Z'` Türkiye'de `17:30` görünür, kullanıcı etkinliği 3 saat erken sanır (test: "parse keeps a Z time in UTC").
- **Düzelt:** "/dartadvance Projemde API'den gelen tarihi DateTime.parse ile okuyup toLocal olmadan ekrana yazan yerleri bul. toLocal ekle, Z'li girdiyle isUtc kontrolü yapan test yaz."
- **Üret:** "/dartadvance Bana etkinlik başlangıcını API'nin UTC metninden okuyup cihaz saatinde HH:mm yazan bir sınıf yaz."
- **Kıyasla:** ekrana giden `DateTime` `isUtc == false`; `dart analyze` temiz.

### 10. `late final` mı getter mı
- **Aç:** `examples/lib/01_builtin_types/event_filter_sheet.dart` · `examples/lib/01_builtin_types/brand_page.dart`
- **Söyle:** `late final` ilk okumada bir kez hesaplanır ve kaynağa bir daha bakmaz; getter her okumada gövdesini çalıştırır. Seçim kaynağın değişip değişmediğine bağlıdır.
- **Tuzak:** Dil `tr` → `en` olunca `late final` başlıklar Türkçe kalır (test: "late final keeps the first language..."). Getter'daki `where` + `sort`, grid her hücrede okuduğu için 3 hücrede 7 kez çalışır (test: "the getter sorts on every read").
- **Düzelt:** "/dartadvance Projemde late final alanları bul. Kaynağı sonradan değişebilenleri (dil, tema, kullanıcı, filtre) getter'a ya da değiştiği yerde yeniden kurmaya çevir, kaynağı değiştiren bir testle kanıtla. Ayrıca where, sort, map, fold gibi iş yapan getter'ları bul; build veya itemBuilder içinde tekrar okunanları, kaynak değişmiyorsa late final'a çevir ve çağrı sayısını testle ölç."
- **Üret:** "/dartadvance Bana uygulama dili değişince seçenek başlıkları da değişen bir filtre sheet'i state'i ve görünür markaları build başına bir kez sıralayan bir sayfa state'i yaz."
- **Kıyasla:** kaynağı değiştiren test yeni değeri görür; iş yapan getter'ın çağrı sayacı tek build'de 1; `dart analyze` temiz.

### 11. Cascade: `..sort` aynı listeyi sıralar
- **Aç:** `examples/lib/01_builtin_types/product_sort.dart`
- **Söyle:** Cascade (`..`) metodun sonucunu değil alıcının kendisini döndürür. `products..sort()` yeni liste gibi görünür ama listeyi yerinde sıralar; aynı listeyi kullanan her yer değişir. Önce kopya, sonra cascade: `[...products]..sort()` (ya da `package:collection` `sorted`).
- **Tuzak:** A–Z" sekmesi "Önerilen" bölümünü de alfabetik yapar, sunucu sırası kaybolur (test: "..sort reorders the source list too").
- **Düzelt:** "/dartadvance Projemde ..sort, ..shuffle, ..removeWhere, ..add gibi listeyi yerinde değiştiren cascade'leri ve sonucunu yeni bir değişkene atayan yerleri bul. Kaynak başka yerde de kullanılıyorsa kopya üzerinde çalıştır, kaynağın değişmediğini test et."
- **Üret:** "/dartadvance Bana ürünler ekranı için sunucu sırasını bozmadan A–Z, fiyata göre artan ve azalan sıralı listeler üreten bir sınıf yaz."
- **Kıyasla:** başka yerde kullanılan listede yerinde değiştiren cascade kalmaz; kaynağın değişmediği testle görülür; `dart analyze` temiz.

### 12. Nullable kontrolcü: `!` değil `?..`
- **Aç:** `examples/lib/01_builtin_types/locate_button.dart`
- **Söyle:** `?..` (null-aware cascade) alıcı null ise zincirin tamamını atlar; ilk adımda bir kez yazılır, sonraki `..` adımları da korunur. `!` "burada null olamaz" sözüdür; geç gelen kontrolcülerde bu söz tutmaz.
- **Tuzak:** harita yüklenmeden "Konumum"a basmak `Null check operator used on a null value` ile ekranı çökertir (test: "! throws when the map is not ready").
- **Düzelt:** "/dartadvance Projemde geç gelen nullable kontrolcüleri (harita, kamera, video, animasyon) ! ile ya da if (x != null) { x.a(); x.b(); } bloklarıyla kullanan yerleri bul. ?.. cascade ile düzelt, null durumda çağrının çökmediğini test et."
- **Üret:** "/dartadvance Bana harita ekranı için "Konumum" butonu yaz: kontrolcü onMapCreated ile gelsin, hazır değilken dokunuş çökmesin, hazır olunca kamerayı taşıyıp pin koysun."
- **Kıyasla:** nullable kontrolcüde `!..` ve `if (x != null) { x.a(); x.b(); }` kalmaz; null durumda çağrı çökmez; `dart analyze` temiz.


---

## Bölüm 02 · Typedefs

**Neden:** Flutter'da `ValueChanged`, `FormFieldValidator`, `Map<String, dynamic>` her yerde; typedef'in yeni tip yaratmadığını bilmeden ID karışıklıkları sessizce derlenir.

### 1. Fonksiyon typedef'i: mapper ve validator (her sürüm)
- **Aç:** `examples/lib/02_typedefs/function_typedefs.dart`
- **Söyle:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.
- **Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz. Düz fonksiyon `isA<Mapper<...>>()` ile doğrulanır.
- **Düzelt:** "/dartadvance Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback ve validator tiplerini bul, `typedef` ile adlandır, test yaz."
- **Üret:** "/dartadvance Bana ürün adı, adet ve fiyat alanlarını aynı imzalı doğrulayıcılarla kontrol eden bir sipariş formu yaz."
- **Kıyasla:** Her tekrar eden imza tek bir typedef'e iner; somut fonksiyonlar düz fonksiyon olarak verilir; `isA<Mapper<...>>()` / `isA<Validator<String>>()` geçer; inline ve typedef'li sürüm aynı sonucu verir; `dart analyze` temiz.

### 2. Fonksiyon olmayan typedef: Json ve generic alias (2.13)
- **Aç:** `examples/lib/02_typedefs/json_alias.dart`
- **Söyle:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir.
- **Tuzak:** Alias orijinal tiple birebir aynıdır (`Json == Map<String, Object?>`); `dynamic` değil `Object?` kullan, yoksa `strict-casts` bile seni koruyamaz. JSON sayısı `int` de gelebilir: `(x as num).toDouble()`.
- **Düzelt:** "/dartadvance Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı yerlerini bul, `typedef` alias ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana API'den gelen fatura satırları JSON listesini okuyup tekrar JSON'a çeviren bir Data sınıfı yaz."
- **Kıyasla:** Test `Json == Map<String, Object?>` ve generic alias eşitliğini doğrular; `int` ve `double` değerler kabul edilir (`as double` kullanan olumsuz sürüm `int`'te `TypeError` verir); `dynamic` kalmaz; Domain'e `Json` sızmaz.

### 3. Typedef yeni tip değildir: ID için extension type (3.3)
- **Aç:** `examples/lib/02_typedefs/alias_not_new_type.dart`
- **Söyle:** `typedef UserIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder.
- **Tuzak:** `UserIdAlias == int` ve alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder; `UserId` alan fonksiyona `int` vermeyi analyzer reddeder (testlenemez, yalnızca prose).
- **Düzelt:** "/dartadvance Projemde `typedef X = int` gibi alias'la ID ya da birim tipi tanımlayan yerleri bul, `extension type` ile dönüştür, test yaz."
- **Üret:** "/dartadvance Bana sipariş numarası ile müşteri numarasının karışmasını derleme anında engelleyen bir fatura servisi yaz."
- **Kıyasla:** Test eski alias'ın `int`'e eşit olduğunu ve yanlış değerin kabul edildiğini gösterir; extension type `.value` ile sarılı değeri verir; yanlış ID için derleme hatasının analyzer tarafından verildiği yorumda yazılıdır.

### 4. Record alias: isimli alanlı typedef (3.0)
- **Aç:** `examples/lib/02_typedefs/record_alias.dart`
- **Söyle:** Bir record tipine isim verir; alanlar isimliyse `p.lat` okunur, sıra karışması anlam karıştırmaz.
- **Tuzak:** Konumsal `(double, double)` içinde `lng`, `lat` yerine yazılsa da derlenir; `.$1` enlem diye boylamı okur.
- **Düzelt:** "/dartadvance Projemde konum, boyut ya da aralık için `(double, double)` gibi konumsal record kullanan yerleri bul, isimli alanlı `typedef` ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana mağaza seçme ekranı için konumu ve seçim callback'ini typedef ile adlandıran bir harita sınıfı yaz."
- **Kıyasla:** Konumsal record kalmaz; `store().lat == 41.0`; `OnPicked` callback'i `Point` alır; `dart analyze` temiz.

### 5. Fonksiyon typedef'inde isimli parametre
- **Aç:** `examples/lib/02_typedefs/named_params.dart`
- **Söyle:** Aynı türden parametreleri olan typedef'te parametreleri isimli (`required`) yaz; çağıran da fonksiyon da adıyla eşleşir.
- **Tuzak:** `String Function(String, String, int)` sırası ters yazılmış bir fonksiyonu da kabul eder; havale ters yönde gider. İsimli typedef bunu analyzer'a reddettirir.
- **Düzelt:** "/dartadvance Projemde aynı türden konumsal parametreleri olan callback ve typedef tiplerini bul, parametrelere isim ver (`required` isimli), test yaz."
- **Üret:** "/dartadvance Bana havale ekranı için gönderen, alıcı ve kuruş alan isimli bir typedef ve onu kullanan bir fonksiyon yaz."
- **Kıyasla:** Typedef'te aynı türden konumsal parametre kalmaz; `send(transfer) == 'ali -> veli: 5000'`; sırası ters fonksiyon analyzer'da reddedilir.

### 6. AsyncResult: Future<Result<T>> için alias
- **Aç:** `examples/lib/02_typedefs/async_result.dart`
- **Söyle:** `typedef AsyncResult<T> = Future<Result<T>>` her repository imzasında tekrar eden tipi bir isme indirir.
- **Tuzak:** Alias yeni tip değildir: `AsyncResult<int> == Future<Result<int>>`, sonuç aynıdır; kazanç imzayı tek yerden değiştirebilmektir.
- **Düzelt:** "/dartadvance Projemde `Future<Result<T>>` imzasını her repository metodunda tekrar eden yerleri bul, `typedef AsyncResult<T>` ile adlandır, test yaz."
- **Üret:** "/dartadvance Bana stok ve fiyat sorgulayan, hata fırlatmayıp sonuç dönen bir repository yaz; dönüş tipi tek bir typedef olsun."
- **Kıyasla:** Repository imzalarında `Future<Result<` kalmaz; `AsyncResult<int> == Future<Result<int>>`; `switch` ile `Ok`/`Err` ayrılır; `dart analyze` temiz.

### 7. Record alias ne zaman class olur
- **Aç:** `examples/lib/02_typedefs/record_vs_class.dart`
- **Söyle:** Alias okunabilirliği çözer, anlamı çözmez; aynı türden 3'ten fazla alan ya da davranış gerekiyorsa class kullan.
- **Tuzak:** `(String, int, int, int)` içinde `$2 * $4` adet ile indirimi çarpar; derlenir, toplam `150` çıkar, doğrusu `1300`.
- **Düzelt:** "/dartadvance Projemde 3'ten fazla alanlı ya da aynı türden alanları olan record alias'larını bul, sınıfa çevir, alanları isimlendir, test yaz."
- **Üret:** "/dartadvance Bana sepet satırını (ad, adet, kuruş, indirim) tutan ve satır toplamını hesaplayan bir sınıf yaz."
- **Kıyasla:** Aynı türden art arda alan içeren record alias kalmaz; `CartLine(...).total == 1300`; `dart analyze` temiz.


---

## Bölüm 03 · Class tasarımı

**Neden:** bir sınıfın dışarıya nasıl açıldığı üç araçla söylenir: modifier (kim extend/implement eder), `package:meta` annotation'ı (analyzer neyi uyarır) ve library sınırı (`_`, `part`). Üçü birlikte, yeni bir durum eklendiğinde ya da bir kural çiğnendiğinde hatayı ekrana çıkmadan yakalatır.

### 1. sealed + exhaustive switch (3.0)
- **Aç:** `examples/lib/03_class_design/sealed_order_state.dart`
- **Söyle:** `sealed` kök doğrudan construct edilemez, alt tipleri aynı library'de kapalıdır; `switch` tüm alt tipleri kapsamazsa analyzer reddeder.
- **Tuzak:** `_` eklersen yeni alt tip eklendiğinde switch sessizce ona düşer, hata vermez; `_` yazma. `sealed` geçişli değildir: alt tipi `final` yapmazsan dışarıdan extend edilir (analyzer buna itiraz etmez).
- **Düzelt:** "/dartadvance Projemde durumu `_`/default'lu switch ya da if-else zinciriyle ayıran yerleri bul, `sealed` aile + `_`'siz switch ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana ödeme sonucunu (başarılı, reddedildi, beklemede) ekran metnine çeviren bir fonksiyon yaz."
- **Kıyasla:** Kök `sealed`, her alt tip `final class`, projedeki switch'lerde `_` yok; test her alt tip için ayrı metni doğrular; geçici olarak yeni bir alt tip ekle, `dart analyze` `non_exhaustive_switch_expression` hatasını göstersin, sonra geri al.

### 2. final (3.0)
- **Aç:** `examples/lib/03_class_design/final_money.dart`
- **Söyle:** `final class` başka library'den construct edilir ama extend / implement edilemez (analyzer reddeder).
- **Tuzak:** `final` aynı library'de hiçbir şeyi kısıtlamaz ve `implements`'i de kapatır; mock gereken sınıfı `final` yaparsan test yazamazsın (bkz. bölüm 3). Testte yalnızca "dışarıdan construct edilir ve eşitlik çalışır" kanıtlanır; extend/implement reddi analyzer'dadır.
- **Düzelt:** "/dartadvance Projemde alt tiplenmemesi gereken değer sınıflarını bul, `final class` + `==`/`hashCode` ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana faturadaki bir kalemi (ürün adı, adet, birim fiyat) tutan, eşitlik karşılaştırılabilen sınıf yaz."
- **Kıyasla:** Bulunan sınıflar `final`, `==` ve `hashCode` birlikte override edilmiş; test eşit/eşit olmayan durumları doğrular.

### 3. interface vs base (3.0)
- **Aç:** `examples/lib/03_class_design/interface_vs_base.dart`
- **Söyle:** `abstract interface class` dışarıda yalnızca `implements` edilir; `abstract base class` yalnızca `extends` edilir ve **base transitivity** uygulanır: alt tip `base`, `final` veya `sealed` olmak zorunda (düz `class` analyzer'da hata).
- **Tuzak:** `base` sınıfı başka library'de düz `class` ile extend edemezsin; alt tipi `final class` yaz (testteki `_CountingRepository`). Interface'i ise test library'sinde sahte olarak implement edebilirsin (`_FakeRepository`).
- **Düzelt:** "/dartadvance Projemde repository sözleşmelerini ve ortak mantıklı tabanları bul, `abstract interface class` / `abstract base class` ile ayır, test yaz."
- **Üret:** "/dartadvance Bana siparişleri getiren bir repository sözleşmesi ve sonuçları önbellekleyen ortak bir taban yaz."
- **Kıyasla:** Test, interface'i `implements` ile sahteler; base'i `final class ... extends` ile kullanır; paylaşılan mantık test edilir.

### 4. mixin class (3.0)
- **Aç:** `examples/lib/03_class_design/mixin_class.dart`
- **Söyle:** `mixin class` hem `with` hem `extends` ile kullanılır; `abstract mixin class` ise construct edilemez.
- **Tuzak:** Mixin gibi kullanılan sınıfın `extends` / `implements` yapması ya da constructor parametresi olması `mixin class` bildirimini geçersiz kılar (analyzer reddeder); state'i private tut, dışarıya kopya ver (`List.unmodifiable`).
- **Düzelt:** "/dartadvance Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları bul, `mixin class` ile birleştir, test yaz."
- **Üret:** "/dartadvance Bana hem bir sınıfa karıştırılabilen hem miras alınabilen, çalma listesi değişikliklerini kaydeden sınıf yaz."
- **Kıyasla:** Test aynı sınıfı `with` ve `extends` ile kullanır; dışarıdan dönen liste değiştirilemez.

### 5. `@immutable`: state yerinde değişmez (package:meta)
- **Aç:** `examples/lib/03_class_design/cart_line.dart`
- **Söyle:** `@immutable` sınıfta final olmayan alanı `must_be_immutable` ile raporlar. Değişiklik `copyWith` ile yeni nesne olur; `ValueNotifier` ve benzerleri aynı nesneyi yeniden yayınlayınca ekranı yenilemez.
- **Tuzak:** sepet satırında adet yerinde artırılıp aynı nesne yayınlanır; ekran yenilenmez, adet 1'de kalır (test: "mutating in place republishes the same object...").
- **Düzelt:** "/dartadvance Projemde state ve değer nesnesi sınıflarında final olmayan alanları ve bu alanları yerinde değiştirip aynı nesneyi yeniden yayınlayan yerleri bul. @immutable ve copyWith ile düzelt, yeni nesnenin yayınlandığını test et."
- **Üret:** "/dartadvance Bana sepet satırı için @immutable bir state sınıfı ve adet artıran, her değişiklikte yeni nesne yayınlayan bir store yaz."
- **Kıyasla:** state sınıflarında final olmayan alan kalmaz; değişiklik yeni nesneyle yayınlanır; `dart analyze` temiz.

### 6. `@useResult`: dönen değer atılmaz (package:meta)
- **Aç:** `examples/lib/03_class_design/coupon_total.dart`
- **Söyle:** `@useResult` sonucu kullanılmayan çağrıyı `unused_result` ile raporlar. Yeni değer döndüren metot (`copyWith`, `withX`, `add`) orijinali değiştirmez; sonucu atmak sessizce hiçbir şey yapmaz.
- **Tuzak:** YAZ50 kuponu uygulandı" yazar ama ödenecek tutar 250,00 ₺ kalır (test: "a dropped @useResult value leaves the total unchanged").
- **Düzelt:** "/dartadvance Projemde yeni değer döndüren (copyWith, withX, add, apply) metotları ve sonucunu atan çağrıları bul. @useResult ekle, atılan sonuçları düzelt, toplamın değiştiğini test et."
- **Üret:** "/dartadvance Bana sepet toplamı için kupon indirimini uygulayıp yeni toplam döndüren bir sınıf yaz; sonucu atılırsa analyzer uyarsın."
- **Kıyasla:** yeni değer döndüren metotlarda `@useResult` var; atılan sonuç kalmaz; tutarın değiştiği test edilir; `dart analyze` temiz.

### 7. `@protected`: durumu yalnız alt sınıf değiştirir (package:meta)
- **Aç:** `examples/lib/03_class_design/order_store.dart` · `examples/lib/03_class_design/pay_button.dart`
- **Söyle:** `@protected` üyeyi alt sınıflara ayırır; başka library'den çağrı `invalid_use_of_protected_member` uyarısı verir. Store'un `emit`'i korunur, ekran yalnız iş metodunu (`pay`, `submit`) çağırır; doğrulama atlanamaz.
- **Tuzak:** ekran `emit(paid)`'i doğrudan çağırır; kart reddedildiği hâlde "Ödendi · Sipariş hazırlanıyor" görünür (test: "emitting from the screen skips validation...").
- **Düzelt:** "/dartadvance Projemde ekran, widget ya da başka bir library'den store'un emit / setState / value = metodunu doğrudan çağıran yerleri bul. Taban metoda @protected ekle, ekranın iş metodunu (pay, submit) çağırdığını test et."
- **Üret:** "/dartadvance Bana ödeme ekranı için yalnız store.pay çağıran bir buton sınıfı yaz."
- **Kıyasla:** taban sınıfta durum değiştiren metot `@protected`; ekran/widget katmanında `emit` çağrısı kalmaz; `dart analyze` temiz.

### 8. `@mustCallSuper`: temizlik atlanmaz (package:meta)
- **Aç:** `examples/lib/03_class_design/chat_controller.dart`
- **Söyle:** `@mustCallSuper` override'ın `super` çağırmasını zorlar; eksikse `must_call_super` uyarısı verir. Taban sınıfın `dispose`'u abonelik, timer, listener kapatır; alt sınıf unutursa ekran kapandıktan sonra da çalışırlar.
- **Tuzak:** sohbetten çıkınca gelen 3 mesaj "okundu" işaretlenir; karşı taraf "görüldü" görür (test: "dispose without super keeps marking messages as read").
- **Düzelt:** "/dartadvance Projemde dispose, close, cancel gibi temizlik yapan taban sınıf metotlarını ve override edip super çağırmayan alt sınıfları bul. Tabana @mustCallSuper ekle, ekrandan çıkınca dinleyicinin kapandığını test et."
- **Üret:** "/dartadvance Bana gelen mesajları dinleyen bir sohbet controller'ı yaz; taban sınıf dispose'da aboneliği kapatsın, alt sınıflar super.dispose() çağırmak zorunda olsun."
- **Kıyasla:** temizlik yapan taban metotlarda `@mustCallSuper`; tüm override'lar `super` çağırır; ekrandan çıkınca dinleyicinin kapandığı test edilir; `dart analyze` temiz.

### 9. Library seviyesinde gizlilik (her sürüm)
- **Aç:** `examples/lib/03_class_design/library_privacy.dart`
- **Söyle:** `_` ile başlayan isim sınıfa değil library'ye özeldir; aynı dosyadaki her sınıf görür, başka dosya (test dahil) göremez.
- **Tuzak:** `WalletAuditor` aynı dosyada olduğu için `Wallet._balanceCents` alanını okuyup yazar (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde `_` alanına aynı dosyadaki başka sınıfın eriştiği yerleri bul, library gizliliği kuralıyla ayır veya bilerek kabul et, her biri için test yaz."
- **Üret:** "/dartadvance Bana bakiyesi gizli tutulan bir Coupon sınıfı ve eksiye düşeni sıfırlayan denetçisini yaz."
- **Kıyasla:** Aynı dosyadan `_` erişimi ya ayrı dosyaya taşınarak derleme hatasına çevrildi ya da bilerek bırakıldı ve testle sabitlendi; `dart analyze` temiz.

### 10. `part` / `part of` (2.0)
- **Aç:** `examples/lib/03_class_design/part_files/order_builder.dart`
- **Söyle:** Bir library'yi birden çok dosyaya böler; part dosyası library'nin private isimlerini ve import'larını paylaşır.
- **Tuzak:** Part'taki `_Line` tipi ve `Queue` (ana dosyanın `dart:collection` import'u) ana dosyada kullanılır; part import'suz çalışır (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde elle yazılmış sınıfı `part` ile böldüğüm yerleri bul, `part of` string URI ve import kurallarıyla düzelt, her biri için test yaz."
- **Üret:** "/dartadvance Bana fatura satırı hesaplarını ayrı dosyaya bölen bir InvoiceBuilder sınıfı yaz."
- **Kıyasla:** Part dosyasında `import` yok, `part of '<dosya>.dart';` string URI ile; el yazımı bölünmeler küçük library'lere ayrıldı veya gerekçelendirildi; davranış testle doğrulanır.


---

## Bölüm 04 · Collection

**Neden:** boş listede çöken ekranlar, sırasız gelen veride bozulan başlıklar, identity `==` yüzünden yanlış açık kalan butonlar ve yerinde değişen state en sık koleksiyon hatalarıdır. `package:collection` bunların çoğunu tek çağrıyla çözer.

### 1. Belki yok: `firstWhereOrNull` (package:collection)
- **Aç:** `examples/lib/04_collection/address_book.dart`
- **Söyle:** `firstWhere` eşleşme yoksa `StateError` atar; `orElse` nullable olmayan tip ister. `firstWhereOrNull` null döner. Koşulsuz olanlar (`firstOrNull`, `lastOrNull`, `singleOrNull`, `elementAtOrNull`) 3.0'dan beri `dart:core`'da.
- **Tuzak:** varsayılan adresi olmayan yeni kullanıcıda ödeme ekranı `StateError: No element` ile açılmaz (test: "firstWhere throws when there is no default").
- **Düzelt:** "/dartadvance Projemde firstWhere, singleWhere, lastWhere ve boş olabilecek listede first/last kullanan yerleri bul. firstWhereOrNull (koşulsuzsa dart:core firstOrNull) ile düzelt, boş durum için test yaz."
- **Üret:** "/dartadvance Bana ödeme ekranı için varsayılan teslimat adresini seçen bir sınıf yaz; adres yoksa null dönsün, ekran "Adres ekle" göstersin."
- **Kıyasla:** belki-yok aramalarında `firstWhere`/`first` kalmaz; boş durum test edilir; `dart analyze` temiz.

### 2. Başlık altında liste: `groupBy`
- **Aç:** `examples/lib/04_collection/order_history.dart`
- **Söyle:** `groupBy(items, key)` `Map<K, List<V>>` kurar; ilk görülen anahtarın sırası korunur. Elle gruplama listenin sıralı geldiğini varsayar.
- **Tuzak:** API listeyi duruma göre sıralı gönderince "Ekim" başlığı iki kez çıkar (test: "consecutive headers repeat a month").
- **Düzelt:** "/dartadvance Projemde listeyi tarih, kategori ya da durum başlıkları altında gösteren ve gruplamayı elle (önceki elemanla karşılaştırarak ya da Map kurarak) yapan yerleri bul. groupBy ile düzelt, sırasız girdiyle test yaz."
- **Üret:** "/dartadvance Bana sipariş geçmişini ay başlıkları altında gösteren bir bölüm listesi kuran sınıf yaz."
- **Kıyasla:** her başlık bir kez; sırasız girdiyle test; `dart analyze` temiz.

### 3. İçerik eşitliği: `ListEquality` / `SetEquality` / `DeepCollectionEquality`
- **Aç:** `examples/lib/04_collection/filter_draft.dart`
- **Söyle:** `List`, `Set`, `Map` için `==` nesneye bakar: `{'a'} == {'a'}` false. Equality sınıfları içeriği karşılaştırır; koleksiyon alanlı sınıfın `==` ve `hashCode`'u aynı Equality ile yazılır.
- **Tuzak:** filtre sheet'inde hiçbir şey değişmeden "Uygula" açık kalır (test: "!= on sets compares identity").
- **Düzelt:** "/dartadvance Projemde iki List, Set ya da Map'i == veya != ile karşılaştıran yerleri ve koleksiyon alanı olan sınıfların == metotlarını bul. ListEquality, SetEquality ya da DeepCollectionEquality ile düzelt, aynı içerikli iki ayrı nesneyle test yaz."
- **Üret:** "/dartadvance Bana filtre sheet'i için uygulanan ve taslak seçimi karşılaştıran, değişiklik yoksa "Uygula"yı kapatan bir sınıf yaz."
- **Kıyasla:** koleksiyonlar `==`/`!=` ile karşılaştırılmaz; aynı içerikli iki ayrı nesneyle test; `dart analyze` temiz.

### 4. Parçalara bölmek: `slices`
- **Aç:** `examples/lib/04_collection/product_grid.dart`
- **Söyle:** `slices(n)` listeyi n'lik parçalara böler, son parça kalan kadardır. Elle `sublist(i, i + n)` son parçada uzunluğu aşar.
- **Tuzak:** 7 ürün satırda 3'erli bölünürken son satırda `RangeError` atar, ürünler yüklenmez (test: "sublist overruns the last row").
- **Düzelt:** "/dartadvance Projemde listeyi satırlara, sayfalara ya da n'lik paketlere bölen ve sublist / elle indeks hesabı kullanan yerleri bul. slices ile düzelt, n'e tam bölünmeyen uzunlukla test yaz."
- **Üret:** "/dartadvance Bana ürünleri her satırda 3 tane olacak şekilde satırlara bölen bir sınıf yaz."
- **Kıyasla:** elle `sublist` ile bölme kalmaz; n'e tam bölünmeyen uzunlukla test; `dart analyze` temiz.

### 5. Sıralama: `sortedBy` ve doğru karşılaştırıcı
- **Aç:** `examples/lib/04_collection/price_sort.dart`
- **Söyle:** Karşılaştırıcı `int` döndürür; `(a - b).toInt()` küçük farkları 0 yapar. `sortedBy` anahtarı `compareTo` ile karşılaştırır ve yeni liste döndürür, kaynağa dokunmaz.
- **Tuzak:** 19,90 ₺ ile 19,50 ₺ eşit sayılır, "Fiyat: artan" 19,90'ı önce gösterir (test: "toInt comparator treats 19.9 and 19.5 as equal").
- **Düzelt:** "/dartadvance Projemde sort karşılaştırıcısında çıkarma (a - b), toInt ya da round kullanan yerleri ve kaynağı yerinde sıralayan sort çağrılarını bul. sortedBy / compareTo ile düzelt, yakın fiyatlarla test yaz."
- **Üret:** "/dartadvance Bana ürün listesini fiyata göre artan ve azalan sıralayan, kaynak listeyi değiştirmeyen bir sınıf yaz."
- **Kıyasla:** karşılaştırıcıda çıkarma/`toInt` kalmaz; yakın fiyatlarla test; `dart analyze` temiz.

### 6. Öncelik kuyruğu: `PriorityQueue`
- **Aç:** `examples/lib/04_collection/upload_queue.dart`
- **Söyle:** `PriorityQueue` heap'tir: ekleme ve `removeFirst` O(log n), en öncelikli eleman hep başta. Liste ya da `Queue` eklenme sırasıyla verir. Eşit öncelikte ekleniş sırası garanti değil; gerekiyorsa ikinci anahtar ekle.
- **Tuzak:** en son seçilen kimlik fotoğrafı 4. sırada bekler, onay gecikir (test: "a List keeps insertion order").
- **Düzelt:** "/dartadvance Projemde öncelikli iş kuyruğu (yükleme, bildirim, senkronizasyon) tutup her eklemede sort çağıran ya da öncelik yerine eklenme sırasını kullanan yerleri bul. PriorityQueue ile düzelt, sona eklenen yüksek öncelikli işle test yaz."
- **Üret:** "/dartadvance Bana belge yükleme kuyruğu yaz: kimlik gibi öncelikli belgeler, sonradan eklense de önce yüklensin."
- **Kıyasla:** öncelikli kuyrukta her eklemede `sort` kalmaz; sona eklenen yüksek öncelikli işle test; `dart analyze` temiz.

### 7. Değiştirilemez state: `IList` (fast_immutable_collections)
- **Aç:** `examples/lib/04_collection/cart_history.dart`
- **Söyle:** `List.add` yerinde değiştirir; önceki state aynı listeyi tuttuğu için o da değişir. `IList` değiştirilemez: `add` yeni liste döndürür, eşitlik içeriğe bakar, büyük listede yapısal paylaşımla hızlıdır. Yalnız dışarıya açmamak yetiyorsa `UnmodifiableListView` (`dart:collection`).
- **Tuzak:** sepete eklenen Termos "Geri al" sonrası da sepette kalır (test: "List.add changes the previous state too").
- **Düzelt:** "/dartadvance Projemde state sınıflarında List/Set/Map alanlarını yerinde değiştiren (add, remove, ..add, []=) yerleri bul. IList/ISet/IMap'e geç ya da yeni koleksiyon üret; önceki state'in değişmediğini test et."
- **Üret:** "/dartadvance Bana 'Geri al' destekli sepet state'i yaz: her ekleme yeni state üretsin, öncekiler değişmesin. fast_immutable_collections kullan."
- **Kıyasla:** state'te yerinde değiştirilen koleksiyon kalmaz; önceki state'in değişmediği testle görülür; `dart analyze` temiz.

### 8. Null-aware element `?` (3.8)
- **Aç:** `examples/lib/04_collection/profile_patch.dart`
- **Söyle:** `{'bio': bio}` null değeri de gönderir; `'bio': ?bio` null ise anahtarı hiç eklemez. Liste ve widget listesinde de aynı: `[?subtitle]`.
- **Tuzak:** yalnız adı değişen PATCH `"bio": null` gönderir, sunucu kayıtlı bio'yu siler (test: "a null bio in the body erases the stored one").
- **Düzelt:** "/dartadvance Projemde istek gövdesi, query parametresi ya da widget listesi kurarken null değeri gönderen veya if (x != null) yazan yerleri bul. 'key': ?value ve ?widget ile düzelt, gönderilen gövdeyi testle kontrol et. SDK 3.8 altındaysa önce söyle."
- **Üret:** "/dartadvance Bana profil düzenleme için yalnız değişen alanları gönderen bir PATCH gövdesi kuran sınıf yaz."
- **Kıyasla:** istek gövdesinde null alan gitmez; gönderilen gövde testle kontrol edilir; `dart analyze` temiz.


---

## Bölüm 05 · Event loop ve Future

**Neden:** Sıralı `await` ve sessizce yutulan ateşle-unut hatalar Flutter'da yavaş ekran ve görünmeyen hata olarak karşına çıkar.

### 1. Event loop sırası (her sürüm)
- **Aç:** `examples/lib/05_event_loop_future/event_loop_order.dart`
- **Söyle:** Önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu (`Timer.run`, `Future()`) çalışır.
- **Tuzak:** `async` fonksiyon ilk `await`'e kadar senkron çalışır; çağıran, `await` etmese bile o kısmı hemen görür.
- **Düzelt:** "/dartadvance Projemde `scheduleMicrotask`, `Timer.run` veya `Future(...)` ile sıra varsayan yerleri bul, event loop sırasına göre düzelt, test yaz."
- **Üret:** "/dartadvance Bana sipariş onaylanınca önce ekran durumunu güncelleyip, işlem bittikten sonra analitik olayını gönderen bir fonksiyon yaz."
- **Kıyasla:** Test sırayı `sync → microtask → event` olarak, `await`'li fonksiyonun durum adımını analitikten önce bitirdiğini (beklenmeyen sürümün ise analitik olmadan döndüğünü) doğrular; `dart analyze` temiz.

### 2. Future.wait ve record `.wait` (3.0)
- **Aç:** `examples/lib/05_event_loop_future/parallel_wait.dart`
- **Söyle:** Bağımsız istekleri aynı anda başlatıp bekler; record `.wait` her alanın tipini korur.
- **Tuzak:** `Future.wait` sonuçları verilen sırayla döner ve yalnız ilk hatayı bildirir; başarılı değerlere `ParallelWaitError.values` ile ulaşılır.
- **Düzelt:** "/dartadvance Projemde birbirine bağlı olmayan `await`'leri art arda yazan repository yerlerini bul, record `.wait` ile paralel yap, test yaz."
- **Üret:** "/dartadvance Bana bir ürün sayfası için ürün detayını, yorumları ve stok bilgisini getiren bir fonksiyon yaz."
- **Kıyasla:** Test bağımsız çağrıların birlikte başladığını (başlangıç sırası) ve kısmi başarıyı (`values`) kapsar; `dart analyze` temiz.

### 3. timeout ve Completer (her sürüm)
- **Aç:** `examples/lib/05_event_loop_future/timeout_completer.dart`
- **Söyle:** `Completer` callback API'sini `Future`'a çevirir; `.timeout` bekleme süresini sınırlar.
- **Tuzak:** `timeout` kaynak future'ı iptal etmez; geç gelen sonuç yok sayılır, `Completer` ikinci kez tamamlanırsa `StateError` atar (`isCompleted` ile koru).
- **Düzelt:** "/dartadvance Projemde callback tabanlı eski API'leri, süresiz bekleyen çağrıları bul, `Completer` ile Future'a çevir, `timeout` ile sınırla, test yaz."
- **Üret:** "/dartadvance Bana callback ile sonuç veren eski bir ödeme SDK'sını saran, 10 sn'de cevap gelmezse hata veren bir fonksiyon yaz."
- **Kıyasla:** Test sessiz SDK'de `TimeoutException`'ı, çift callback'te yalnız ilk sonucu doğrular; süresiz bekleyen çağrı kalmaz.

### 4. unawaited, ignore ve ateşle-unut hatalar (unawaited 2.15, ignore 2.14)
- **Aç:** `examples/lib/05_event_loop_future/fire_and_forget.dart`
- **Söyle:** `unawaited` "bilerek beklemiyorum" der; `ignore()` hatayı da yutar.
- **Tuzak:** `unawaited` hatayı yutmaz; hata yine işlenmemiş (unhandled) olur, `ignore()` ise sessizce yutar.
- **Düzelt:** "/dartadvance Projemde beklenmeden çağrılan Future'ları (`unawaited`) bul, hatasını `catchError` ile ele alacak şekilde düzelt, test yaz."
- **Üret:** "/dartadvance Bana fatura ekranı açılırken sonucu beklemeden önbelleği ısıtan, hatayı kaybetmeyen bir fonksiyon yaz."
- **Kıyasla:** Test hatanın zone'a sızmadığını ve `catchError` ile raporlandığını doğrular; `dart analyze` temiz.


---

## Bölüm 06 · Streams

**Neden:** Flutter'da sızan `listen`, ikinci dinleyicide `StateError` ve dinlenmeden açılan kaynak en sık görülen stream hatalarıdır; bu beş desen hepsini kapatır.

### 1. Single-subscription ve broadcast (2.x)
- **Aç:** `examples/lib/06_streams/stream_kinds.dart`
- **Söyle:** Varsayılan stream tek dinleyici kabul eder; `StreamController.broadcast()` çok dinleyici kabul eder ve dinleyicisiz olayları düşürür.
- **Tuzak:** Single-subscription'a ikinci `listen` `StateError` atar, ilk abonelik cancel edilse bile (test kanıtlıyor).
- **Düzelt:** "/dartadvance Projemde aynı stream'i birden çok yerde dinleyen yerleri bul, single-subscription/broadcast ayrımıyla düzelt, test yaz."
- **Üret:** "/dartadvance Bana stok değişimlerini hem ekrana hem log'a aynı anda ileten bir sınıf yaz."
- **Kıyasla:** Çoklu dinlenen akış `isBroadcast`; iki dinleyici aynı olayı aldı; ikinci `listen` `StateError` atmıyor; mevcut testler ve `dart analyze` yeşil.

### 2. `async*` generator (2.x)
- **Aç:** `examples/lib/06_streams/async_generator.dart`
- **Söyle:** `async*` + `yield` ile tembel stream üretir; dinleyici durunca `finally` çalışır ve sonraki sayfa istenmez.
- **Tuzak:** `take(3)` gibi erken durma sonraki sayfayı çağırmaz ve `finally` bir kez çalışır (test kanıtlıyor).
- **Düzelt:** "/dartadvance Projemde sayfaları hepsini çekip listeye dönen yerleri bul, `async*` ile tembel Stream'e çevir, erken iptali de kapsayan test yaz."
- **Üret:** "/dartadvance Bana sayfa sayfa gelen ürün yorumlarını akıtan, ilk 5'te bırakılınca bağlantıyı kapatan bir fonksiyon yaz."
- **Kıyasla:** Dönüştürülen her yerde sayfalar sırayla geldi; `take(n)` sonrası fazladan sayfa istenmedi; temizlik bir kez çalıştı; analyze temiz.

### 3. StreamController callback'leri (2.x)
- **Aç:** `examples/lib/06_streams/controller_callbacks.dart`
- **Söyle:** `onListen`, `onPause`, `onResume`, `onCancel` ile kaynak yalnız birisi dinlerken çalışır.
- **Tuzak:** `onListen`/`onCancel` olmadan Timer dinleyicisiz de okur ve iptal sonrası sürer; callback'li akışta kaynak kapalı kalır (test kanıtlıyor).
- **Düzelt:** "/dartadvance Projemde Timer, soket veya sensörü dinlenmeden başlatan yerleri bul, `StreamController` onListen/onCancel ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana sıcaklık sensörünü yalnız biri dinlerken okuyan, dinleyen kalmayınca durduran bir akış yaz."
- **Kıyasla:** Dinleyici yokken kaynak okunmadı (sayaç/log boş); ilk `listen` sonrası kaynak başladı; `cancel` sonrası `onCancel` çalıştı ve sayaç artmayı bıraktı; testler ve `dart analyze` yeşil.

### 4. `StreamTransformer` (2.x)
- **Aç:** `examples/lib/06_streams/message_transformer.dart`
- **Söyle:** `transform()` ile stream'i yeniden biçimlendirir; `fromHandlers` olay başına sink'e 0..n çıktı yazar.
- **Tuzak:** Sink'e eklemediğin olay sessizce düşer; kırpılan boş mesaj çıktıda yoktur (test kanıtlıyor).
- **Düzelt:** "/dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul, `StreamTransformer.fromHandlers` ile dönüştür, test yaz."
- **Üret:** "/dartadvance Bana fatura satırı metinlerini kırpıp boşları atan, kalanları büyük harfe çeviren bir stream dönüştürücü yaz."
- **Kıyasla:** Dönüşen her akışta davranış aynı: beklenen olaylar sırayla geldi, süzülenler düştü; testler yeşil.

### 5. Dinleyen state sınıfı ve dispose (2.x)
- **Aç:** `examples/lib/06_streams/price_watcher.dart`
- **Söyle:** Subscription alanda tutulur, `dispose()`'da `await cancel()` ve `null` yapılır; düz Dart, kütüphane yok.
- **Tuzak:** `dispose` sonrası gelen olay state'i değiştirmez; `start` iki kez çağrılsa tek abonelik olur (`??=`) (test kanıtlıyor).
- **Düzelt:** "/dartadvance Projemde stream dinleyip dispose'da cancel etmeyen state'leri bul, subscription'ı alanda tutup `await cancel()` ile düzelt, test yaz."
- **Üret:** "/dartadvance Bana çalma listesindeki şarkı değişimlerini dinleyip son şarkıyı tutan, kapatılınca dinlemeyi bırakan bir sınıf yaz."
- **Kıyasla:** Bulunan her state sınıfında `dispose` sonrası kaynağın `onCancel`'ı çalıştı; geç gelen olay state'i değiştirmedi; kaynak birden çok dinleyiciye gidiyorsa ayrıca `isBroadcast` ve iki dinleyici testi var.


---

## Bölüm 07 · package:async

**Neden:** Arama kutusu, config yükleme ve stream okuma kodları sessizce eski yanıtı gösterir ya da aynı işi tekrar tekrar yapar; `package:async` bunları tek satırda çözer.

### 1. CancelableOperation (2.x)
- **Aç:** `examples/lib/07_async_package/cancelable_search.dart`
- **Söyle:** Bir `Future`'ı iptal edilebilir sarar; iptalde sonuç atılır, `valueOrCancellation()` `null` döner.
- **Tuzak:** Olumsuz sürümde yavaş eski cevap en son gelip ekranı ezer. İptal alttaki isteği durdurmaz, yalnızca sonucunu yok sayar; tamamlanmış işte `cancel()` bir şey yapmaz (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde her tuş vuruşunda istek atan arama yerlerini bul, CancelableOperation (package:async) ile son sorgu kazansın, her biri için test yaz."
- **Üret:** "/dartadvance Bana kullanıcı yazdıkça şehir önerisi getiren, eski sorgunun geç gelen cevabını yok sayan bir sınıf yaz."
- **Kıyasla:** Eski çağrı `null`, yeni çağrı değer döner; eski cevabın geç gelmesi sonucu ezmez; `hide Result` kullanılır; `dart analyze` temiz.

### 2. AsyncMemoizer (2.x)
- **Aç:** `examples/lib/07_async_package/async_memoizer.dart`
- **Söyle:** Async işi bir kez çalıştırır, sonraki/eşzamanlı çağıranlar aynı future'ı alır.
- **Tuzak:** Hata da sonsuza kadar saklanır, tekrar denenmez (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde tekrar tekrar yüklenen config/liste yerlerini bul, AsyncMemoizer (package:async) ile tek seferlik yap, her biri için test yaz."
- **Üret:** "/dartadvance Bana ödeme ayarlarını ağdan yalnız bir kez yükleyip eşzamanlı çağıranlarla paylaşan bir sınıf yaz."
- **Kıyasla:** Eşzamanlı ve sonraki çağrılarda yükleyici sayacı 1 kalır; `hasRun` doğrulanır.

### 3. AsyncCache (2.x)
- **Aç:** `examples/lib/07_async_package/async_cache.dart`
- **Söyle:** Sonucu süre boyunca taze tutar; `invalidate()` ile sıfırlanır.
- **Tuzak:** Başarısız istek de TTL boyunca önbellekte kalır (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde kur/fiyat/stok gibi veriyi her okumada çeken yerleri bul, AsyncCache (package:async) ile TTL'li önbelleğe al, her biri için test yaz."
- **Üret:** "/dartadvance Bana sipariş kargo ücretini 30 saniye boyunca tekrar istemeden hatırlayan bir servis yaz."
- **Kıyasla:** TTL içinde tek fetch; `invalidate` sonrası ikinci fetch; `Duration.zero` ile her okumada yenilenir (süre dolumu zamanlayıcıyla olur; testte ardışık okumaların arasına `await Future<void>.delayed(Duration.zero)` koy).

### 4. StreamQueue (2.x)
- **Aç:** `examples/lib/07_async_package/stream_queue.dart`
- **Söyle:** Stream'i pull-based okutur: `next`, `take(n)`, `peek`, `hasNext`, `rest`.
- **Tuzak:** Stream biterse `next` `StateError` fırlatır; önce `hasNext` sor, işin bitince `cancel()` et (testte kanıtlı).
- **Düzelt:** "/dartadvance Projemde başlık+gövde sırayla okunan stream parse yerlerini bul, StreamQueue (package:async) ile düzelt, her biri için test yaz."
- **Üret:** "/dartadvance Bana ilk satırı 'FATURA 3' gibi kalem sayısı, sonra o kadar satırı okuyan bir fatura parser'ı yaz."
- **Kıyasla:** Başlıktaki sayı kadar öğe döner; `finally` içinde `queue.cancel()` vardır; tek-abonelikli stream'e ikinci `listen` yoktur.

### 5. StreamGroup ve StreamSplitter (2.x)
- **Aç:** `examples/lib/07_async_package/stream_group.dart`
- **Söyle:** `StreamGroup.merge` birçok kaynağı tek stream yapar; `StreamSplitter` tek-abonelikli stream'i birden çok tüketiciye tüm olaylarla verir.
- **Tuzak:** `asBroadcastStream` geç dinleyiciye eski olayları vermez, splitter verir (testte kanıtlı); merge ancak tüm kaynaklar kapanınca kapanır.
- **Düzelt:** "/dartadvance Projemde aynı stream'i iki kez dinleyen yerleri bul, StreamSplitter ve StreamGroup (package:async) ile düzelt, her biri için test yaz."
- **Üret:** "/dartadvance Bana çalma listesi stream'inden şarkı sayısını ve toplam süreyi tek geçişte hesaplayan fonksiyon yaz."
- **Kıyasla:** Splitter'ın her kolu tüm olayları görür (yanlış çift dinleme `StateError` verirdi); merge iki kaynaktan da olay iletir, ikisi kapanınca biter.


---

## Bölüm 08 · Isolates

**Neden:** Flutter'da JSON/parse işi frame kaçırtır; `compute` ve `Isolate.run` closure'ın ne yakaladığına bakmadan yazılınca sessizce yavaşlar ya da patlar.

### 1. Eşikli ağır parse: `Isolate.run` (2.19)
- **Aç:** `examples/lib/08_isolates/decode_orders.dart`
- **Söyle:** Büyük gövde `Isolate.run` ile çözülür, küçük gövde inline kalır.
- **Tuzak:** `Isolate.run` içinde fırlayan hata aynı tipte ana isolate'e gelir (`FormatException` testte tipiyle yakalanır); `Result`'a çevirmeyi RepositoryImpl yapar. Parse fonksiyonu top-level ve saf olmalı. Dosyada `decodeOrdersWrong` (her çağrıda isolate açar) eşikli `decodeOrders` ile yan yana durur.
- **Düzelt:** "/dartadvance Projemde ana isolate'te büyük JSON/CSV/GPX çözen yerleri bul, eşikli `Isolate.run` ile taşı, her biri için test yaz."
- **Üret:** "/dartadvance Bana 3 MB'lık ürün kataloğu JSON'unu Product listesine çeviren bir fonksiyon yaz."
- **Kıyasla:** Her bulunan yerde eşik 1 ve büyük eşik aynı sonucu verir; bozuk girdide `FormatException` tipiyle fırlar; parse fonksiyonu top-level ve saf; `dart analyze` temiz.

### 2. Ne gönderilir, closure ne yakalar (2.19)
- **Aç:** `examples/lib/08_isolates/capture_rules.dart`
- **Söyle:** Mesajlar kopyalanır, global değişken isolate'te ayrı kopyadır, bazı nesneler hiç gönderilemez.
- **Tuzak:** `ReceivePort`, `Socket`, `Pointer`, `Finalizer` gibi nesneyi yakalayan closure `ArgumentError` ile patlar (testli). API dokümanı (dartbug 36983): closure gerekenden fazla durum yakalayabilir; instance metodu içinde closure yazmak `this`'i taşıyabilir. Çözüm: gereken durumu parametre alan ayrı bir fonksiyonda closure kur (testi yok, API notudur).
- **Düzelt:** "/dartadvance Projemde `Isolate.run`/`compute` closure'larını bul, ne yakaladıklarını ve global durumu kurallarıyla düzelt, her biri için test yaz."
- **Üret:** "/dartadvance Bana fatura listesini arka planda sıralayıp KDV toplamını hesaplayan bir fonksiyon yaz."
- **Kıyasla:** Her closure yalnızca gereken parametreyi yakalar; çağıranın verisi değişmez (testli); global mutable duruma bağımlılık kalmaz; `ReceivePort`/`Socket` yakalayan closure yok.

### 3. Sağlam worker: ports, hata ve çıkış (3.0)
- **Aç:** `examples/lib/08_isolates/price_worker.dart`
- **Söyle:** Tekrar eden işi, `onExit` ve ports ile kurulan uzun ömürlü bir isolate'e verir.
- **Tuzak:** Ölü worker asla yanıt vermez; isteği `exited` ile yarıştırmazsan çağıran sonsuza kadar bekler. Worker'daki hata `RemoteError` değeri olarak döner; `close()` sonrası istek `StateError` verir (üçü de testli). Dosyada `withTaxWrong` yan yana: ölü worker'da takılır, `RemoteError`'u `TypeError`'a çevirir (testli).
- **Düzelt:** "/dartadvance Projemde her mesaj/satır için sürekli isolate açan yerleri bul, ports ve `onExit` ile uzun ömürlü worker'a çevir, her biri için test yaz."
- **Üret:** "/dartadvance Bana sipariş satırları art arda geldikçe indirim hesaplayan, açık kalan bir arka plan hesaplayıcısı yaz."
- **Kıyasla:** Her dönüştürülen yerde sıralı ve eşzamanlı istekler doğru cevaplanır; hata `RemoteError` gelir; `close()` sonrası `exited` tamamlanır ve yeni istek `StateError` verir.

# 01 · Built-in types
> Kaynak: https://dart.dev/language/built-in-types · https://dart.dev/language/operators · https://dart.dev/language/records · https://dart.dev/language/variables · https://api.dart.dev/dart-core/DateTime/toLocal.html · Min. sürüm: 3.0 (record), diğerleri her sürüm

Bildiğini sandığın tipler. Sayı, metin, record, tarih ve cascade her satırda var; buradaki hatalar derlenir, testte görünmez, kullanıcının ekranında çıkar. Her bölüm gerçek bir Flutter ekranındaki hatayı ve düzeltmesini gösterir.

## 1. Fiyat: `double` değil kuruş `int`
**Ne:** `double.toString` ekran için değildir: `.0` ve tek haneli kuruş bırakır, toplamada kuruş kaçırır. Fiyat kuruş `int` tutulur; `~/ 100` lira, `% 100` kuruş, `replaceAllMapped` binlik nokta. **Ne zaman:** fiyat, indirim, sepet, fatura; ekrana yazılan her tutar. **Gerekmez:** ekrana yazılmayan ölçüm değerleri (konum, oran); `intl` zaten kullanılıyorsa biçimlendirme `NumberFormat` ile.
<!-- snippet: 01_builtin_types/product_price -->
```dart
// Düzelt: /dartadvance Projemde fiyatı double tutan ya da ekrana $price, toString veya
//    toStringAsFixed ile yazan yerleri bul. Kuruş int'e çevir, ~/ 100, % 100 ve binlik nokta ile
//    yazdır, 2499990 girdisiyle test yaz.
// Üret: /dartadvance Bana ürün kartı için fiyat etiketi yaz: kuruş int alsın, 24.999,90 ₺
//    biçiminde yazsın, eski fiyatı da göstersin.

/// Product card: sale price and the struck-through old price.
final class ProductPrice {
  // ✗ double.toString is not for screens: '24999.9 ₺', '29999.0 ₺'.
  String labelWrong(double price) => '$price ₺';

  String label(int cents) {
    final lira = '${cents ~/ 100}'.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+$)'),
      (_) => '.',
    );
    return '$lira,${(cents % 100).toString().padLeft(2, '0')} ₺'; // '24.999,90 ₺'
  }
}
```
**Tuzak:** ürün kartı `24999.9 ₺` ve `29999.0 ₺` gösterir (test: "double toString shows a raw number").
**Düzelt (mevcut proje):** > "/dartadvance Projemde fiyatı double tutan ya da ekrana $price, toString veya toStringAsFixed ile yazan yerleri bul. Kuruş int'e çevir, ~/ 100, % 100 ve binlik nokta ile yazdır, 2499990 girdisiyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün kartı için fiyat etiketi yaz: kuruş int alsın, 24.999,90 ₺ biçiminde yazsın, eski fiyatı da göstersin."
**Kabul:** fiyat `int` kuruş; `2499990` → `'24.999,90 ₺'`, `5` → `'0,05 ₺'`; `dart analyze` temiz.

## 2. Döngüsel indeks: `remainder` değil `%`
**Ne:** Dart'ın `%` operatörü Öklid kalanıdır: sonuç her zaman `0` ile `n - 1` arasında. `remainder` bölünenin işaretini alır: `(-1).remainder(5)` → `-1`. **Ne zaman:** galeri/carousel geri-ileri, haftanın günü, sekme döngüsü. **Gerekmez:** indeks hiç negatif olamıyorsa (yalnız ileri).
<!-- snippet: 01_builtin_types/photo_gallery -->
```dart
// Düzelt: /dartadvance Projemde sayfa, sekme ya da gün indeksini remainder ile veya
//    if (i < 0) i = len - 1 gibi elle saran yerleri bul. % ile düzelt, index 0 için test yaz.
// Üret: /dartadvance Bana ürün galerisi için ileri/geri gezinen bir sınıf yaz: ilk fotoğraftan
//    geri son fotoğrafa, sondan ileri ilk fotoğrafa dönsün.

/// Product gallery; "back" on the first photo goes to the last one.
final class PhotoGallery {
  const PhotoGallery(this.count);

  final int count;

  // ✗ remainder keeps the sign of the dividend: 0 → -1, photos[-1] throws RangeError.
  int previousWrong(int index) => (index - 1).remainder(count);

  int previous(int index) => (index - 1) % count; // 0 → count - 1

  int next(int index) => (index + 1) % count;
}
```
**Tuzak:** ilk fotoğrafta "geri" `-1` verir, `photos[-1]` `RangeError` atar ve galeri açılmaz (test: "remainder keeps the sign...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde sayfa, sekme ya da gün indeksini remainder ile veya if (i < 0) i = len - 1 gibi elle saran yerleri bul. % ile düzelt, index 0 için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün galerisi için ileri/geri gezinen bir sınıf yaz: ilk fotoğraftan geri son fotoğrafa, sondan ileri ilk fotoğrafa dönsün."
**Kabul:** `previous(0)` → `count - 1`; elle `if (i < 0)` sarma kalmaz; `dart analyze` temiz.

## 3. Geri sayım: `~/` ve `%`
**Ne:** `/` her zaman `double` verir; `~/` tam bölümü, `%` kalanı `int` olarak verir. **Ne zaman:** dakika:saniye, saat:dakika, sayfa sayısı, ızgara satırı. **Gerekmez:** ondalıklı sonuç isteniyorsa `/`.
<!-- snippet: 01_builtin_types/resend_countdown -->
```dart
// Düzelt: /dartadvance Projemde süreyi dakika:saniye ya da saat:dakika yazan yerleri bul. / ile
//    bölüp round/toInt yapanları ve padLeft'siz % kullananları ~/, % ve padLeft(2, '0') ile
//    düzelt, 125 sn girdisiyle test yaz.
// Üret: /dartadvance Bana doğrulama kodu ekranı için "Kodu tekrar gönder (m:ss)" metnini üreten
//    bir geri sayım sınıfı yaz.

/// OTP screen: remaining time on the "resend code" button.
final class ResendCountdown {
  // ✗ `/` is a double and round lifts 2.5 minutes to 3; seconds are not padded.
  String labelWrong(int seconds) => '${(seconds / 60).round()}:${seconds % 60}'; // 150: 3:30

  String label(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'; // 150: 2:30, 125: 2:05
}
```
**Tuzak:** `(150 / 60).round()` 3 olur, buton `3:30` yazar; padLeft'siz `125 % 60` `2:5` yazar (test: "/ with round shows 3:30 and 2:5").
**Düzelt (mevcut proje):** > "/dartadvance Projemde süreyi dakika:saniye ya da saat:dakika yazan yerleri bul. / ile bölüp round/toInt yapanları ve padLeft'siz % kullananları ~/, % ve padLeft(2, '0') ile düzelt, 125 sn girdisiyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana doğrulama kodu ekranı için \"Kodu tekrar gönder (m:ss)\" metnini üreten bir geri sayım sınıfı yaz."
**Kabul:** `/` + `round`/`toInt` kalmaz; 150 → `2:30`, 125 → `2:05`, 59 → `0:59`; `dart analyze` temiz.

## 4. `num`: JSON tam sayıyı `int` verir
**Ne:** `int` ve `double` ikisi de `num`'un alt tipidir; `int`, `double`'ın alt tipi değildir. `jsonDecode` `41`'i `int`, `29.0`'ı `double` çözer. **Ne zaman:** JSON'dan okunan her ondalıklı alan (konum, fiyat, puan, oran). **Gerekmez:** API'nin yalnız tam sayı döndürdüğü alan (`as int`).
<!-- snippet: 01_builtin_types/store_location -->
```dart
// Düzelt: /dartadvance Projemde JSON'dan okunan sayıları as double ile cast eden yerleri bul
//    (konum, fiyat, puan, oran). (x as num).toDouble() ile düzelt, tam sayı gelen JSON ile
//    test yaz.
// Üret: /dartadvance Bana API'den gelen mağaza listesini (ad, enlem, boylam, puan) okuyan bir
//    fromJson yaz; sayılar int de gelebilir.

/// Store map pin read from the API.
final class StoreLocation {
  const StoreLocation(this.latitude, this.longitude);

  // ✗ jsonDecode gives 41 as int; `41 as double` throws TypeError at runtime.
  factory StoreLocation.fromJsonWrong(Map<String, Object?> json) =>
      StoreLocation(json['latitude'] as double, json['longitude'] as double);

  /// int and double are both num.
  factory StoreLocation.fromJson(Map<String, Object?> json) => StoreLocation(
    (json['latitude'] as num).toDouble(), // 41: 41.0
    (json['longitude'] as num).toDouble(),
  );

  final double latitude;
  final double longitude;
}
```
**Tuzak:** `json['latitude'] as double` derlenir, `41` gelince `type 'int' is not a subtype of type 'double'` ile çalışma anında patlar (test: "as double throws when JSON sends a whole number").
**Düzelt (mevcut proje):** > "/dartadvance Projemde JSON'dan okunan sayıları as double ile cast eden yerleri bul (konum, fiyat, puan, oran). (x as num).toDouble() ile düzelt, tam sayı gelen JSON ile test yaz."
**Üret (yeni kod):** > "/dartadvance Bana API'den gelen mağaza listesini (ad, enlem, boylam, puan) okuyan bir fromJson yaz; sayılar int de gelebilir."
**Kabul:** JSON alanında `as double` kalmaz; tam sayı içeren JSON ile test geçer; `dart analyze` temiz.

## 5. Sayı okuma: `parse` değil `tryParse`
**Ne:** `int.parse`/`double.parse` geçersiz metinde `FormatException` fırlatır; `tryParse` `null` döner. `double.parse` yalnız noktayı tanır. **Ne zaman:** kullanıcı girdisi, sunucudan gelen metin sayı, query parametresi. **Gerekmez:** kendi ürettiğin ve biçimi kesin metin (o zaman `parse` hatası bir bug'dır).
<!-- snippet: 01_builtin_types/dimension_field -->
```dart
// Düzelt: /dartadvance Projemde kullanıcı girdisini ya da sunucudan gelen metni int.parse /
//    double.parse ile okuyan yerleri bul. tryParse ile düzelt, virgüllü ve hatalı girdide alan
//    hatası göster, test yaz.
// Üret: /dartadvance Bana ürün ölçüsü formu yaz: genişlik ve yükseklik cm, Türkçe klavyede
//    virgülle girilebilsin, hatalı girdide alanın altında hata yazsın.

/// Product size form (cm); a Turkish keyboard types the decimal comma.
final class DimensionField {
  // ✗ '12,5' and '12a' throw FormatException; Save crashes.
  double parseWrong(String text) => double.parse(text);

  double? parse(String text) => double.tryParse(text.trim().replaceAll(',', '.')); // '12,5': 12.5

  String? errorText(String text) => parse(text) == null ? 'Geçerli bir ölçü girin' : null;
}
```
**Tuzak:** Türkçe klavye `12,5` yazar; `double.parse` fırlatır ve Kaydet çöker (test: "double.parse throws on a decimal comma...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde kullanıcı girdisini ya da sunucudan gelen metni int.parse / double.parse ile okuyan yerleri bul. tryParse ile düzelt, virgüllü ve hatalı girdide alan hatası göster, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün ölçüsü formu yaz: genişlik ve yükseklik cm, Türkçe klavyede virgülle girilebilsin, hatalı girdide alanın altında hata yazsın."
**Kabul:** girdi okuyan yerde `parse` kalmaz; `'12,5'` → 12.5, `'12a'` → alan hatası; `dart analyze` temiz.

## 6. Metni kesmek: `substring` değil `characters` (`package:characters`)
**Ne:** `String` UTF-16 birimi dizisidir; 👨‍👩‍👧 ekranda tek karakter, bellekte 8 birim. `substring`, `length`, `[i]` birimle çalışır; `characters` kullanıcının gördüğü karakterle (grapheme). **Ne zaman:** önizleme, kısaltma, karakter sayacı, baş harf avatarı; kullanıcıya görünen her metin. **Gerekmez:** yalnız ASCII olduğu kesin kimlik ve kodlar.
<!-- snippet: 01_builtin_types/chat_preview -->
```dart
// Düzelt: /dartadvance Projemde kullanıcıya görünen metni length, substring ya da [0] ile sayan,
//    kesen veya baş harfini alan yerleri bul (önizleme, sayaç, avatar). characters ile düzelt,
//    emojili girdiyle test yaz.
// Üret: /dartadvance Bana sohbet listesi için son mesaj önizlemesi yaz: 22 karakterde kessin,
//    emojiyi bölmesin.
import 'package:characters/characters.dart';

/// Chat list: one-line preview of the last message.
final class ChatPreview {
  static const maxLength = 22;

  // ✗ substring cuts UTF-16 units: the family emoji 👨‍👩‍👧 is split into 👨‍👩.
  String textWrong(String message) =>
      message.length <= maxLength ? message : '${message.substring(0, maxLength)}…';

  String text(String message) {
    final characters = message.characters;
    return characters.length <= maxLength
        ? message
        : '${characters.take(maxLength)}…'; // emoji stays whole
  }
}
```
**Tuzak:** sohbet önizlemesinde aile emojisi 👨‍👩'ye bölünür; yarım surrogate'ta Flutter'ın `Text`'i `string is not well-formed UTF-16` hatası fırlatır (test: "substring splits the family emoji").
**Düzelt (mevcut proje):** > "/dartadvance Projemde kullanıcıya görünen metni length, substring ya da [0] ile sayan, kesen veya baş harfini alan yerleri bul (önizleme, sayaç, avatar). characters ile düzelt, emojili girdiyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sohbet listesi için son mesaj önizlemesi yaz: 22 karakterde kessin, emojiyi bölmesin."
**Kabul:** görünen metinde `length`/`substring`/`[i]` kalmaz; kesilen metin emojiyi bütün tutar; `dart analyze` temiz.

## 7. Türkçe harf: silme, çevir (raw `RegExp`)
**Ne:** `[^a-z0-9]` ve `\w` yalnız İngilizce harfleri tanır; Türkçe harfler "özel karakter" sayılıp silinir. Önce Latin karşılığına çevrilir (`replaceAllMapped`), sonra temizlenir. Desen raw string (`r'...'`) ile yazılır: normal string'de `\d` kaçış değil `d` harfidir. Büyük/küçük harfte de aynı: `toUpperCase` i → I yapar, önce i → İ çevrilir. **Ne zaman:** slug, paylaşım linki, dosya adı, analytics olay adı, snake_case anahtar; Türkçe arama ve büyük harf. **Gerekmez:** metin yalnız sistem tarafından üretiliyor ve ASCII ise.
<!-- snippet: 01_builtin_types/category_slug -->
```dart
// Düzelt: /dartadvance Projemde slug, dosya adı, analytics olay adı ya da snake_case anahtar
//    üreten ve [^a-z0-9], [^\w] gibi desenle özel karakter silen yerleri bul. Türkçe harfleri
//    önce Latin karşılığına çevir, 'Öne Çıkan Ürünler' girdisiyle test yaz.
// Üret: /dartadvance Bana kategori başlığından paylaşım linki parçası üreten bir sınıf yaz:
//    Türkçe harfleri çevirsin, boşluk ve özel karakterleri tire yapsın.

/// Share link of a category: 'Öne Çıkan Ürünler' → 'one-cikan-urunler'.
final class CategorySlug {
  static const _latin = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
  };

  // ✗ [^a-z0-9] treats Turkish letters as special characters: 'ne-kan-r-nler'.
  String slugWrong(String title) => _clean(title.toLowerCase());

  String slug(String title) => _clean(
    _lower(title).replaceAllMapped(
      RegExp('[çğıöşü]'),
      (match) => _latin[match[0]]!,
    ),
  ); // 'one-cikan-urunler'

  String _clean(String text) =>
      text.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  String _lower(String text) => text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
}
```
**Tuzak:** `'Öne Çıkan Ürünler'` → `'ne-kan-r-nler'` (test: "[^a-z0-9] removes Turkish letters").
**Düzelt (mevcut proje):** > "/dartadvance Projemde slug, dosya adı, analytics olay adı ya da snake_case anahtar üreten ve [^a-z0-9], [^\w] gibi desenle özel karakter silen yerleri bul. Türkçe harfleri önce Latin karşılığına çevir, 'Öne Çıkan Ürünler' girdisiyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana kategori başlığından paylaşım linki parçası üreten bir sınıf yaz: Türkçe harfleri çevirsin, boşluk ve özel karakterleri tire yapsın."
**Kabul:** `'Öne Çıkan Ürünler'` → `'one-cikan-urunler'`; her `RegExp` deseni `r'...'`; `dart analyze` temiz.

## 8. Önbellek anahtarı: `List` değil record (3.0)
**Ne:** `List`, `Set`, `Map` eşitliği referansa bakar: `[1, 2] == [1, 2]` false. Record içerik eşitliği ve `hashCode` ile gelir; `(lat, lng)` doğrudan Map anahtarı, Set elemanı olur. **Ne zaman:** birden çok değerden oluşan önbellek anahtarı, Set'te tekilleştirme, iki değer döndüren fonksiyon. **Gerekmez:** tek değerli anahtar; alanları ve davranışı olan veri (sınıf).
<!-- snippet: 01_builtin_types/pin_address_cache -->
```dart
// Düzelt: /dartadvance Projemde Map anahtarı ya da Set elemanı olarak List, ya da '$a-$b' gibi
//    birleştirilmiş String kullanan yerleri bul. Record ile düzelt, aynı anahtarla iki çağrıda
//    tek istek gittiğini test et.
// Üret: /dartadvance Bana haritada pin adresini (lat, lng) anahtarlı önbellekte tutan bir sınıf
//    yaz; aynı pine ikinci dokunuşta sunucuya gitmesin.

/// Map pin: the address is fetched once, then served from the cache.
final class PinAddressCache {
  int requestsWrong = 0;
  int requests = 0;

  final _byList = <List<double>, String>{};
  final _byRecord = <(double, double), String>{};

  // ✗ List equality is identity: every tap builds a new [lat, lng], the cache never hits.
  String addressWrong(double lat, double lng) =>
      _byList.putIfAbsent([lat, lng], () => _fetch(() => requestsWrong++));

  String address(double lat, double lng) =>
      _byRecord.putIfAbsent((lat, lng), () => _fetch(() => requests++));

  String _fetch(void Function() count) {
    count();
    return 'Caferağa Mah., Kadıköy';
  }
}
```
**Tuzak:** aynı pine 3 dokunuş 3 sunucu isteği yapar, önbellek hiç tutmaz (test: "a List key never hits...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde Map anahtarı ya da Set elemanı olarak List, ya da '$a-$b' gibi birleştirilmiş String kullanan yerleri bul. Record ile düzelt, aynı anahtarla iki çağrıda tek istek gittiğini test et."
**Üret (yeni kod):** > "/dartadvance Bana haritada pin adresini (lat, lng) anahtarlı önbellekte tutan bir sınıf yaz; aynı pine ikinci dokunuşta sunucuya gitmesin."
**Kabul:** Map/Set anahtarında `List` ya da birleştirilmiş String kalmaz; aynı `(lat, lng)` ile 3 çağrıda 1 istek; `dart analyze` temiz.

## 9. API saati UTC: `toLocal`
**Ne:** `Z` ile biten ISO metnini `DateTime.parse` UTC olarak tutar (`isUtc` true); `hour` UTC saatidir. Ekrana yazmadan önce `toLocal()`, sunucuya gönderirken `toUtc().toIso8601String()`. **Ne zaman:** API'den gelen her tarih/saat; etkinlik, sipariş, mesaj zamanı. **Gerekmez:** sunucu zaten yerel saat ve bölge bilgisiyle gönderiyorsa; yalnız tarih (saat yok).
<!-- snippet: 01_builtin_types/event_time -->
```dart
// Düzelt: /dartadvance Projemde API'den gelen tarihi DateTime.parse ile okuyup toLocal olmadan
//    ekrana yazan yerleri bul. toLocal ekle, Z'li girdiyle isUtc kontrolü yapan test yaz.
// Üret: /dartadvance Bana etkinlik başlangıcını API'nin UTC metninden okuyup cihaz saatinde
//    HH:mm yazan bir sınıf yaz.

/// Event detail: start time; the API sends UTC ('...Z').
final class EventTime {
  // ✗ A 'Z' time stays UTC; hour is the UTC hour, 3 hours early in Türkiye.
  DateTime startWrong(String iso) => DateTime.parse(iso);

  DateTime start(String iso) => DateTime.parse(iso).toLocal();

  String label(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
```
**Tuzak:** `'2026-11-02T17:30:00Z'` Türkiye'de `17:30` görünür, kullanıcı etkinliği 3 saat erken sanır (test: "parse keeps a Z time in UTC").
**Düzelt (mevcut proje):** > "/dartadvance Projemde API'den gelen tarihi DateTime.parse ile okuyup toLocal olmadan ekrana yazan yerleri bul. toLocal ekle, Z'li girdiyle isUtc kontrolü yapan test yaz."
**Üret (yeni kod):** > "/dartadvance Bana etkinlik başlangıcını API'nin UTC metninden okuyup cihaz saatinde HH:mm yazan bir sınıf yaz."
**Kabul:** ekrana giden `DateTime` `isUtc == false`; `dart analyze` temiz.

## 10. `late final` mı getter mı
**Ne:** `late final` ilk okumada bir kez hesaplanır ve kaynağa bir daha bakmaz; getter her okumada gövdesini çalıştırır. Seçim kaynağın değişip değişmediğine bağlıdır. **Ne zaman:** kaynak sabitse ve hesap pahalıysa `late final`; kaynak değişebiliyorsa getter ya da değiştiği yerde yeniden kurma. **Gerekmez:** ucuz ve tek okunan değer; düz alan yeter.
<!-- snippet: 01_builtin_types/event_filter_sheet -->
```dart
// Düzelt: /dartadvance Projemde late final alanları bul. Kaynağı sonradan değişebilenleri (dil,
//    tema, kullanıcı, filtre) getter'a ya da değiştiği yerde yeniden kurmaya çevir, kaynağı
//    değiştiren bir testle kanıtla.
// Üret: /dartadvance Bana uygulama dili değişince seçenek başlıkları da değişen bir filtre
//    sheet'i state'i yaz.

/// Event filter sheet; chip titles follow the app language.
final class EventFilterSheet {
  EventFilterSheet(this.language);

  static const _titles = {
    'tr': ['Bekleyen', 'Onaylanan', 'Reddedilen'],
    'en': ['Pending', 'Approved', 'Declined'],
  };

  String language;

  // ✗ Built on first read and never again: after 'tr' → 'en' the chips stay Turkish.
  late final List<String> titlesWrong = _titles[language]!;

  List<String> get titles => _titles[language]!; // follows language
}
```
<!-- snippet: 01_builtin_types/brand_page -->
```dart
// Düzelt: /dartadvance Projemde where, sort, map, fold gibi iş yapan getter'ları bul. build veya
//    itemBuilder içinde tekrar tekrar okunanları, kaynak değişmiyorsa late final'a ya da kaynak
//    değiştiğinde yenilenen bir alana çevir; çağrı sayısını testle ölç.
// Üret: /dartadvance Bana görünür markaları sıraya göre listeleyen bir sayfa state'i yaz; liste
//    build başına bir kez hesaplansın.

final class Brand {
  const Brand(this.name, this.order, {this.visible = true});

  final String name;
  final int order;
  final bool visible;
}

/// Brands grid: itemCount and itemBuilder read the list for every cell.
final class BrandPage {
  BrandPage(this.brands);

  final List<Brand> brands;
  int sorts = 0;

  // ✗ Looks like a field, runs where + sort on every read: 3 cells, 7 sorts.
  List<Brand> get visibleWrong => _sortVisible();

  late final List<Brand> visible = _sortVisible(); // 1 sort

  List<Brand> _sortVisible() {
    sorts++;
    return brands.where((b) => b.visible).toList()..sort((a, b) => a.order.compareTo(b.order));
  }
}
```
**Tuzak:** Dil `tr` → `en` olunca `late final` başlıklar Türkçe kalır (test: "late final keeps the first language..."). Getter'daki `where` + `sort`, grid her hücrede okuduğu için 3 hücrede 7 kez çalışır (test: "the getter sorts on every read").
**Düzelt (mevcut proje):** > "/dartadvance Projemde late final alanları bul. Kaynağı sonradan değişebilenleri (dil, tema, kullanıcı, filtre) getter'a ya da değiştiği yerde yeniden kurmaya çevir, kaynağı değiştiren bir testle kanıtla. Ayrıca where, sort, map, fold gibi iş yapan getter'ları bul; build veya itemBuilder içinde tekrar okunanları, kaynak değişmiyorsa late final'a çevir ve çağrı sayısını testle ölç."
**Üret (yeni kod):** > "/dartadvance Bana uygulama dili değişince seçenek başlıkları da değişen bir filtre sheet'i state'i ve görünür markaları build başına bir kez sıralayan bir sayfa state'i yaz."
**Kabul:** kaynağı değiştiren test yeni değeri görür; iş yapan getter'ın çağrı sayacı tek build'de 1; `dart analyze` temiz.

## 11. Cascade: `..sort` aynı listeyi sıralar
**Ne:** Cascade (`..`) metodun sonucunu değil alıcının kendisini döndürür. `products..sort()` yeni liste gibi görünür ama listeyi yerinde sıralar; aynı listeyi kullanan her yer değişir. Önce kopya, sonra cascade: `[...products]..sort()` (ya da `package:collection` `sorted`). **Ne zaman:** sıralı/filtreli görünüm aynı kaynaktan türüyorsa; state'teki listeler. **Gerekmez:** liste yalnız o fonksiyonun içinde yaşıyorsa.
<!-- snippet: 01_builtin_types/product_sort -->
```dart
// Düzelt: /dartadvance Projemde ..sort, ..shuffle, ..removeWhere, ..add gibi listeyi yerinde
//    değiştiren cascade'leri ve sonucunu yeni bir değişkene atayan yerleri bul. Kaynak başka yerde
//    de kullanılıyorsa kopya üzerinde çalıştır, kaynağın değişmediğini test et.
// Üret: /dartadvance Bana ürünler ekranı için sunucu sırasını bozmadan A–Z, fiyata göre artan ve
//    azalan sıralı listeler üreten bir sınıf yaz.

/// Products screen: "Önerilen" in server order, an "A–Z" tab from the same list.
final class ProductSort {
  // ✗ `..sort` sorts in place and returns the same list: "Önerilen" becomes A–Z too.
  List<String> alphabeticalWrong(List<String> products) => products..sort();

  List<String> alphabetical(List<String> products) => [...products]..sort();
}
```
**Tuzak:** "A–Z" sekmesi "Önerilen" bölümünü de alfabetik yapar, sunucu sırası kaybolur (test: "..sort reorders the source list too").
**Düzelt (mevcut proje):** > "/dartadvance Projemde ..sort, ..shuffle, ..removeWhere, ..add gibi listeyi yerinde değiştiren cascade'leri ve sonucunu yeni bir değişkene atayan yerleri bul. Kaynak başka yerde de kullanılıyorsa kopya üzerinde çalıştır, kaynağın değişmediğini test et."
**Üret (yeni kod):** > "/dartadvance Bana ürünler ekranı için sunucu sırasını bozmadan A–Z, fiyata göre artan ve azalan sıralı listeler üreten bir sınıf yaz."
**Kabul:** başka yerde kullanılan listede yerinde değiştiren cascade kalmaz; kaynağın değişmediği testle görülür; `dart analyze` temiz.

## 12. Nullable kontrolcü: `!` değil `?..`
**Ne:** `?..` (null-aware cascade) alıcı null ise zincirin tamamını atlar; ilk adımda bir kez yazılır, sonraki `..` adımları da korunur. `!` "burada null olamaz" sözüdür; geç gelen kontrolcülerde bu söz tutmaz. **Ne zaman:** `onMapCreated`, kamera, video, WebView gibi sonradan gelen kontrolcüler; nullable alıcıya art arda çağrı. **Gerekmez:** alıcı null olamıyorsa (non-nullable alan).
<!-- snippet: 01_builtin_types/locate_button -->
```dart
// Düzelt: /dartadvance Projemde geç gelen nullable kontrolcüleri (harita, kamera, video,
//    animasyon) ! ile ya da if (x != null) { x.a(); x.b(); } bloklarıyla kullanan yerleri bul.
//    ?.. cascade ile düzelt, null durumda çağrının çökmediğini test et.
// Üret: /dartadvance Bana harita ekranı için "Konumum" butonu yaz: kontrolcü onMapCreated ile
//    gelsin, hazır değilken dokunuş çökmesin, hazır olunca kamerayı taşıyıp pin koysun.

/// Map controller; it arrives with onMapCreated, null until the map is drawn.
final class MapCamera {
  String? target;
  String? pin;

  void moveTo(String place) => target = place;

  void showPin(String place) => pin = place;
}

/// The "my location" button on the map.
final class LocateButton {
  LocateButton([this.camera]);

  MapCamera? camera;

  // ✗ `!` throws TypeError when the map is not ready: an early tap crashes the screen.
  void onTapWrong(String place) => camera!
    ..moveTo(place)
    ..showPin(place);

  void onTap(String place) => camera
    ?..moveTo(place)
    ..showPin(place); // skipped while camera is null
}
```
**Tuzak:** harita yüklenmeden "Konumum"a basmak `Null check operator used on a null value` ile ekranı çökertir (test: "! throws when the map is not ready").
**Düzelt (mevcut proje):** > "/dartadvance Projemde geç gelen nullable kontrolcüleri (harita, kamera, video, animasyon) ! ile ya da if (x != null) { x.a(); x.b(); } bloklarıyla kullanan yerleri bul. ?.. cascade ile düzelt, null durumda çağrının çökmediğini test et."
**Üret (yeni kod):** > "/dartadvance Bana harita ekranı için "Konumum" butonu yaz: kontrolcü onMapCreated ile gelsin, hazır değilken dokunuş çökmesin, hazır olunca kamerayı taşıyıp pin koysun."
**Kabul:** nullable kontrolcüde `!..` ve `if (x != null) { x.a(); x.b(); }` kalmaz; null durumda çağrı çökmez; `dart analyze` temiz.

## Flutter'da kanıt
- `TextField` uzunluğu `text.characters.length` ile sayar: [material/text_field.dart#L1185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/text_field.dart#L1185)
- `EditableText.onChanged` doc'u `string.length` kullanma der (👨‍👩‍👦: 8 / 5 / 1): [widgets/editable_text.dart#L1440](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/editable_text.dart#L1440)
- `LengthLimitingTextInputFormatter.truncate` grapheme sınırında keser: [services/text_formatter.dart#L543](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/text_formatter.dart#L543)
- `late final` controller, kaynağı (`this`) değişmeyen değer: [cupertino/sliding_segmented_control.dart#L594](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/cupertino/sliding_segmented_control.dart#L594)

## Kontrol listesi
- [ ] Fiyat kuruş `int`; ekrana `~/ 100`, `% 100` ve binlik nokta ile yazılıyor.
- [ ] Döngüsel indeks `%` ile; `remainder` ya da elle `if (i < 0)` yok.
- [ ] Süre `~/ 60`, `% 60` ve `padLeft(2, '0')` ile yazılıyor.
- [ ] JSON'daki ondalıklı sayı `(x as num).toDouble()` ile okunuyor.
- [ ] Kullanıcı ya da sunucu metni `tryParse` ile okunuyor.
- [ ] Görünen metin `characters` ile sayılıyor ve kesiliyor.
- [ ] Slug/anahtar üretirken Türkçe harf önce çevriliyor; her `RegExp` deseni `r'...'`.
- [ ] Çok değerli Map/Set anahtarı record.
- [ ] API'den gelen saat ekrana `toLocal()` ile yazılıyor.
- [ ] `late final` yalnız kaynağı değişmeyen değerde; iş yapan getter build'de tekrar okunmuyor.
- [ ] Başka yerde kullanılan liste yerinde değiştiren cascade ile değiştirilmiyor.
- [ ] Nullable kontrolcüde `!` yerine `?..`.

## Pekiştirme
- **Kolay:** `formatDuration(int seconds)` yaz: 3725 sn → `1:02:05`, 59 sn → `0:59`. `/` kullanmadan; üç sınır değeri için test.
- **Zor:** Bir ürün JSON'unu (`price` int ya da double, `createdAt` UTC) okuyan, fiyatı kuruş `int` tutup `1.299,90 ₺` yazan, tarihi yerel saatte gösteren ve başlıktan Türkçe harfli slug üreten bir sınıf yaz; `{"price": 100}` ve `{"price": 99.9}` girdileri için test.

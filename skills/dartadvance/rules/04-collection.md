# 04 · Collection
> Kaynak: https://pub.dev/packages/collection · https://pub.dev/packages/fast_immutable_collections · https://dart.dev/libraries/dart-core#collections · https://dart.dev/language/collections#null-aware-element · Min. sürüm: Dart 3.0 (`firstOrNull`), 3.8 (null-aware element), `package:collection` 1.19
Neden bu konu: boş listede çöken ekranlar, sırasız gelen veride bozulan başlıklar, identity `==` yüzünden yanlış açık kalan butonlar ve yerinde değişen state en sık koleksiyon hatalarıdır. `package:collection` bunların çoğunu tek çağrıyla çözer.

## 1. Belki yok: `firstWhereOrNull` (package:collection)
**Ne:** `firstWhere` eşleşme yoksa `StateError` atar; `orElse` nullable olmayan tip ister. `firstWhereOrNull` null döner. Koşulsuz olanlar (`firstOrNull`, `lastOrNull`, `singleOrNull`, `elementAtOrNull`) 3.0'dan beri `dart:core`'da. **Ne zaman:** varsayılan adres, seçili kart, aktif kampanya; bulunamayabilecek her arama. **Gerekmez:** eleman kesin varsa (az önce eklendi) ve yokluğu programcı hatasıysa.
<!-- snippet: 04_collection/address_book -->
```dart
// Düzelt: /dartadvance Projemde firstWhere, singleWhere, lastWhere ve boş olabilecek listede
//    first/last kullanan yerleri bul. firstWhereOrNull (koşulsuzsa dart:core firstOrNull) ile
//    düzelt, boş durum için test yaz.
// Üret: /dartadvance Bana ödeme ekranı için varsayılan teslimat adresini seçen bir sınıf yaz;
//    adres yoksa null dönsün, ekran "Adres ekle" göstersin.
import 'package:collection/collection.dart';

/// A delivery address on the checkout screen.
final class Address {
  const Address(this.title, {this.isDefault = false});

  final String title;
  final bool isDefault;
}

/// Checkout: the user's default delivery address.
final class AddressBook {
  // ✗ firstWhere throws StateError with no match: a new user cannot open checkout.
  Address defaultAddressWrong(List<Address> addresses) =>
      addresses.firstWhere((address) => address.isDefault);

  Address? defaultAddress(List<Address> addresses) =>
      addresses.firstWhereOrNull((address) => address.isDefault); // null → "Adres ekle"
}
```
**Tuzak:** varsayılan adresi olmayan yeni kullanıcıda ödeme ekranı `StateError: No element` ile açılmaz (test: "firstWhere throws when there is no default").
**Düzelt (mevcut proje):** > "/dartadvance Projemde firstWhere, singleWhere, lastWhere ve boş olabilecek listede first/last kullanan yerleri bul. firstWhereOrNull (koşulsuzsa dart:core firstOrNull) ile düzelt, boş durum için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ödeme ekranı için varsayılan teslimat adresini seçen bir sınıf yaz; adres yoksa null dönsün, ekran "Adres ekle" göstersin."
**Kabul:** belki-yok aramalarında `firstWhere`/`first` kalmaz; boş durum test edilir; `dart analyze` temiz.

## 2. Başlık altında liste: `groupBy`
**Ne:** `groupBy(items, key)` `Map<K, List<V>>` kurar; ilk görülen anahtarın sırası korunur. Elle gruplama listenin sıralı geldiğini varsayar. **Ne zaman:** tarih, kategori, durum başlıklı listeler; özet sayıları. **Gerekmez:** liste zaten anahtara göre sıralı geliyorsa ve öyle kalacağı sözleşmeyle garantiliyse.
<!-- snippet: 04_collection/order_history -->
```dart
// Düzelt: /dartadvance Projemde listeyi tarih, kategori ya da durum başlıkları altında gösteren
//    ve gruplamayı elle (önceki elemanla karşılaştırarak ya da Map kurarak) yapan yerleri bul.
//    groupBy ile düzelt, sırasız girdiyle test yaz.
// Üret: /dartadvance Bana sipariş geçmişini ay başlıkları altında gösteren bir bölüm listesi
//    kuran sınıf yaz.
import 'package:collection/collection.dart';

/// One order in the order history.
final class Order {
  const Order(this.no, this.month);

  final String no;
  final String month;
}

/// Order history under month headers; the API sorts by status, not by date.
final class OrderHistory {
  // ✗ A new header whenever the month changes: unsorted input shows 'Ekim' twice.
  List<(String, List<Order>)> sectionsWrong(List<Order> orders) {
    final sections = <(String, List<Order>)>[];
    for (final order in orders) {
      if (sections.isEmpty || sections.last.$1 != order.month) {
        sections.add((order.month, []));
      }
      sections.last.$2.add(order);
    }
    return sections;
  }

  List<(String, List<Order>)> sections(List<Order> orders) => [
    for (final MapEntry(:key, :value) in groupBy(orders, (o) => o.month).entries) (key, value),
  ]; // each month once
}
```
**Tuzak:** API listeyi duruma göre sıralı gönderince "Ekim" başlığı iki kez çıkar (test: "consecutive headers repeat a month").
**Düzelt (mevcut proje):** > "/dartadvance Projemde listeyi tarih, kategori ya da durum başlıkları altında gösteren ve gruplamayı elle (önceki elemanla karşılaştırarak ya da Map kurarak) yapan yerleri bul. groupBy ile düzelt, sırasız girdiyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana sipariş geçmişini ay başlıkları altında gösteren bir bölüm listesi kuran sınıf yaz."
**Kabul:** her başlık bir kez; sırasız girdiyle test; `dart analyze` temiz.

## 3. İçerik eşitliği: `ListEquality` / `SetEquality` / `DeepCollectionEquality`
**Ne:** `List`, `Set`, `Map` için `==` nesneye bakar: `{'a'} == {'a'}` false. Equality sınıfları içeriği karşılaştırır; koleksiyon alanlı sınıfın `==` ve `hashCode`'u aynı Equality ile yazılır. **Ne zaman:** "değişti mi" kontrolü, state `==`'i, önbellek anahtarı. **Gerekmez:** aynı nesne mi sorusu (identity) gerçekten isteniyorsa.
<!-- snippet: 04_collection/filter_draft -->
```dart
// Düzelt: /dartadvance Projemde iki List, Set ya da Map'i == veya != ile karşılaştıran yerleri ve
//    koleksiyon alanı olan sınıfların == metotlarını bul. ListEquality, SetEquality ya da
//    DeepCollectionEquality ile düzelt, aynı içerikli iki ayrı nesneyle test yaz.
// Üret: /dartadvance Bana filtre sheet'i için uygulanan ve taslak seçimi karşılaştıran,
//    değişiklik yoksa "Uygula"yı kapatan bir sınıf yaz.
import 'package:collection/collection.dart';

/// Filter sheet: "Uygula" is enabled only when the draft differs from the applied filter.
final class FilterDraft {
  // ✗ Set == compares identity: nothing changed, yet "Uygula" is enabled.
  bool canApplyWrong(Set<String> applied, Set<String> draft) => applied != draft;

  bool canApply(Set<String> applied, Set<String> draft) =>
      !const SetEquality<String>().equals(applied, draft); // order does not matter
}
```
**Tuzak:** filtre sheet'inde hiçbir şey değişmeden "Uygula" açık kalır (test: "!= on sets compares identity").
**Düzelt (mevcut proje):** > "/dartadvance Projemde iki List, Set ya da Map'i == veya != ile karşılaştıran yerleri ve koleksiyon alanı olan sınıfların == metotlarını bul. ListEquality, SetEquality ya da DeepCollectionEquality ile düzelt, aynı içerikli iki ayrı nesneyle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana filtre sheet'i için uygulanan ve taslak seçimi karşılaştıran, değişiklik yoksa "Uygula"yı kapatan bir sınıf yaz."
**Kabul:** koleksiyonlar `==`/`!=` ile karşılaştırılmaz; aynı içerikli iki ayrı nesneyle test; `dart analyze` temiz.

## 4. Parçalara bölmek: `slices`
**Ne:** `slices(n)` listeyi n'lik parçalara böler, son parça kalan kadardır. Elle `sublist(i, i + n)` son parçada uzunluğu aşar. **Ne zaman:** grid satırları, sayfalama, toplu (batch) istek. **Gerekmez:** n sabit ve uzunluk her zaman n'in katıysa (yine de slices daha kısa).
<!-- snippet: 04_collection/product_grid -->
```dart
// Düzelt: /dartadvance Projemde listeyi satırlara, sayfalara ya da n'lik paketlere bölen ve
//    sublist / elle indeks hesabı kullanan yerleri bul. slices ile düzelt, n'e tam bölünmeyen
//    uzunlukla test yaz.
// Üret: /dartadvance Bana ürünleri her satırda 3 tane olacak şekilde satırlara bölen bir sınıf
//    yaz.
import 'package:collection/collection.dart';

/// Product list: three products per row.
final class ProductGrid {
  static const perRow = 3;

  // ✗ sublist(i, i + 3) runs past the end on the last row: 7 products throw RangeError.
  List<List<String>> rowsWrong(List<String> products) => [
    for (var i = 0; i < products.length; i += perRow) products.sublist(i, i + perRow),
  ];

  List<List<String>> rows(List<String> products) => products.slices(perRow).toList(); // 3, 3, 1
}
```
**Tuzak:** 7 ürün satırda 3'erli bölünürken son satırda `RangeError` atar, ürünler yüklenmez (test: "sublist overruns the last row").
**Düzelt (mevcut proje):** > "/dartadvance Projemde listeyi satırlara, sayfalara ya da n'lik paketlere bölen ve sublist / elle indeks hesabı kullanan yerleri bul. slices ile düzelt, n'e tam bölünmeyen uzunlukla test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürünleri her satırda 3 tane olacak şekilde satırlara bölen bir sınıf yaz."
**Kabul:** elle `sublist` ile bölme kalmaz; n'e tam bölünmeyen uzunlukla test; `dart analyze` temiz.

## 5. Sıralama: `sortedBy` ve doğru karşılaştırıcı
**Ne:** Karşılaştırıcı `int` döndürür; `(a - b).toInt()` küçük farkları 0 yapar. `sortedBy` anahtarı `compareTo` ile karşılaştırır ve yeni liste döndürür, kaynağa dokunmaz. **Ne zaman:** fiyat, mesafe, puan gibi double anahtarla sıralama; kaynağı korunacak listeler. **Gerekmez:** liste yalnız o fonksiyonda yaşıyorsa yerinde `sort` da olur (karşılaştırıcı yine `compareTo`).
<!-- snippet: 04_collection/price_sort -->
```dart
// Düzelt: /dartadvance Projemde sort karşılaştırıcısında çıkarma (a - b), toInt ya da round
//    kullanan yerleri ve kaynağı yerinde sıralayan sort çağrılarını bul. sortedBy / compareTo
//    ile düzelt, yakın fiyatlarla test yaz.
// Üret: /dartadvance Bana ürün listesini fiyata göre artan ve azalan sıralayan, kaynak listeyi
//    değiştirmeyen bir sınıf yaz.
import 'package:collection/collection.dart';

/// A product with its price.
final class Product {
  const Product(this.name, this.price);

  final String name;
  final double price;
}

/// "Fiyat: artan" sort on the product list.
final class PriceSort {
  // ✗ toInt turns 19.90 - 19.50 into 0: two prices count as equal, the order is wrong.
  List<Product> ascendingWrong(List<Product> products) =>
      [...products]..sort((a, b) => (a.price - b.price).toInt());

  List<Product> ascending(List<Product> products) =>
      products.sortedBy<num>((product) => product.price); // source untouched
}
```
**Tuzak:** 19,90 ₺ ile 19,50 ₺ eşit sayılır, "Fiyat: artan" 19,90'ı önce gösterir (test: "toInt comparator treats 19.9 and 19.5 as equal").
**Düzelt (mevcut proje):** > "/dartadvance Projemde sort karşılaştırıcısında çıkarma (a - b), toInt ya da round kullanan yerleri ve kaynağı yerinde sıralayan sort çağrılarını bul. sortedBy / compareTo ile düzelt, yakın fiyatlarla test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün listesini fiyata göre artan ve azalan sıralayan, kaynak listeyi değiştirmeyen bir sınıf yaz."
**Kabul:** karşılaştırıcıda çıkarma/`toInt` kalmaz; yakın fiyatlarla test; `dart analyze` temiz.

## 6. Öncelik kuyruğu: `PriorityQueue`
**Ne:** `PriorityQueue` heap'tir: ekleme ve `removeFirst` O(log n), en öncelikli eleman hep başta. Liste ya da `Queue` eklenme sırasıyla verir. Eşit öncelikte ekleniş sırası garanti değil; gerekiyorsa ikinci anahtar ekle. **Ne zaman:** yükleme, bildirim, senkronizasyon kuyrukları. **Gerekmez:** öncelik yoksa (FIFO yeter): `Queue`.
<!-- snippet: 04_collection/upload_queue -->
```dart
// Düzelt: /dartadvance Projemde öncelikli iş kuyruğu (yükleme, bildirim, senkronizasyon) tutup
//    her eklemede sort çağıran ya da öncelik yerine eklenme sırasını kullanan yerleri bul.
//    PriorityQueue ile düzelt, sona eklenen yüksek öncelikli işle test yaz.
// Üret: /dartadvance Bana belge yükleme kuyruğu yaz: kimlik gibi öncelikli belgeler, sonradan
//    eklense de önce yüklensin.
import 'package:collection/collection.dart';

/// A file waiting to be uploaded.
final class Upload {
  const Upload(this.name, {this.priority = 1});

  final String name;

  /// Lower goes first.
  final int priority;
}

/// Seller application: the ID photo must upload before the product photos.
final class UploadQueue {
  // ✗ A List keeps insertion order: the ID added last waits behind every photo.
  List<String> orderWrong(List<Upload> uploads) => [
    for (final upload in uploads) upload.name,
  ];

  List<String> order(List<Upload> uploads) {
    final queue = PriorityQueue<Upload>((a, b) => a.priority.compareTo(b.priority))
      ..addAll(uploads);
    return [for (final upload in queue.toList()) upload.name]; // ID first
  }
}
```
**Tuzak:** en son seçilen kimlik fotoğrafı 4. sırada bekler, onay gecikir (test: "a List keeps insertion order").
**Düzelt (mevcut proje):** > "/dartadvance Projemde öncelikli iş kuyruğu (yükleme, bildirim, senkronizasyon) tutup her eklemede sort çağıran ya da öncelik yerine eklenme sırasını kullanan yerleri bul. PriorityQueue ile düzelt, sona eklenen yüksek öncelikli işle test yaz."
**Üret (yeni kod):** > "/dartadvance Bana belge yükleme kuyruğu yaz: kimlik gibi öncelikli belgeler, sonradan eklense de önce yüklensin."
**Kabul:** öncelikli kuyrukta her eklemede `sort` kalmaz; sona eklenen yüksek öncelikli işle test; `dart analyze` temiz.

## 7. Değiştirilemez state: `IList` (fast_immutable_collections)
**Ne:** `List.add` yerinde değiştirir; önceki state aynı listeyi tuttuğu için o da değişir. `IList` değiştirilemez: `add` yeni liste döndürür, eşitlik içeriğe bakar, büyük listede yapısal paylaşımla hızlıdır. Yalnız dışarıya açmamak yetiyorsa `UnmodifiableListView` (`dart:collection`). **Ne zaman:** state sınıflarındaki koleksiyon alanları; geri al, geçmiş, karşılaştırma. **Gerekmez:** yerel, kısa ömürlü liste.
<!-- snippet: 04_collection/cart_history -->
```dart
// Düzelt: /dartadvance Projemde state sınıflarında List/Set/Map alanlarını yerinde değiştiren
//    (add, remove, ..add, []=) yerleri bul. IList/ISet/IMap'e geç ya da yeni koleksiyon üret;
//    önceki state'in değişmediğini test et.
// Üret: /dartadvance Bana 'Geri al' destekli sepet state'i yaz: her ekleme yeni state üretsin,
//    öncekiler değişmesin. fast_immutable_collections kullan.
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// Cart with "Geri al": every add is a new state, undo returns the previous one.
final class CartHistory {
  // ✗ add changes the same list: the previous state sees the new item, undo does nothing.
  (List<String> before, List<String> after) addWrong(List<String> items, String item) =>
      (items, items..add(item));

  (IList<String> before, IList<String> after) add(IList<String> items, String item) =>
      (items, items.add(item)); // before stays ['Kahve', 'Kupa']
}
```
**Tuzak:** sepete eklenen Termos "Geri al" sonrası da sepette kalır (test: "List.add changes the previous state too").
**Düzelt (mevcut proje):** > "/dartadvance Projemde state sınıflarında List/Set/Map alanlarını yerinde değiştiren (add, remove, ..add, []=) yerleri bul. IList/ISet/IMap'e geç ya da yeni koleksiyon üret; önceki state'in değişmediğini test et."
**Üret (yeni kod):** > "/dartadvance Bana 'Geri al' destekli sepet state'i yaz: her ekleme yeni state üretsin, öncekiler değişmesin. fast_immutable_collections kullan."
**Kabul:** state'te yerinde değiştirilen koleksiyon kalmaz; önceki state'in değişmediği testle görülür; `dart analyze` temiz.

## 8. Null-aware element `?` (3.8)
**Ne:** `{'bio': bio}` null değeri de gönderir; `'bio': ?bio` null ise anahtarı hiç eklemez. Liste ve widget listesinde de aynı: `[?subtitle]`. **Ne zaman:** PATCH gövdesi, query parametresi, opsiyonel widget. **Gerekmez:** SDK alt sınırı 3.8'in altındaysa: `if (bio != null) 'bio': bio`.
<!-- snippet: 04_collection/profile_patch -->
```dart
// Düzelt: /dartadvance Projemde istek gövdesi, query parametresi ya da widget listesi kurarken
//    null değeri gönderen veya if (x != null) yazan yerleri bul. 'key': ?value ve ?widget ile
//    düzelt, gönderilen gövdeyi testle kontrol et. SDK 3.8 altındaysa önce söyle.
// Üret: /dartadvance Bana profil düzenleme için yalnız değişen alanları gönderen bir PATCH
//    gövdesi kuran sınıf yaz.

/// Edit profile: only the changed fields go in the PATCH body.
final class ProfilePatch {
  // ✗ Sends "bio": null; the server overwrites the stored bio.
  Map<String, Object?> bodyWrong({String? name, String? bio}) => {'name': name, 'bio': bio};

  Map<String, Object> body({String? name, String? bio}) => {
    'name': ?name,
    'bio': ?bio,
  }; // (name: 'Ayşe'): {'name': 'Ayşe'}

  Map<String, Object?> apply(Map<String, Object?> stored, Map<String, Object?> body) => {
    ...stored,
    ...body,
  };
}
```
**Tuzak:** yalnız adı değişen PATCH `"bio": null` gönderir, sunucu kayıtlı bio'yu siler (test: "a null bio in the body erases the stored one").
**Düzelt (mevcut proje):** > "/dartadvance Projemde istek gövdesi, query parametresi ya da widget listesi kurarken null değeri gönderen veya if (x != null) yazan yerleri bul. 'key': ?value ve ?widget ile düzelt, gönderilen gövdeyi testle kontrol et. SDK 3.8 altındaysa önce söyle."
**Üret (yeni kod):** > "/dartadvance Bana profil düzenleme için yalnız değişen alanları gönderen bir PATCH gövdesi kuran sınıf yaz."
**Kabul:** istek gövdesinde null alan gitmez; gönderilen gövde testle kontrol edilir; `dart analyze` temiz.

## Flutter'da kanıt
- `SchedulerBinding._taskQueue = HeapPriorityQueue<_TaskEntry<dynamic>>(_taskSorter)`: [scheduler/binding.dart#L439](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L439)
- `RadioGroup`: `_radios.firstWhereOrNull(...)`: [widgets/radio_group.dart#L147](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/radio_group.dart#L147)
- `NetworkImage.==` içerik eşitliği, `hashCode` `MapEquality().hash`: [painting/_network_image_io.dart#L185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/_network_image_io.dart#L185)
- `PlatformRouteInformationProvider._equals` `DeepCollectionEquality.unordered()`: [widgets/router.dart#L1522](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/router.dart#L1522)

## Kontrol listesi
- [ ] Belki-yok aramasında `firstWhereOrNull` / `firstOrNull`.
- [ ] Başlıklı liste `groupBy` ile.
- [ ] Koleksiyonlar `==` ile değil Equality sınıflarıyla karşılaştırılıyor.
- [ ] Liste parçaları `slices` ile.
- [ ] Karşılaştırıcı `compareTo`; kaynağı korunacak listede `sortedBy`.
- [ ] Öncelikli kuyruk `PriorityQueue`.
- [ ] State koleksiyonları değiştirilemez (`IList` ya da yeni kopya).
- [ ] İstek gövdesinde null alan `?` ile dışarıda.

## Pekiştirme
- Kolay: Ürün listesinde stokta olan ilk ürünü null güvenli bulan fonksiyon yaz. Bitti: boş listede test geçiyor.
- Zor: Siparişleri şehre göre grupla, `Order` sınıfını `List` alanıyla içerik eşitliğine sahip yap. Bitti: aynı içerikli iki nesne `==` ve aynı `hashCode` veriyor.

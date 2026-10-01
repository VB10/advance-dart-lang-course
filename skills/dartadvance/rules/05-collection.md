# 05 · Koleksiyonlar
> Kaynak: https://dart.dev/libraries/dart-core#collections · https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries · https://dart.dev/libraries/dart-core#implementing-map-keys · https://dart.dev/effective-dart/design#do-override-hashcode-if-you-override · https://dart.dev/effective-dart/design#avoid-defining-custom-equality-for-mutable-classes · Min. sürüm: Dart 3.0 (`firstOrNull`), `package:collection` 1.19
Neden bu konu: Flutter'da boş listede `first` ile çöken ekranlar, yerinde `sort()` ile bozulan state ve identity `==` yüzünden gereksiz rebuild'ler en sık koleksiyon hatalarıdır.

Liste, map ve kuyruk işlerini (arama, gruplama, sıralama, eşitlik, değişmezlik) kısa ve güvenli yazmayı öğretir; Domain'de entity alanları, State'te değişmez liste, UI'da hazır gruplanmış veri olarak durur.

## 1. Core mu paket mi (3.0)
**Ne:** `firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull` core'da; predicate'li `firstWhereOrNull` hâlâ `package:collection`'da. **Ne zaman:** "belki yok" aramasında `StateError` yerine null istediğinde. **Gerekmez:** Eleman kesin varsa düz `first`.
<!-- snippet: 05_collection/first_or_null -->
```dart
// Düzelt: /dartadvance Projemde `first`/`firstWhere`/`try-catch StateError` ile arama yapan
//    yerleri bul, `firstOrNull`/`firstWhereOrNull` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana siparişlerde bir müşterinin ilk siparişini bulan, yoksa null
//    dönen bir fonksiyon yaz.
import 'package:collection/collection.dart';

typedef Product = ({String name, int stock});

Product naiveFirst(List<Product> products) => products.first; // empty: StateError

Product? cheapest(List<Product> sortedByPrice) => sortedByPrice.firstOrNull; // empty: null

Product naiveInStock(List<Product> products) => products.firstWhere((product) => product.stock > 0);

Product? firstInStock(List<Product> products) =>
    products.firstWhereOrNull((product) => product.stock > 0); // no match: null

Product? onlyProduct(List<Product> products) => products.singleOrNull;
```
**Tuzak:** `first`/`firstWhere` boşta `StateError` atar (test: "first and firstWhere throw StateError ..."); `singleOrNull` iki veya daha fazla elemanda da null döner, hata vermez (test: "singleOrNull is null for zero and for two or more elements").
**Düzelt (mevcut proje):** > "/dartadvance Projemde `first`/`firstWhere`/`try-catch StateError` ile arama yapan yerleri bul, `firstOrNull`/`firstWhereOrNull` ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana siparişlerde bir müşterinin ilk siparişini bulan, yoksa null dönen bir fonksiyon yaz."
**Kabul:** Boş listede ve eşleşme yokta exception atmıyor; `first`/`firstWhere`/`StateError` yakalama kalmadı; `firstOrNull` için paket import'u yok, predicate'li arama için var; her değişiklik için test, `dart analyze` temiz.

## 2. Gruplama ve sıralama (package:collection)
**Ne:** `groupListsBy`, `sortedBy`/`sortedByCompare`, `mapIndexed`, `compareNatural`. **Ne zaman:** Listeyi ekran için gruplarken veya yeni sıralı kopya gerektiğinde. **Gerekmez:** Yerinde sıralama yeterliyse `List.sort`.
<!-- snippet: 05_collection/group_and_sort -->
```dart
// Düzelt: /dartadvance Projemde `list.sort()` ile yerinde sıralayan veya elle gruplayan
//    yerleri bul, `sortedBy`/`groupListsBy` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana kullanıcı listesini şehre göre gruplayıp her şehirde en yeni
//    üyeyi ilk gösteren bir fonksiyon yaz.
import 'package:collection/collection.dart';

typedef Order = ({String city, String sku, int amount});

Map<String, List<Order>> ordersByCity(Iterable<Order> orders) =>
    orders.groupListsBy((order) => order.city);

List<Order> sortInPlace(List<Order> orders) =>
    orders..sort((a, b) => b.amount.compareTo(a.amount)); // mutates the input

List<Order> biggestFirst(Iterable<Order> orders) =>
    orders.sortedByCompare((order) => order.amount, (a, b) => b.compareTo(a)); // input untouched

List<String> numberedLines(List<Order> orders) =>
    orders.mapIndexed((index, order) => '${index + 1}. ${order.sku}').toList();

List<String> versionsInOrder(Iterable<String> versions) =>
    versions.sorted(compareNatural); // v2 before v10
```
**Tuzak:** `sort()` girdi listesini değiştirir (test: "sort() mutates the input ..."); `sort()` yerinde çalışır ve `void` döner; `sorted*` yeni liste verir, kaynak değişmez (test: "sorting helpers return a new list and leave the source alone").
**Düzelt (mevcut proje):** > "/dartadvance Projemde `list.sort()` ile yerinde sıralayan veya elle gruplayan yerleri bul, `sortedBy`/`groupListsBy` ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana kullanıcı listesini şehre göre gruplayıp her şehirde en yeni üyeyi ilk gösteren bir fonksiyon yaz."
**Kabul:** Gruplar ilk görülme sırasında; kaynak liste `sort()` ile değişmiyor (yerinde sıralama kalmadı); her değişen yer için test, `dart analyze` temiz.

## 3. İçerik eşitliği
**Ne:** `List`/`Map`/`Set` `==` ile identity karşılaştırır; içerik için `ListEquality`, `DeepCollectionEquality` kullanılır. **Ne zaman:** Koleksiyon alanı olan sınıfta `==`/`hashCode` yazarken. **Gerekmez:** Alanlar `String`/`int`/record ise `Object.hash` yeter.
<!-- snippet: 05_collection/content_equality -->
```dart
// Düzelt: /dartadvance Projemde `List`/`Map` alanlı sınıflarda `==`/`hashCode` yazan
//    yerleri bul, `DeepCollectionEquality` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana etiket listesi ve özellik haritası tutan, aynı içerikte eşit
//    sayılan bir `Playlist` sınıfı yaz.
import 'package:collection/collection.dart';

const _tagEquality = DeepCollectionEquality();

bool naiveSame(Map<String, List<String>> a, Map<String, List<String>> b) =>
    a == b; // same content: false

bool deepSame(Map<String, List<String>> a, Map<String, List<String>> b) =>
    _tagEquality.equals(a, b); // same content: true

final class Profile {
  Profile(this.name, this.tags);

  final String name;
  final Map<String, List<String>> tags;

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && _tagEquality.equals(other.tags, tags);

  @override
  int get hashCode => Object.hash(name, _tagEquality.hash(tags));
}

bool sameQuery(Map<String, List<String>> a, Map<String, List<String>> b) =>
    const DeepCollectionEquality.unordered().equals(a, b);
```
**Tuzak:** `Map`/`List` üzerinde `==` aynı içerikte bile false'tur (test: "== on maps is false ..."); `ListEquality<List<int>>` iç listeleri identity ile karşılaştırır; iç içe veri için `DeepCollectionEquality` gerekir (test: "ListEquality without deep support ..."). `hashCode` da aynı Equality ile üretilmeli.
**Düzelt (mevcut proje):** > "/dartadvance Projemde `List`/`Map` alanlı sınıflarda `==`/`hashCode` yazan yerleri bul, `DeepCollectionEquality` ile düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana etiket listesi ve özellik haritası tutan, aynı içerikte eşit sayılan bir `Playlist` sınıfı yaz."
**Kabul:** `==` ve `hashCode` aynı `DeepCollectionEquality` örneğini kullanıyor; aynı içerikli iki ayrı nesne için eşitlik ve hash testi geçiyor; koleksiyon alanlarında çıplak `==` kalmadı.

## 4. Değişmez state: kopya mı görünüm mü
**Ne:** `List.unmodifiable` kopya alır; `UnmodifiableListView` canlı, salt-okunur görünümdür. **Ne zaman:** State nesnesinde kopya, ViewModel'in iç listesini dışarı açarken görünüm. **Gerekmez:** Liste zaten dışarı sızmıyorsa.
<!-- snippet: 05_collection/immutable_state -->
```dart
// Düzelt: /dartadvance Projemde state/ViewModel'de `List` alanını doğrudan saklayan ya da
//    açan yerleri bul, `List.unmodifiable`/`UnmodifiableListView` ile düzelt, test yaz.
// Üret: /dartadvance Bana ürün listesi tutan bir sepet state'i ve listeyi salt-okunur açan
//    bir ViewModel yaz.
import 'dart:collection';

final class LeakyCart {
  LeakyCart(this.skus);

  final List<String> skus; // caller's later add() changes this state
}

final class CartState {
  CartState(List<String> skus) : skus = List.unmodifiable(skus);

  final List<String> skus; // a copy: nothing leaks in

  CartState add(String sku) => CartState([...skus, sku]);
}

final class CartViewModel {
  final List<String> _skus = [];

  List<String> get skus => UnmodifiableListView(_skus); // live read-only view

  void add(String sku) => _skus.add(sku);
}
```
**Tuzak:** Listeyi doğrudan saklamak çağıranın değişikliğini state'e sızdırır (test: "the leaky state follows the caller list"); `UnmodifiableListView` kopya değildir; sahibi listeyi değiştirirse görünüm de değişir (test: "the view rejects changes but follows the owner").
**Düzelt (mevcut proje):** > "/dartadvance Projemde state/ViewModel'de `List` alanını doğrudan saklayan ya da açan yerleri bul, `List.unmodifiable`/`UnmodifiableListView` ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ürün listesi tutan bir sepet state'i ve listeyi salt-okunur açan bir ViewModel yaz."
**Kabul:** State'e verilen kaynak liste sonradan değişse state değişmiyor; dışarı açılan listeye `add` `UnsupportedError` atıyor; her değişen yer için test, `dart analyze` temiz.

## 5. Öncelik kuyruğu
**Ne:** `HeapPriorityQueue` en küçük (karşılaştırıcıya göre ilk) elemanı verir. **Ne zaman:** Öncelikli iş/görev sırası. **Gerekmez:** Sıra yalnızca geliş sırasıysa `Queue`/`QueueList`.
<!-- snippet: 05_collection/task_scheduler -->
```dart
// Düzelt: /dartadvance Projemde öncelikli işi `sort()` ya da tek ölçütlü karşılaştırıcıyla
//    sıralayan yerleri bul, `HeapPriorityQueue` + sıra numarası ile düzelt, test yaz.
// Üret: /dartadvance Bana faturaları aciliyete göre işleyen, eşit aciliyette geliş sırasını
//    koruyan bir kuyruk yaz.
import 'package:collection/collection.dart';

typedef _Task = ({int priority, int sequence, String name});

int _byPriorityOnly(_Task a, _Task b) => b.priority.compareTo(a.priority);

int _highestFirstThenFifo(_Task a, _Task b) => switch (_byPriorityOnly(a, b)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class TaskScheduler {
  TaskScheduler() : _queue = HeapPriorityQueue(_highestFirstThenFifo);

  TaskScheduler.priorityOnly() : _queue = HeapPriorityQueue(_byPriorityOnly); // ties: not FIFO

  int _sequence = 0;
  final HeapPriorityQueue<_Task> _queue;

  void schedule(String name, {required int priority}) =>
      _queue.add((priority: priority, sequence: _sequence++, name: name));

  List<String> drain() {
    final names = <String>[];
    while (_queue.isNotEmpty) {
      names.add(_queue.removeFirst().name);
    }
    return names;
  }
}
```
**Tuzak:** Eşit öncelikte FIFO garanti edilmez (test: "priority-only comparator does not keep FIFO on ties"); `sequence` alanı ile karşılaştırıcıya ikinci ölçüt eklenir (test: "runs the highest priority first and FIFO within a priority").
**Düzelt (mevcut proje):** > "/dartadvance Projemde öncelikli işi `sort()` ya da tek ölçütlü karşılaştırıcıyla sıralayan yerleri bul, `HeapPriorityQueue` + sıra numarası ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana faturaları aciliyete göre işleyen, eşit aciliyette geliş sırasını koruyan bir kuyruk yaz."
**Kabul:** Karşılaştırıcı önce öncelik sonra sıra numarasına bakıyor; aynı öncelikte geliş sırası testle kanıtlı; `drain()` sonrası kuyruk boş.

## Flutter'da kanıt
- `SchedulerBinding._taskQueue = HeapPriorityQueue<_TaskEntry<dynamic>>(_taskSorter)`: [scheduler/binding.dart#L439](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L439)
- `RadioGroup`: `_radios.firstWhereOrNull(...)`: [widgets/radio_group.dart#L147](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/radio_group.dart#L147)
- `NetworkImage.==` içerik eşitliği, `hashCode` `MapEquality().hash`: [painting/_network_image_io.dart#L185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/_network_image_io.dart#L185)
- `PlatformRouteInformationProvider._equals` `DeepCollectionEquality.unordered()`: [widgets/router.dart#L1522](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/router.dart#L1522)

## Kontrol listesi
- [ ] Belki-yok aramasında `firstOrNull`/`firstWhereOrNull` kullandım, `try/catch` değil.
- [ ] `sort()` yerine, kaynağı korumam gerekince `sorted*` kullandım.
- [ ] Koleksiyon alanlı `==` ve `hashCode` aynı Equality'yi kullanıyor.
- [ ] State'e giren liste `List.unmodifiable` ile kopyalandı.
- [ ] `UnmodifiableListView`'ı kopya sanmadım.
- [ ] Eşit öncelikte sıra gerekiyorsa karşılaştırıcıya sıra numarası ekledim.

## Pekiştirme
- Kolay: Ürün listesinde stokta olan ilk ürünü null güvenli bulan fonksiyon yaz. Bitti: boş listede test geçiyor.
- Zor: Siparişleri şehre göre grupla, `Order` sınıfını `List` alanıyla içerik eşitliğine sahip yap. Bitti: aynı içerikli iki nesne `==` ve aynı `hashCode` veriyor.

# 05 · Koleksiyonlar
> Kaynak: https://dart.dev/libraries/dart-core#collections · https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries · https://dart.dev/libraries/dart-core#implementing-map-keys · https://dart.dev/effective-dart/design#do-override-hashcode-if-you-override · https://dart.dev/effective-dart/design#avoid-defining-custom-equality-for-mutable-classes · Min. sürüm: Dart 3.0 (`firstOrNull`), `package:collection` 1.19

Liste, map ve kuyruk işlerini (arama, gruplama, sıralama, eşitlik, değişmezlik) kısa ve güvenli yazmayı öğretir; Domain'de entity alanları, State'te değişmez liste, UI'da hazır gruplanmış veri olarak durur.

## 1. Core mu paket mi (3.0)
**Ne:** `firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull` core'da; predicate'li `firstWhereOrNull` hâlâ `package:collection`'da. **Ne zaman:** "belki yok" aramasında `StateError` yerine null istediğinde. **Gerekmez:** Eleman kesin varsa düz `first`.
<!-- snippet: 05_collection/first_or_null -->
```dart
import 'package:collection/collection.dart';

typedef Product = ({String name, int stock});

// Core (Dart 3.0): no import needed for the OrNull helpers.
Product? cheapest(List<Product> sortedByPrice) => sortedByPrice.firstOrNull;

// Package: the predicate version still lives in package:collection.
Product? firstInStock(List<Product> products) =>
    products.firstWhereOrNull((product) => product.stock > 0);

// Two or more elements gives null, not an error.
Product? onlyProduct(List<Product> products) => products.singleOrNull;
```
**Tuzak:** `singleOrNull` iki veya daha fazla elemanda da null döner, hata vermez (test: "singleOrNull is null for zero and for two or more elements").
**Skill'e ver:** > "Bir kullanıcının kayıtlı adresleri listesinde varsayılan adresi bulan, yoksa null dönen fonksiyon yaz; listenin ilk elemanını da yazmadan null güvenli al."
**Kabul:** Boş listede exception atmaz; `firstOrNull` için paket import'u yok, predicate'li arama için var; `dart analyze` temiz.

## 2. Gruplama ve sıralama (package:collection)
**Ne:** `groupListsBy`, `sortedBy`/`sortedByCompare`, `mapIndexed`, `compareNatural`. **Ne zaman:** Listeyi ekran için gruplarken veya yeni sıralı kopya gerektiğinde. **Gerekmez:** Yerinde sıralama yeterliyse `List.sort`.
<!-- snippet: 05_collection/group_and_sort -->
```dart
import 'package:collection/collection.dart';

typedef Order = ({String city, String sku, int amount});

Map<String, List<Order>> ordersByCity(Iterable<Order> orders) =>
    orders.groupListsBy((order) => order.city);

// Returns a new list; core List.sort sorts in place and returns void.
List<Order> biggestFirst(Iterable<Order> orders) =>
    orders.sortedByCompare((order) => order.amount, (a, b) => b.compareTo(a));

List<String> numberedLines(List<Order> orders) =>
    orders.mapIndexed((index, order) => '${index + 1}. ${order.sku}').toList();

List<String> versionsInOrder(Iterable<String> versions) => versions.sorted(compareNatural);
```
**Tuzak:** `sort()` yerinde çalışır ve `void` döner; `sorted*` yeni liste verir, kaynak değişmez (test: "sorting helpers return a new list and leave the source alone").
**Skill'e ver:** > "Bir kütüphane uygulamasında kitapları yazara göre grupla, her grubu yayın yılına göre yeniden eskiye sırala ve satırları '1. Başlık' diye numarala."
**Kabul:** Grup anahtarları ilk görülme sırasında; kaynak liste değişmemiş; numara 1'den başlıyor.

## 3. İçerik eşitliği
**Ne:** `List`/`Map`/`Set` `==` ile identity karşılaştırır; içerik için `ListEquality`, `DeepCollectionEquality` kullanılır. **Ne zaman:** Koleksiyon alanı olan sınıfta `==`/`hashCode` yazarken. **Gerekmez:** Alanlar `String`/`int`/record ise `Object.hash` yeter.
<!-- snippet: 05_collection/content_equality -->
```dart
import 'package:collection/collection.dart';

const _tagEquality = DeepCollectionEquality();

final class Profile {
  Profile(this.name, this.tags);

  final String name;
  final Map<String, List<String>> tags;

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && _tagEquality.equals(other.tags, tags);

  // hashCode must match ==, so it uses the same Equality.
  @override
  int get hashCode => Object.hash(name, _tagEquality.hash(tags));
}

bool sameQuery(Map<String, List<String>> a, Map<String, List<String>> b) =>
    const DeepCollectionEquality.unordered().equals(a, b);
```
**Tuzak:** `ListEquality<List<int>>` iç listeleri identity ile karşılaştırır; iç içe veri için `DeepCollectionEquality` gerekir (test: "ListEquality without deep support ..."). `hashCode` da aynı Equality ile üretilmeli.
**Skill'e ver:** > "Bir `Invoice` sınıfı yaz: `lines` (`List<Map<String, int>>`) alanı olsun; iki fatura içerik olarak aynıysa eşit, hashCode'ları da aynı olsun."
**Kabul:** `==` ve `hashCode` aynı `DeepCollectionEquality` örneğini kullanıyor; iki ayrı ama aynı içerikli nesne için eşitlik ve hash testi geçiyor.

## 4. Değişmez state: kopya mı görünüm mü
**Ne:** `List.unmodifiable` kopya alır; `UnmodifiableListView` canlı, salt-okunur görünümdür. **Ne zaman:** State nesnesinde kopya, ViewModel'in iç listesini dışarı açarken görünüm. **Gerekmez:** Liste zaten dışarı sızmıyorsa.
<!-- snippet: 05_collection/immutable_state -->
```dart
import 'dart:collection';

final class CartState {
  CartState(List<String> skus) : skus = List.unmodifiable(skus);

  // A copy: later changes to the caller's list do not leak in.
  final List<String> skus;

  CartState add(String sku) => CartState([...skus, sku]);
}

final class CartViewModel {
  final List<String> _skus = [];

  // A live view: read-only for callers, but follows _skus.
  List<String> get skus => UnmodifiableListView(_skus);

  void add(String sku) => _skus.add(sku);
}
```
**Tuzak:** `UnmodifiableListView` kopya değildir; sahibi listeyi değiştirirse görünüm de değişir (test: "the view rejects changes but follows the owner").
**Skill'e ver:** > "Bir oynatma listesi ekranı için `PlaylistState` (değişmez, `add` yeni state döner) ve iç listeyi salt-okunur açan bir `PlaylistViewModel` yaz."
**Kabul:** State'e verilen kaynak liste sonradan değişse state değişmiyor; dışarı açılan listeye `add` `UnsupportedError` atıyor.

## 5. Öncelik kuyruğu
**Ne:** `HeapPriorityQueue` en küçük (karşılaştırıcıya göre ilk) elemanı verir. **Ne zaman:** Öncelikli iş/görev sırası. **Gerekmez:** Sıra yalnızca geliş sırasıysa `Queue`/`QueueList`.
<!-- snippet: 05_collection/task_scheduler -->
```dart
import 'package:collection/collection.dart';

typedef _Task = ({int priority, int sequence, String name});

int _highestFirstThenFifo(_Task a, _Task b) => switch (b.priority.compareTo(a.priority)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class TaskScheduler {
  int _sequence = 0;
  final _queue = HeapPriorityQueue<_Task>(_highestFirstThenFifo);

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
**Tuzak:** Eşit öncelikte FIFO garanti edilmez; `sequence` alanı ile karşılaştırıcıya ikinci ölçüt eklenir (test: "runs the highest priority first and FIFO within a priority").
**Skill'e ver:** > "Bir bildirim servisinde acil bildirimler önce, aynı aciliyette olanlar geliş sırasıyla gönderilen bir `NotificationScheduler` yaz."
**Kabul:** Karşılaştırıcı öncelik sonra sıra numarasına bakıyor; `drain()` sonrası kuyruk boş.

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

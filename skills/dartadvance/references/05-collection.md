# 05 · Collections: `dart:collection` + `package:collection`

> Kaynak: https://dart.dev/libraries/dart-core#collections ·
> https://dart.dev/libraries#multi-platform-libraries ·
> https://dart.dev/resources/useful-packages#packages-that-correspond-to-sdk-libraries ·
> https://dart.dev/libraries/dart-core#implementing-map-keys ·
> https://dart.dev/language/records#record-equality
> API: https://api.dart.dev/dart-collection/dart-collection-library.html ·
> https://pub.dev/documentation/collection/1.19.1/ (kaynak: pub cache `collection-1.19.1/lib/`)
> Effective Dart: https://dart.dev/effective-dart/usage#do-use-collection-literals-when-possible,
> https://dart.dev/effective-dart/design#do-override-hashcode-if-you-override,
> https://dart.dev/effective-dart/design#avoid-defining-custom-equality-for-mutable-classes
> Min. sürüm: `dart:collection` her sürümde; **`firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull`/`indexed`/`nonNulls` 3.0**
> (SDK CHANGELOG 3.0.0, `@Since("3.0")`); **`List.unmodifiableOf` / `Map.unmodifiableOf` 3.13** (CHANGELOG 3.13.0);
> `package:collection` bu repoda **1.19.1** (`pubspec.lock`), `environment: sdk` alt sınırı 3.4.

dart.dev iki kütüphaneyi yan yana koyar: multi-platform tablosunda
"`dart:collection`, `package:collection`" tek satırdır ve `collection` paketi
"Packages that expand on Dart core libraries" listesinde "Expands on
dart:collection…" diye geçer (sık kullanılan API'ler: `Equality`,
`CanonicalizedMap`, `MapKeySet`, `MapValueSet`, `PriorityQueue`, `QueueList`).
Paket Dart ekibinindir ama **SDK değildir**: `pubspec.yaml`'a eklenmeden
`firstWhereOrNull` derlenmez.

## Hangisi nereden geliyor (core vs package)

En sık karışan sınır. Kanıt: SDK kaynağı (`dart-sdk/lib/core`, `lib/collection`,
Dart 3.13.0) ve `collection-1.19.1/lib/src`; her satır testte kullanılıyor.

| API | Kütüphane | Import | Kanıt |
|---|---|---|---|
| `List`, `Set`, `Map`, `List.unmodifiable`, `Set.unmodifiable`, `toList(growable: false)` | `dart:core` | yok | `core/list.dart`, `core/set.dart`, `core/iterable.dart` |
| `List.unmodifiableOf`, `Map.unmodifiableOf` (daha iyi tiplenmiş) | `dart:core` **3.13+** | yok | `@Since("3.13")`, CHANGELOG 3.13.0 |
| `firstOrNull`, `lastOrNull`, `singleOrNull`, `elementAtOrNull`, `indexed`, `nonNulls` | `dart:collection` extension'ı (`IterableExtensions`, `NullableIterableExtensions`), **`dart:core` re-export eder** | yok | `collection/iterable.dart` `@Since("3.0")`; `core.dart`: `export "dart:collection" show NullableIterableExtensions, IterableExtensions;` |
| `LinkedHashMap`/`LinkedHashSet`, `HashMap`/`HashSet`, `SplayTreeMap`/`SplayTreeSet`, `Queue`/`ListQueue`, `UnmodifiableListView`/`UnmodifiableMapView`/`UnmodifiableSetView` | `dart:collection` | `import 'dart:collection';` | api.dart.dev/dart-collection |
| `firstWhereOrNull`, `lastWhereOrNull`, `singleWhereOrNull`, `sorted`, `sortedBy`, `groupListsBy`/`groupSetsBy`/`groupFoldBy`, `mapIndexed`/`whereIndexed`/`forEachIndexed`, `none`, `slices`, `whereNot`, `flattened` | `package:collection` (`IterableExtension` vb.) | `import 'package:collection/collection.dart';` | `src/iterable_extensions.dart` |
| `sum`, `average`, `min`/`max`, `minOrNull`/`maxOrNull` (sayı iterable'ları) | `package:collection` | aynı | `IterableNumberExtension`, `IterableIntegerExtension`, `IterableDoubleExtension` |
| `groupBy`, `lastBy`, `minBy`, `maxBy` (top-level fonksiyon) | `package:collection` | aynı | `src/functions.dart` |
| `Equality` ailesi, `PriorityQueue`/`HeapPriorityQueue`, `CanonicalizedMap`, `QueueList`, `MapKeySet`/`MapValueSet`, `binarySearch`/`lowerBound`, `compareNatural` | `package:collection` | aynı | `src/equality.dart`, `priority_queue.dart`, `canonicalized_map.dart`, `queue_list.dart`, `wrappers.dart`, `list_extensions.dart`, `comparators.dart` |

Sınırın üç inceliği (hepsi testli):

- `firstOrNull` & co. **iki yerde de** tanımlı (core'da `IterableExtensions`, pakette `IterableExtension`).
  Paket import edildiğinde çakışma hatası yok; (`core_iterable_helpers_test.dart`)
  paketinkinin seçildiğini gösteriyor. Normal girdide sonuç aynı.
- Paketin `whereNotNull()`'ı 1.19.1'de `@Deprecated('Use .nonNulls instead.')`: core'u kullan.
- `package:collection` `UnmodifiableListView`/`UnmodifiableMapView`'ı `dart:collection`'dan
  **re-export eder**; `UnmodifiableSetView`'ı ise **kendisi de** tanımlar. İkisi prefix'siz
  import edildiğinde ambiguity hatası yok, paketinki kullanılıyor (`name_clash_test.dart`).
- Paket içindeki ayrı kütüphaneler (`package:collection/equality.dart`, `priority_queue.dart`,
  `algorithms.dart`, `wrappers.dart`, `iterable_zip.dart`) 1.19.1'de
  `@Deprecated('Will be removed in collection 2.0.0.')`: yalnızca `collection.dart` import et.

## Sık yapılan yanlış varsayımlar

| Varsayım | Gerçek | Kanıt |
|---|---|---|
| `[1, 2] == [1, 2]` true | **false**: `List`/`Set`/`Map` `==`'i identity'dir | `content_equality_test.dart` |
| Record yapısal eşit, içindeki liste de öyle | Record alanları `==` ile karşılaştırılır; `List` alanı identity ile → `(sku: 'a', options: ['red']) == (sku: 'a', options: ['red'])` **false** (const liste canonical olduğu için const record'da true) | [#record-equality](https://dart.dev/language/records#record-equality), `record_with_list_test.dart` |
| Set sırasızdır, sıraya güvenilmez | Docs "unordered collection" der ([#sets](https://dart.dev/libraries/dart-core#sets)) ama **varsayılan** `Set` = `LinkedHashSet`, insertion order'ı korur; `{}` map literal = `LinkedHashMap`. `HashSet`/`HashMap` hiçbir sıra vaat etmez | api: [Set](https://api.dart.dev/dart-core/Set-class.html), [LinkedHashMap](https://api.dart.dev/dart-collection/LinkedHashMap-class.html) ("A non-constant map literal … is a `LinkedHashMap`") |
| `UnmodifiableListView` bir kopya | **Canlı görünüm**: kaynak liste değişirse view de değişir; kopya için `List.unmodifiable` | api: [UnmodifiableListView](https://api.dart.dev/dart-collection/UnmodifiableListView-class.html), `unmodifiable_view_vs_copy_test.dart` |
| `singleWhereOrNull` iki eşleşmede fırlatır | **null** döner (core `singleWhere` fırlatır) | paket doc'u "Notice: This behavior differs from Iterable.singleWhere" |
| `PriorityQueue` eşit öncelikte FIFO | "There is no specified ordering for objects with the same priority": sıra numarasıyla kır | `src/priority_queue.dart`, `task_scheduler_test.dart` |
| `.sum`/`.average` core'da var | İkisi de `package:collection`; boş `Iterable<int>`'te `sum` 0, `average`/`max` `StateError` | `number_extensions_test.dart` |

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| "Belki yok" araması → `firstWhereOrNull` (paket) | Koşulsuz ilk/son eleman → core `firstOrNull`/`lastOrNull` (paket gerekmez) |
| index + eleman → paket `mapIndexed` | Core `indexed` + record pattern (`for (final (i, x) in xs.indexed)`) yetiyorsa paket gerekmez |
| İçerik eşitliği gereken `==`/`hashCode` → `ListEquality`/`SetEquality`/`MapEquality` (`equals` + `hash` birlikte) | Alanlar zaten değer tipiyse (`String`, `int`, record) → `Object.hash` yeterli ([#implementing-map-keys](https://dart.dev/libraries/dart-core#implementing-map-keys)); iç içe koleksiyon → `DeepCollectionEquality` |
| State'i dışarı açarken salt-okunur **görünüm** → `UnmodifiableListView` | Sonradan değişmemesi gereken anlık görüntü → `List.unmodifiable` (3.13+: `List.unmodifiableOf`) |
| Sürekli sıralı anahtar, aralık sorgusu (`lastKeyBefore`) → `SplayTreeMap` | Bir kere sıralayıp göstermek → `sortedBy` / `List.sort` |
| İki uçtan ekle/çıkar → `Queue` (`ListQueue`) | İki uç + index erişimi → `QueueList` (paket) |
| Öncelikli iş kuyruğu → `HeapPriorityQueue` | Az sayıda eleman, tek seferlik → `sorted` |
| Anahtarı normalize edilen map (header adı) → `CanonicalizedMap` | Özel eşitlik tek yerde → `LinkedHashMap(equals:, hashCode:)` (SDK) |
| `{}`, `[]` literal (Effective Dart: [collection literals](https://dart.dev/effective-dart/usage#do-use-collection-literals-when-possible)) | `LinkedHashMap()`/`Set()` constructor'ı: yalnızca özel eşitlik veya `SplayTree*` gerekiyorsa |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Domain / Entity | Koleksiyon alanı olan entity: `List.unmodifiable` ile kopyala + `ListEquality().equals`/`hash` ile `==`/`hashCode` (Effective Dart: [mutable sınıfta özel eşitlikten kaçın](https://dart.dev/effective-dart/design#avoid-defining-custom-equality-for-mutable-classes)) |
| Domain / Entity (alternatif) | Record: yapısal eşitlik bedava, ama `List` alanı identity ile karşılaştırılır |
| Data / Model | `groupListsBy`, `sortedBy`, `slices` (sayfalama), `sum` ile eşleme |
| Data / RepositoryImpl | `firstWhereOrNull` → `null` → `Err(...)`; `firstWhere` + `StateError` yakalamaya gerek yok |
| Application / state sınıfı (düz Dart) | Private `List`, public `UnmodifiableListView` getter; iş kuyruğu için `HeapPriorityQueue` |
| Presentation | `LinkedHashMap` sırası (literal) göstermeye güvenilebilir; `SplayTreeMap` sıralı liste |

## Doğrulanmış örnekler

Tüm kod `examples/lib/05_collection/` altında, testleri
`examples/test/05_collection/` altında
(`dart run dartadvance_tool:dartadvance verify 05_collection`).

### SDK: `dart:core` ve `dart:collection`

Dart 3.0 extension'ları: import gerekmez.

<!-- snippet: 05_collection/core_iterable_helpers -->
```dart
/// Dart 3.0 `Iterable` extensions: no import and no package needed.
({int? first, int? last, int? single, int? third, List<(int, String)> indexed, List<String> named})
coreHelpers(List<int> numbers, List<String?> maybeNames) => (
  first: numbers.firstOrNull,
  last: numbers.lastOrNull,
  single: numbers.singleOrNull, // null for zero OR for two-plus elements
  third: numbers.elementAtOrNull(2),
  indexed: [
    for (final (index, name) in ['a', 'b'].indexed) (index, name),
  ],
  named: maybeNames.nonNulls.toList(),
);
```

Literal'ler insertion order'lı; var olan anahtarı güncellemek sırasını değiştirmez.

<!-- snippet: 05_collection/literal_insertion_order -->
```dart
({List<String> mapKeys, List<String> setElements}) literalOrder() {
  final scores = {'zeynep': 3, 'ali': 5, 'mert': 1};
  final tags = {'flutter', 'dart', 'async'};
  scores['bora'] = 2;
  scores['ali'] = 9; // Updating a key keeps its position.
  return (mapKeys: scores.keys.toList(), setElements: tags.toList());
}
```

Görünüm vs kopya. `add` ikisinde de `UnsupportedError`.

<!-- snippet: 05_collection/unmodifiable_view_vs_copy -->
```dart
import 'dart:collection';

({List<int> view, List<int> copy}) viewVsCopy() {
  final source = <int>[1, 2];
  final view = UnmodifiableListView<int>(source);
  final copy = List<int>.unmodifiable(source);
  source.add(3);
  return (view: view, copy: copy);
}
```

`SplayTreeMap`/`SplayTreeSet`: sıralı iterasyon, özel comparator, aralık sorgusu.

<!-- snippet: 05_collection/splay_tree -->
```dart
import 'dart:collection';

final class PriceIndex {
  final SplayTreeMap<int, String> _byPrice = SplayTreeMap<int, String>();

  void add(int priceMinor, String productId) => _byPrice[priceMinor] = productId;

  List<int> get pricesAscending => _byPrice.keys.toList();
  String? get cheapest => _byPrice.isEmpty ? null : _byPrice[_byPrice.firstKey()];

  /// The most expensive product strictly cheaper than [budget].
  String? bestUnder(int budget) {
    final key = _byPrice.lastKeyBefore(budget);
    return key == null ? null : _byPrice[key];
  }
}

SplayTreeSet<String> sortedTags(Iterable<String> tags) =>
    SplayTreeSet<String>((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))..addAll(tags);
```

`Queue()` bir `ListQueue` oluşturur: iki uçta sabit zamanlı okuma/çıkarma, amortize sabit
zamanlı ekleme. Burada sınırlı bir "son bakılanlar" tamponu.

<!-- snippet: 05_collection/recently_viewed_queue -->
```dart
import 'dart:collection';

final class RecentlyViewed {
  RecentlyViewed(this.capacity);
  final int capacity;
  final Queue<String> _items = Queue<String>();

  void view(String id) {
    _items
      ..remove(id)
      ..addFirst(id);
    if (_items.length > capacity) _items.removeLast();
  }

  List<String> get items => _items.toList();
}
```

`HashMap`/`LinkedHashMap` constructor'ları `equals`/`hashCode` (ve `isValidKey`)
alır; api doc: birini veriyorsan genelde ikisini de ver, tutarlı olsunlar.

<!-- snippet: 05_collection/custom_equality_map -->
```dart
import 'dart:collection';

Map<String, int> caseInsensitiveCounts(Iterable<String> words) {
  final counts = LinkedHashMap<String, int>(
    equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
    hashCode: (key) => key.toLowerCase().hashCode,
  );
  for (final word in words) {
    counts.update(word, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}
```

### `package:collection`

Predicate'li `...OrNull` aramaları: paket.

<!-- snippet: 05_collection/first_where_or_null -->
```dart
import 'package:collection/collection.dart';

({String? firstLong, String? lastShort, String? onlyEmpty}) lookups(List<String> words) => (
  firstLong: words.firstWhereOrNull((word) => word.length > 4),
  lastShort: words.lastWhereOrNull((word) => word.length < 3),
  onlyEmpty: words.singleWhereOrNull((word) => word.isEmpty), // two-plus matches: null
);
```

Gruplama, yeni liste döndüren sıralama, doğal sıralama (`'v2' < 'v10'`; düz
`sort()` `['v1', 'v10', 'v2']` verir).

`groupListsBy` (extension) ve `groupBy` (top-level fonksiyon) `Map<K, List<T>>` kurar;
değerler orijinal göreli sıralarını korur.

<!-- snippet: 05_collection/group_by -->
```dart
import 'package:collection/collection.dart';

typedef Sale = ({String city, String sku, int amount});

Map<String, List<Sale>> salesByCity(Iterable<Sale> sales) =>
    sales.groupListsBy((sale) => sale.city);

Map<String, List<Sale>> salesByCityFunction(Iterable<Sale> sales) =>
    groupBy(sales, (Sale sale) => sale.city);
```

<!-- snippet: 05_collection/sorted_by -->
```dart
import 'package:collection/collection.dart';

import 'group_by.dart';

/// Returns a new list; core `List.sort` sorts in place and returns `void`.
List<Sale> byAmount(Iterable<Sale> sales) => sales.sortedBy((sale) => sale.amount);

List<String> naturalOrder(Iterable<String> names) => names.sorted(compareNatural);
```

Sayı extension'ları (`sum`, `average`, `max`, `maxOrNull`…): boş `Iterable<int>`'te `sum` 0,
`average`/`max` `StateError`.

<!-- snippet: 05_collection/number_extensions -->
```dart
import 'package:collection/collection.dart';

({int total, double mean, int? highest}) stats(List<int> amounts) => (
  total: amounts.sum,
  mean: amounts.isEmpty ? 0 : amounts.average,
  highest: amounts.maxOrNull,
);
```

`mapIndexed`/`whereIndexed`/`slices`/`none` paket extension'larıdır; index + eleman için core
karşılığı `indexed` (record, 3.0).

<!-- snippet: 05_collection/indexed_extensions -->
```dart
import 'package:collection/collection.dart';

({List<String> labels, List<String> evens, List<List<int>> pages, bool noneNegative}) indexedOps(
  List<String> names,
  List<int> ids,
) => (
  labels: names.mapIndexed((index, name) => '${index + 1}. $name').toList(),
  evens: names.whereIndexed((index, _) => index.isEven).toList(),
  pages: ids.slices(2).toList(),
  noneNegative: ids.none((id) => id < 0),
);
```

`Equality` sınıfları **sığ**dır: `ListEquality<List<int>>` iç listeleri `==` ile
(identity) karşılaştırır, iç içe yapı için `DeepCollectionEquality`.
Flutter'ın `listEquals`/`setEquals`/`mapEquals`'ı da sığdır ve doc'ları aynı
yönlendirmeyi yapar.

<!-- snippet: 05_collection/content_equality -->
```dart
import 'package:collection/collection.dart';

Map<String, List<String>> _freshTags() => {
  'tags': ['a', 'b'],
};

({bool list, bool set, bool map, bool deep, bool unorderedList}) contentEquality() => (
  list: const ListEquality<int>().equals([1, 2], [1, 2]),
  set: const SetEquality<int>().equals({1, 2}, {2, 1}),
  map: const MapEquality<String, int>().equals({'a': 1}, {'a': 1}),
  deep: const DeepCollectionEquality().equals(_freshTags(), _freshTags()),
  unorderedList: const DeepCollectionEquality.unordered().equals([1, 2], [2, 1]),
);
```

`CanonicalizedMap` her anahtarı **bir kez** kanonik biçime çevirir (doc: özel eşitlikli
`LinkedHashMap`'ten ucuz), iterasyonda orijinal anahtarı tutar.

<!-- snippet: 05_collection/canonicalized_map -->
```dart
import 'package:collection/collection.dart';

CanonicalizedMap<String, String, String> headers() =>
    CanonicalizedMap<String, String, String>((key) => key.toLowerCase());
```

`binarySearch`/`lowerBound` yalnızca **aynı comparator'la sıralı** listede anlamlı
(aksi halde sonuç "unspecified").

<!-- snippet: 05_collection/binary_search -->
```dart
import 'package:collection/collection.dart';

int _compare(int a, int b) => a.compareTo(b);

/// [sorted] must be sorted with the same comparator.
({int found, int missing, int insertAt}) searchSorted(List<int> sorted) => (
  found: sorted.binarySearch(30, _compare),
  missing: sorted.binarySearch(35, _compare),
  insertAt: sorted.lowerBound(35, _compare),
);
```

`QueueList` hem `Queue` (`addFirst`/`removeFirst`) hem `List` (`[]`); `dart:collection`'daki
`ListQueue`'da `[]` yok.

<!-- snippet: 05_collection/queue_list -->
```dart
import 'package:collection/collection.dart';

QueueList<String> history() => QueueList<String>()
  ..add('b')
  ..addFirst('a')
  ..add('c');
```

### Katmanlarda

Entity: kopya + içerik eşitliği + uyumlu `hashCode`
([Effective Dart](https://dart.dev/effective-dart/design#do-override-hashcode-if-you-override)).
Test: iki eşit `Order` bir `Set`'te tek eleman.

<!-- snippet: 05_collection/order_entity -->
```dart
import 'package:collection/collection.dart';

final class Order {
  Order({required this.id, required List<String> skus}) : skus = List.unmodifiable(skus);
  final String id;
  final List<String> skus;

  static const _skusEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      other is Order && other.id == id && _skusEquality.equals(other.skus, skus);

  @override
  int get hashCode => Object.hash(id, _skusEquality.hash(skus));
}
```

Record ile karşılaştırma: aynı liste **instance**'ı → true, eşit içerikli iki
liste → false.

<!-- snippet: 05_collection/record_with_list -->
```dart
typedef CartLine = ({String sku, List<String> options});

/// A `List` field inside a record still compares by identity.
bool sameLine(CartLine a, CartLine b) => a == b;
```

Repository: `firstWhereOrNull` + switch → `Result` (SKILL.md mimarisi).

<!-- snippet: 05_collection/order_repository -->
```dart
import 'package:collection/collection.dart';

import '../00_architecture/result.dart';
import 'order_entity.dart';

abstract interface class OrderRepository {
  Result<Order> findById(String id);
}

final class InMemoryOrderRepository implements OrderRepository {
  InMemoryOrderRepository(this._orders);
  final List<Order> _orders;

  @override
  Result<Order> findById(String id) => switch (_orders.firstWhereOrNull((o) => o.id == id)) {
    final order? => Ok(order),
    null => const Err(ServerFailure(404)),
  };
}
```

Data mapping. `sortedBy<num>`: `int` `Comparable<num>` olduğundan `K extends
Comparable<K>` sınırı `num` ile sağlanır. `groupListsBy` müşterilerin ilk görülme sırasını korur.

<!-- snippet: 05_collection/order_rows_mapping -->
```dart
import 'package:collection/collection.dart';

typedef OrderRow = ({String customer, String orderId, int totalMinor});

Map<String, List<OrderRow>> rowsByCustomer(Iterable<OrderRow> rows) => {
  for (final MapEntry(:key, :value) in rows.groupListsBy((row) => row.customer).entries)
    key: value.sortedBy<num>((row) => -row.totalMinor),
};
```

State sınıfı (düz Dart): değişken liste private, dışarıya `UnmodifiableListView`
(`dart:collection`; paket re-export eder) açılır, `state.items.add(...)` `add`'i atlamak yerine
fırlatır.

<!-- snippet: 05_collection/cart_state -->
```dart
import 'dart:collection';

final class CartState {
  final List<String> _items = [];

  UnmodifiableListView<String> get items => UnmodifiableListView(_items);

  void add(String sku) => _items.add(sku);
}
```

`HeapPriorityQueue` eşit önceliklerde sıra vaat etmez; sıra numarası aynı öncelik içinde
FIFO sağlar. Karşılaştırıcı küçük bir private fonksiyondur.

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

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib`
(`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`).

| Regex | Satır |
|---|---|
| `^import 'package:collection/` | 11 |
| `firstWhereOrNull` | 5 |
| `listEquals\(` / `setEquals\(` / `mapEquals\(` | 29 / 8 / 5 |
| `Equality<` | 3 |
| `PriorityQueue` | 2 |
| `SplayTreeMap\|SplayTreeSet` | 8 |
| `Queue<` | 13 |
| `LinkedHashMap\|LinkedHashSet` | 9 |
| `UnmodifiableListView` / `UnmodifiableMapView` | 1 / 0 |
| `\.firstOrNull` / `\.nonNulls` | 2 / 0 |

`package:collection` import eden 11 dosya ve kullandıkları:
`cupertino/sliding_segmented_control.dart` (`.sum`), `material/carousel.dart`
(`.max`, `.min`, `.sum`), `material/input_decorator.dart`,
`widgets/draggable_scrollable_sheet.dart`, `widgets/radio_group.dart`
(`firstWhereOrNull`), `painting/_network_image_io.dart` ve `_network_image_web.dart`
(`MapEquality.hash`), `scheduler/binding.dart` (`HeapPriorityQueue`),
`semantics/semantics.dart` (`.flattened`), `widgets/router.dart`
(`DeepCollectionEquality.unordered`), `widgets/widget_state.dart` (`MapEquality.hash`).

| Kullanım | Ne gösteriyor | Kaynak |
|---|---|---|
| `NetworkImage.==` Flutter'ın `mapEquals`'ı, `hashCode` `const MapEquality<String, String>().hash(headers)` | Entity kalıbının aynısı: içerik eşitliği + **ona uyan hash**. Flutter'ın `mapEquals`'ının hash karşılığı yok, hash için pakete gidiyor | [painting/_network_image_io.dart#L185](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/_network_image_io.dart#L185) |
| `WidgetStateMapper`: `==` `mapEquals`, `hashCode` `MapEquality<…>().hash(_map)` | Aynı ikili, framework'ün state API'sinde | [widgets/widget_state.dart#L1034](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/widget_state.dart#L1034) |
| `foundation/collections.dart`: `setEquals`, `listEquals`, `mapEquals` | Flutter'ın kendi sığ, null kabul eden karşılaştırmaları; doc'ları derin eşitlik için `DeepCollectionEquality`'ye yönlendiriyor, dosyada `// TODO(ianh): These should be on the Set and List classes themselves.` notu var. Aynı dosyada `binarySearch` ve `mergeSort` de var (paketteki top-level fonksiyonlarla aynı isimler) | [foundation/collections.dart#L58](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/collections.dart#L58) |
| `PlatformRouteInformationProvider._equals`: `const DeepCollectionEquality.unordered().equals(a.queryParametersAll, b.queryParametersAll)` | `Map<String, List<String>>` için derin **ve** sırasız eşitlik (query parametre sırası önemsiz) | [widgets/router.dart#L1522](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/router.dart#L1522) |
| `SchedulerBinding._taskQueue = HeapPriorityQueue<_TaskEntry<dynamic>>(_taskSorter)` | Framework'ün görev kuyruğu; `_taskSorter` `-e1.priority.compareTo(e2.priority)` ile yüksek önceliği öne alıyor. `import … show HeapPriorityQueue, PriorityQueue;` | [scheduler/binding.dart#L439](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/scheduler/binding.dart#L439) |
| `RadioGroup`: `_radios.firstWhereOrNull((radio) => radio.focusNode.hasFocus)` → `if (radio == null) return;` | "Belki yok" araması, `StateError` yerine null | [widgets/radio_group.dart#L147](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/radio_group.dart#L147) |
| `static final List<int> _normalizedBodyScales = UnmodifiableListView<int>(<int>[for …])` | Salt-okunur statik tablo (framework'teki tek `UnmodifiableListView`) | [cupertino/menu_anchor.dart#L223](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/cupertino/menu_anchor.dart#L223) |
| `SplayTreeMap<double, AssetMetadata>()` DPR → varyant | Sıralı anahtar üzerinde "en yakın çözünürlük" araması | [painting/image_resolution.dart#L337](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/painting/image_resolution.dart#L337) |
| `SliverMultiBoxAdaptorElement._childElements = SplayTreeMap<int, Element?>()` | Index'e göre sıralı child elementler | [widgets/sliver.dart#L965](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/sliver.dart#L965) |
| `<ChildBackButtonDispatcher>{} as LinkedHashSet<ChildBackButtonDispatcher>` | Set literal'inin `LinkedHashSet` olduğuna framework'ün kendisi güveniyor | [widgets/router.dart#L973](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/router.dart#L973) |
| `ScaffoldMessengerState._snackBars = Queue<ScaffoldFeatureController<SnackBar, …>>()` | Sırayla gösterilen SnackBar kuyruğu (`dart:collection` `Queue`) | [material/scaffold.dart#L198](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/scaffold.dart#L198) |

## Lint'ler

`recommended` seti `core`'u içerir.

| Lint | Set | Ne yapar |
|---|---|---|
| [collection_methods_unrelated_type](https://dart.dev/tools/linter-rules/collection_methods_unrelated_type) | core | `List<int>.contains('1')`, `Map<K, V>[x]`, `Set.remove`, `Queue.remove` gibi çağrılarda ilgisiz tipli argümanı yakalar (her zaman false/null döner) |
| [prefer_iterable_whereType](https://dart.dev/tools/linter-rules/prefer_iterable_whereType) | core | `where((e) => e is T)` yerine `whereType<T>()` |
| [prefer_is_empty](https://dart.dev/tools/linter-rules/prefer_is_empty) / [prefer_is_not_empty](https://dart.dev/tools/linter-rules/prefer_is_not_empty) | core | `length == 0` yerine `isEmpty` / `isNotEmpty` |
| [prefer_collection_literals](https://dart.dev/tools/linter-rules/prefer_collection_literals) | recommended | `Map()`, `Set()`, `LinkedHashMap()`, `LinkedHashSet()` yerine `{}`; `LinkedHashSet`/`LinkedHashMap` **tipi beklenen** yerde istisna |
| [avoid_function_literals_in_foreach_calls](https://dart.dev/tools/linter-rules/avoid_function_literals_in_foreach_calls) | recommended | `forEach((x) {...})` yerine `for-in` |
| [unnecessary_to_list_in_spreads](https://dart.dev/tools/linter-rules/unnecessary_to_list_in_spreads) | recommended | `...xs.map(f).toList()` içindeki gereksiz `toList()` |
| [prefer_contains](https://dart.dev/tools/linter-rules/prefer_contains) | recommended | `indexOf(x) != -1` yerine `contains(x)` |

Not: [iterable_contains_unrelated_type](https://dart.dev/tools/linter-rules/iterable_contains_unrelated_type)
ve [list_remove_unrelated_type](https://dart.dev/tools/linter-rules/list_remove_unrelated_type)
Dart 3.3'te **kaldırıldı** (sayfa: "no longer functional"); yerlerine
`collection_methods_unrelated_type`.

## Kontrol listesi

- [ ] Kullandığın API core mu paket mi? `firstWhereOrNull`, `sortedBy`, `groupListsBy`, `sum`, `Equality`, `PriorityQueue` → `package:collection` pubspec'te olmalı.
- [ ] Yalnızca `firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull`/`indexed`/`nonNulls` gerekiyorsa paket gereksiz (SDK ≥ 3.0).
- [ ] `whereNotNull()` → `nonNulls`; `package:collection/equality.dart` gibi alt importlar → `package:collection/collection.dart`.
- [ ] Koleksiyon alanlı sınıfta `==` override ediyorsan `hashCode` aynı `Equality`'nin `hash`'ini kullanıyor mu? Alan dışarıdan değiştirilemez mi (`List.unmodifiable`)?
- [ ] Record/`==` ile karşılaştırılan yerde `List` alanı var mı? (identity → beklenmedik false)
- [ ] State dışarı `List` olarak mı açılıyor? → `UnmodifiableListView` (görünüm) veya `List.unmodifiable` (kopya): hangisinin gerektiğine karar ver.
- [ ] `PriorityQueue`'da eşit önceliklerin sırası önemli mi? → sıra numarasıyla tie-break.
- [ ] `binarySearch`/`lowerBound` listesi aynı comparator'la sıralı mı?
- [ ] `List.unmodifiableOf`/`Map.unmodifiableOf` kullanıyorsan SDK alt sınırı ≥ 3.13 mü?

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: "Belki yok" araması → `Result` (`firstWhereOrNull`)
- **Demo promptu:** "Kütüphane uygulaması için ISBN'e göre kitap bulan, bulamazsa `Err` dönen bellek içi bir repository yaz."
- **Model:** [`examples/lib/05_collection/order_repository.dart`](../../../examples/lib/05_collection/order_repository.dart), [`first_where_or_null.dart`](../../../examples/lib/05_collection/first_where_or_null.dart), [`core_iterable_helpers.dart`](../../../examples/lib/05_collection/core_iterable_helpers.dart)
- **Katman:** Domain (repository arayüzü) + Data / RepositoryImpl
- **Adımlar:** 1. Domain'de `Result<T>` dönen repository arayüzü tanımla. 2. Data'da `firstWhereOrNull` (**`package:collection`**; projenin `pubspec.yaml`'ına `collection` bağımlılığı eklenmeli (`dart pub add collection`)) ile ara. 3. Sonucu `switch` ile `final x? => Ok(x)`, `null => Err(...)` olarak eşle; `try`/`catch` yok. 4. Predicate gerekmiyorsa paketsiz core `firstOrNull`/`singleOrNull` (**`dart:core`**, 3.0) kullan.
- **Kabul kriteri:** Test, bulunan kaydın `Ok`, bulunmayanın `Err` döndüğünü ve core `firstWhere`/`singleWhere`'in aynı girdide `StateError` fırlattığını kanıtlar.
- **Min. sürüm:** core `...OrNull` 3.0; `package:collection` 1.19.1 (SDK ≥ 3.4)

### Tarif: Koleksiyon alanlı entity'de içerik eşitliği
- **Demo promptu:** "Bir tarif entity'si yaz: malzeme listesi içeriğe göre karşılaştırılsın, iki eşit tarif bir `Set`'te tek eleman olsun."
- **Model:** [`examples/lib/05_collection/order_entity.dart`](../../../examples/lib/05_collection/order_entity.dart), [`content_equality.dart`](../../../examples/lib/05_collection/content_equality.dart), [`record_with_list.dart`](../../../examples/lib/05_collection/record_with_list.dart)
- **Katman:** Domain / Entity
- **Adımlar:** 1. Constructor'da listeyi `List.unmodifiable` (**`dart:core`**) ile kopyala. 2. `static const` bir `ListEquality` (**`package:collection`**; projenin `pubspec.yaml`'ına `collection` bağımlılığı eklenmeli (`dart pub add collection`)) tanımla. 3. `==`'i bu equality'nin `equals`'ı, `hashCode`'u aynı equality'nin `hash`'i ile yaz. 4. İç içe koleksiyon varsa `DeepCollectionEquality` kullan; aynı veriyi record'a koyuyorsan `List` alanının identity ile karşılaştırıldığını not et.
- **Kabul kriteri:** Test, eşit içerikli iki entity'nin `==` ve aynı `hashCode` verdiğini, `Set`'te tek eleman olduğunu, sıranın önemli olduğunu ve listeye yazmanın `UnsupportedError` fırlattığını kanıtlar.
- **Min. sürüm:** `package:collection` 1.19.1; record 3.0

### Tarif: Salt-okunur state: görünüm mü kopya mı
- **Demo promptu:** "Bildirim kutusu state sınıfı yaz: okunmamış bildirimleri dışarıya canlı ama değiştirilemez bir liste olarak, dışa aktarım için ise anlık kopya olarak versin."
- **Model:** [`examples/lib/05_collection/cart_state.dart`](../../../examples/lib/05_collection/cart_state.dart), [`unmodifiable_view_vs_copy.dart`](../../../examples/lib/05_collection/unmodifiable_view_vs_copy.dart)
- **Katman:** Application / state sınıfı
- **Adımlar:** 1. Değişken listeyi private tut. 2. Canlı görünüm için getter `UnmodifiableListView` (**`dart:collection`**; paket re-export eder, bağımlılık gerekmez) döndürsün. 3. Anlık görüntü için `List.unmodifiable` (**`dart:core`**; 3.13+ `List.unmodifiableOf`) döndür. 4. Değişiklik yalnızca state metoduyla yapılsın.
- **Kabul kriteri:** Test, görünümün sonraki değişikliği gösterdiğini, kopyanın göstermediğini ve ikisine de yazmanın `UnsupportedError` fırlattığını kanıtlar.
- **Min. sürüm:** her sürüm (`List.unmodifiableOf` 3.13)

### Tarif: Öncelikli iş kuyruğu, eşit öncelikte FIFO
- **Demo promptu:** "Yükleme kuyruğu yaz: kullanıcının başlattığı yüklemeler arka plan yüklemelerinden önce, aynı öncelikte olanlar geliş sırasıyla işlensin."
- **Model:** [`examples/lib/05_collection/task_scheduler.dart`](../../../examples/lib/05_collection/task_scheduler.dart)
- **Katman:** Application / state sınıfı (veya Data)
- **Adımlar:** 1. Öğeyi `(priority, sequence, payload)` record'u olarak tut. 2. Karşılaştırıcıyı private top-level fonksiyon yap: önce öncelik (büyük önce), eşitse `sequence`. 3. `HeapPriorityQueue` (**`package:collection`**; projenin `pubspec.yaml`'ına `collection` bağımlılığı eklenmeli (`dart pub add collection`)) bu karşılaştırıcıyla kurulsun. 4. Her eklemede sayaç artsın.
- **Kabul kriteri:** Test, yüksek önceliğin önce çıktığını ve aynı öncelikte ekleme sırasının korunduğunu kanıtlar.
- **Min. sürüm:** record 3.0; `package:collection` 1.19.1

### Tarif: Data mapping: grupla, sırala, özetle
- **Demo promptu:** "Harcama satırlarını kategoriye göre grupla, her grubu tutara göre azalan sırala ve kategori toplamlarını hesapla."
- **Model:** [`examples/lib/05_collection/order_rows_mapping.dart`](../../../examples/lib/05_collection/order_rows_mapping.dart), [`group_by.dart`](../../../examples/lib/05_collection/group_by.dart), [`sorted_by.dart`](../../../examples/lib/05_collection/sorted_by.dart), [`number_extensions.dart`](../../../examples/lib/05_collection/number_extensions.dart), [`indexed_extensions.dart`](../../../examples/lib/05_collection/indexed_extensions.dart)
- **Katman:** Data / Model → Entity eşleme
- **Adımlar:** 1. Satırı record typedef'i olarak tanımla. 2. `groupListsBy` ile grupla (ilk görülme sırası korunur). 3. Her grubu `sortedBy` ile **yeni** listeye sırala; metin içinde sayı varsa `compareNatural`. 4. Toplam için `sum`, index gerekiyorsa `mapIndexed`; hepsi **`package:collection`** (projenin `pubspec.yaml`'ına `collection` bağımlılığı eklenmeli (`dart pub add collection`)); yalnızca index + eleman için core `indexed` yeter.
- **Kabul kriteri:** Test, grup anahtar sırasını, grup içi sıralamayı, kaynağın değişmediğini ve boş listede `sum`'ın 0, `average`'ın `StateError` olduğunu kanıtlar.
- **Min. sürüm:** `package:collection` 1.19.1

### Tarif: SDK yapıları: sıralı map, iki uçlu kuyruk, özel eşitlik
- **Demo promptu:** "Otel odası fiyat indeksi (bütçenin altındaki en pahalı oda), son aranan 5 şehir listesi ve büyük/küçük harf duyarsız etiket sayacı yaz; paket kullanmadan."
- **Model:** [`examples/lib/05_collection/splay_tree.dart`](../../../examples/lib/05_collection/splay_tree.dart), [`recently_viewed_queue.dart`](../../../examples/lib/05_collection/recently_viewed_queue.dart), [`custom_equality_map.dart`](../../../examples/lib/05_collection/custom_equality_map.dart), [`literal_insertion_order.dart`](../../../examples/lib/05_collection/literal_insertion_order.dart)
- **Katman:** Data veya state sınıfı
- **Adımlar:** 1. Sürekli sıralı anahtar ve aralık sorgusu için `SplayTreeMap` + `lastKeyBefore`. 2. Sınırlı "son kullanılanlar" için `Queue` (`addFirst`/`removeLast`). 3. Özel anahtar eşitliği için `LinkedHashMap(equals:, hashCode:)`, ikisi tutarlı. 4. Hepsi **`dart:collection`** (`import 'dart:collection';`), bağımlılık gerekmez; sıra yalnızca ekleme sırası ise düz `{}` literal yeter.
- **Kabul kriteri:** Test, sıralı iterasyonu, aralık sorgusunu, kapasite sınırını ve eşit sayılan anahtarların tek girdi olduğunu kanıtlar.
- **Min. sürüm:** her sürüm

### Tarif: Paketin özel yapıları: `CanonicalizedMap`, `QueueList`, `binarySearch`
- **Demo promptu:** "HTTP başlıklarını büyük/küçük harf duyarsız tutan bir map, geri/ileri gezinme geçmişi ve sıralı bir sürüm listesinde ekleme noktası bulan fonksiyon yaz."
- **Model:** [`examples/lib/05_collection/canonicalized_map.dart`](../../../examples/lib/05_collection/canonicalized_map.dart), [`queue_list.dart`](../../../examples/lib/05_collection/queue_list.dart), [`binary_search.dart`](../../../examples/lib/05_collection/binary_search.dart)
- **Katman:** Data
- **Adımlar:** 1. Normalize edilen anahtar için `CanonicalizedMap` (anahtarı bir kez kanonik biçime çevirir). 2. İki uç + index erişimi için `QueueList`. 3. Sıralı listede `binarySearch`/`lowerBound`, listeyi sıralayan comparator'ın aynısıyla. 4. Hepsi **`package:collection`**; projenin `pubspec.yaml`'ına `collection` bağımlılığı eklenmeli (`dart pub add collection`).
- **Kabul kriteri:** Test, eşdeğer anahtarların tek girdi olduğunu, `QueueList`'te hem `addFirst` hem `[]` çalıştığını ve `binarySearch`'ün bulunmayan için -1, `lowerBound`'un ekleme noktası döndüğünü kanıtlar.
- **Min. sürüm:** `package:collection` 1.19.1

## Pekiştirme

### Alıştırma 1 · Belirsiz kupon kodu (kolay)

`resolveCoupon(coupons, input)` yaz: kullanıcı kupon kodunun **başını** yazıyor
(büyük/küçük harf ve baştaki/sondaki boşluk önemsiz). Tam olarak bir kupon eşleşirse onu
döndür; hiç eşleşme yoksa **ya da birden fazla** eşleşme varsa (belirsiz) `null` dön.
`try`/`catch` kullanma. Core `singleWhere` aynı girdide ne yapardı?

**İpucu:** "Sık yapılan yanlış varsayımlar" tablosundaki `singleWhereOrNull` satırı;
fonksiyon `package:collection`'dan gelir, core'da yalnızca predicate'siz `singleOrNull` var.

<details><summary>Çözüm</summary>

<!-- snippet: 05_collection/practice/ex1_resolve_coupon -->
```dart
import 'package:collection/collection.dart';

typedef Coupon = ({String code, int percent});

/// `null` for zero matches and for an ambiguous prefix (two-plus matches).
Coupon? resolveCoupon(Iterable<Coupon> coupons, String input) {
  final prefix = input.trim().toUpperCase();
  if (prefix.isEmpty) return null;
  return coupons.singleWhereOrNull((coupon) => coupon.code.startsWith(prefix));
}
```

`'W'` hem `WELCOME10` hem `WINTER20` ile eşleşir: `singleWhereOrNull` → `null`,
core `singleWhere` → `StateError`.

</details>

### Alıştırma 2 · Destek kutusu: katmanlar boyunca koleksiyonlar (orta)

Bir destek talebi kutusu kur. **Domain:** `Severity` enum'u (`low`, `normal`, `urgent`),
`SupportTicket`, `TicketRepository` (`Result<SupportTicket> findById`). **Data:**
`InMemoryTicketRepository`: bulunamayan id → `Err(ServerFailure(404))`, `StateError`
yakalamadan. **State sınıfı:** `InboxState` talepleri önceliğe göre işlesin: önce `urgent`,
**aynı önceliktekiler geliş sırasıyla (FIFO)**. İşlenenler `handled` getter'ı ile canlı,
salt-okunur bir görünüm olarak, `handledSnapshot()` ile salt-okunur bir kopya olarak
dışarı açılsın.

**İpucu:** "Katmanlarda" bölümündeki `TaskScheduler` ve `CartState`;
`HeapPriorityQueue` eşit önceliklerde sıra vaat etmez.

<details><summary>Çözüm</summary>

Domain + Data:

<!-- snippet: 05_collection/practice/ex2_support_ticket -->
```dart
import 'package:collection/collection.dart';

import '../../00_architecture/result.dart';

enum Severity { low, normal, urgent }

final class SupportTicket {
  const SupportTicket({required this.id, required this.severity});
  final String id;
  final Severity severity;
}

abstract interface class TicketRepository {
  Result<SupportTicket> findById(String id);
}

final class InMemoryTicketRepository implements TicketRepository {
  InMemoryTicketRepository(this._tickets);
  final List<SupportTicket> _tickets;

  @override
  Result<SupportTicket> findById(String id) {
    final ticket = _tickets.firstWhereOrNull((ticket) => ticket.id == id);
    return ticket == null ? const Err(ServerFailure(404)) : Ok(ticket);
  }
}
```

State sınıfı:

<!-- snippet: 05_collection/practice/ex2_inbox_state -->
```dart
import 'package:collection/collection.dart';

import 'ex2_support_ticket.dart';

typedef _Entry = ({int priority, int sequence, SupportTicket ticket});

int _mostSevereFirstThenFifo(_Entry a, _Entry b) => switch (b.priority.compareTo(a.priority)) {
  0 => a.sequence.compareTo(b.sequence),
  final byPriority => byPriority,
};

final class InboxState {
  int _sequence = 0;
  final List<SupportTicket> _handled = [];
  final _queue = HeapPriorityQueue<_Entry>(_mostSevereFirstThenFifo);

  void receive(SupportTicket ticket) =>
      _queue.add((priority: ticket.severity.index, sequence: _sequence++, ticket: ticket));

  SupportTicket? handleNext() {
    if (_queue.isEmpty) return null;
    final ticket = _queue.removeFirst().ticket;
    _handled.add(ticket);
    return ticket;
  }

  /// A live, read-only view.
  UnmodifiableListView<SupportTicket> get handled => UnmodifiableListView(_handled);

  /// A read-only copy of this moment.
  List<SupportTicket> handledSnapshot() => List.unmodifiable(_handled);
}
```

Test: `handled` bir kez alınıp sonra bir talep daha işlendiğinde görünüm yeni talebi de
gösterir, snapshot göstermez; ikisine de `add` → `UnsupportedError`.

</details>

### Alıştırma 3 · `@immutable` ama içi değişen liste (zor)

04 (metadata) ile birleştir. `@immutable final class LeakyPlaylist` yaz (tek alan:
`final List<String> trackIds`): analyzer hiçbir şey demez, ama kaynak listeyi değiştirince
playlist de değişir: bunu testle göster. Sonra `Playlist`'i düzelt: liste kopyalanıp
salt-okunur olsun, `==`/`hashCode` içerik (ve sıra) üzerinden, birbiriyle uyumlu olsun
(iki eşit playlist bir `Set`'te tek eleman), `withTrack(id)` **yeni** bir playlist dönsün
ve sonucu kullanılmadan çağrılırsa analyzer uyarsın.

**İpucu:** 04'teki `@immutable`/`@useResult` tablosu ("tüm instance alanları `final`": liste
içeriğinden söz etmez) ve bu reference'ın "Katmanlarda" bölümündeki `Order` entity'si
([do-override-hashcode-if-you-override](https://dart.dev/effective-dart/design#do-override-hashcode-if-you-override)).

<details><summary>Çözüm</summary>

<!-- snippet: 05_collection/practice/ex3_playlist -->
```dart
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Passes the analyzer, yet whoever holds the source list can still change it.
@immutable
final class LeakyPlaylist {
  const LeakyPlaylist(this.trackIds);
  final List<String> trackIds;
}

@immutable
final class Playlist {
  Playlist(Iterable<String> trackIds) : trackIds = List.unmodifiable(trackIds);
  final List<String> trackIds;

  static const _tracksEquality = ListEquality<String>();

  @useResult
  Playlist withTrack(String id) => Playlist([...trackIds, id]);

  @override
  bool operator ==(Object other) =>
      other is Playlist && _tracksEquality.equals(other.trackIds, trackIds);

  @override
  int get hashCode => _tracksEquality.hash(trackIds);
}
```

`final` alan **referansı** sabitler, listenin içeriğini değil. `List.unmodifiable` kopyası
hem dışarıdaki kaynağın değişikliğinden hem `trackIds.add(...)`'ten korur. `@useResult`,
`playlist.withTrack(id);` gibi sonucu kullanılmayan çağrıyı raporlar.

</details>

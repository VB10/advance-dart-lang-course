# Çekim notları

Her özellik aynı döngü: **Aç** (tek dosya, başında prompt yazıyor) → **Söyle** (2 cümle) → izleyiciye **"kendi projende şu promptla yap"** de →
**Kıyasla** (Kabul satırı). Skill çıktısı birebir aynı olmaz; canlıdan önce promptu kendi projende bir kez dene.

Hazırlık: `dart pub get` · `dart run dartadvance_tool:dartadvance verify --all`. Dosyalar `examples/lib/NN_*/`, testler `examples/test/NN_*/`;
test: `cd examples && dart test test/NN_*`. Konu sırası ve gerekçesi: [KONULAR.md](KONULAR.md).
Bölüm sonunda kural dosyasındaki **Pekiştirme** iki alıştırmasını ver; çözümü sonraki bölümün başında skill ile birlikte yap.


---

## Bölüm 01 · Built-in types

**Neden:** Dart'ın temel tipleri sessiz hatalara açıktır (metin uzunluğu, bölme, değişmezlik); bu konu UI'da gösterilen metin, State'teki sayaçlar ve Domain sabitleri katmanlarında bu hataları önler.

### 1. Grapheme uzunluğu (`package:characters`)
- **Aç:** `examples/lib/01_builtin_types/grapheme_length.dart`
- **Söyle:** `String.length` UTF-16 kod birimi sayar; kullanıcının gördüğü karakter için `characters` kullanılır.
- **Tuzak:** `'👋🏽'.length` 4'tür, `substring` emojiyi ortadan bölüp yalnız bir surrogate bırakır (test: "substring by code units splits...").
- **İzleyiciye prompt:** "Projemde kullanıcıya görünen metni `length` ya da `substring` ile sayan veya kesen yerleri bul, `characters` ile düzelt, her biri için test yaz."
- **Kıyasla:** `length`/`runes`/`substring` kullanılmaz; `'👨‍👩‍👦'` 1 karakter sayılır; `dart analyze` temiz.

### 2. Tamsayı bölme ve kalan
- **Aç:** `examples/lib/01_builtin_types/integer_division.dart`
- **Söyle:** `~/` `int` döndürür ve sıfıra doğru keser; `%` asla negatif olmaz, `remainder` bölünenin işaretini korur.
- **Tuzak:** `-7 ~/ 2` değeri -3'tür (Python'daki gibi -4 değil) ve `(-1).remainder(5)` -1 verirken `-1 % 5` 4 verir (testler: "~/ truncates toward zero...", "% is never negative...").
- **İzleyiciye prompt:** "Projemde `/` sonucunu `toInt()`/`ceil()` ile tamsayıya çeviren ve negatif değerde `%` kullanan yerleri bul, `~/` ve `remainder` ile düzelt, test yaz."
- **Kıyasla:** `double` dönüşümü kalmaz; `-7 ~/ 2` -3, `(-1) % 5` 4, `(-1).remainder(5)` -1 testle doğrulanır; `dart analyze` temiz.

### 3. `final` / `const` / `late final`
- **Aç:** `examples/lib/01_builtin_types/variable_kinds.dart`
- **Söyle:** `final` bir kez atanır ama nesne değişebilir; `const` derleme zamanı sabiti ve derin değişmezdir; `late final` ilk okumada hesaplanır.
- **Tuzak:** `final` liste `add` kabul eder, `const` liste `UnsupportedError` fırlatır (test: "a final list can still be mutated...").
- **İzleyiciye prompt:** "Projemde değişmemesi gereken listeleri ve her okumada yeniden hesaplanan getter'ları bul, `const` ve `late final` ile düzelt, her biri için test yaz."
- **Kıyasla:** sabit liste `add`'de `UnsupportedError` verir; `late final` alanın hesaplama sayacı iki okumadan sonra 1; `dart analyze` temiz.

### 4. Wildcard `_` ve null-aware cascade (3.7)
- **Aç:** `examples/lib/01_builtin_types/wildcards_and_null_aware.dart`
- **Söyle:** `_` kullanılmayan değeri yok sayar ve artık birden fazla olabilir; `?..` cascade'i yalnızca alıcı null değilse çalıştırır; `...?` null listeyi boş sayar.
- **Tuzak:** `cart?..note = x` null alıcıda null döner, yeni nesne üretmez (test: "?.. skips the cascade on null...").
- **İzleyiciye prompt:** "Projemde `if (x != null)` ile null kontrolü yapıp atama veya liste birleştirme yapan yerleri bul, `?..` ve `...?` ile sadeleştir, her biri için test yaz."
- **Kıyasla:** null girdide sonuç null, null liste boş sayılır; kullanılmayan parametreler `_` olur; `dart analyze` temiz.


---

## Bölüm 02 · Typedefs

**Neden:** Flutter'da `ValueChanged`, `FormFieldValidator`, `Map<String, dynamic>` her yerde; typedef'in yeni tip yaratmadığını bilmeden ID karışıklıkları sessizce derlenir.

### 1. Fonksiyon typedef'i: mapper ve validator (her sürüm)
- **Aç:** `examples/lib/02_typedefs/function_typedefs.dart`
- **Söyle:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.
- **Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz. Düz fonksiyon `isA<Mapper<...>>()` ile doğrulanır.
- **İzleyiciye prompt:** "Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback ve validator tiplerini bul, `typedef` ile adlandır, her biri için test yaz."
- **Kıyasla:** Her tekrar eden imza tek bir typedef'e iner; somut fonksiyonlar düz fonksiyon olarak verilir; `isA<Mapper<...>>()` / `isA<Validator<String>>()` geçer; inline ve typedef'li sürüm aynı sonucu verir; `dart analyze` temiz.

### 2. Fonksiyon olmayan typedef: Json ve generic alias (2.13)
- **Aç:** `examples/lib/02_typedefs/json_alias.dart`
- **Söyle:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir.
- **Tuzak:** Alias orijinal tiple birebir aynıdır (`Json == Map<String, Object?>`); `dynamic` değil `Object?` kullan, yoksa `strict-casts` bile seni koruyamaz. JSON sayısı `int` de gelebilir: `(x as num).toDouble()`.
- **İzleyiciye prompt:** "Projemde `Map<String, dynamic>` tipini tekrar eden Data katmanı yerlerini bul, `typedef` alias ile düzelt, her biri için test yaz."
- **Kıyasla:** Test `Json == Map<String, Object?>` ve generic alias eşitliğini doğrular; `int` ve `double` değerler kabul edilir; `dynamic` kalmaz; Domain'e `Json` sızmaz.

### 3. Typedef yeni tip değildir: ID için extension type (3.3)
- **Aç:** `examples/lib/02_typedefs/alias_not_new_type.dart`
- **Söyle:** `typedef UserIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder.
- **Tuzak:** `UserIdAlias == int` ve alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder; `UserId` alan fonksiyona `int` vermeyi analyzer reddeder (testlenemez, yalnızca prose).
- **İzleyiciye prompt:** "Projemde `typedef X = int` gibi alias'la ID ya da birim tipi tanımlayan yerleri bul, `extension type` ile dönüştür, her biri için test yaz."
- **Kıyasla:** Test eski alias'ın `int`'e eşit olduğunu ve yanlış değerin kabul edildiğini gösterir; extension type `.value` ile sarılı değeri verir; yanlış ID için derleme hatasının analyzer tarafından verildiği yorumda yazılıdır.


---

## Bölüm 03 · Class modifiers

**Neden:** Flutter'da state ve repository tiplerini kapatmak, yeni bir durum eklendiğinde derleyicinin seni uyarmasını sağlar; `_` ile yazılmış switch bu uyarıyı sessizce yutar.

### 1. sealed + exhaustive switch (3.0)
- **Aç:** `examples/lib/03_class_modifiers/sealed_order_state.dart`
- **Söyle:** `sealed` kök doğrudan construct edilemez, alt tipleri aynı library'de kapalıdır; `switch` tüm alt tipleri kapsamazsa analyzer reddeder.
- **Tuzak:** `_` eklersen yeni alt tip eklendiğinde switch sessizce ona düşer, hata vermez; `_` yazma. `sealed` geçişli değildir: alt tipi `final` yapmazsan dışarıdan extend edilir (analyzer buna itiraz etmez).
- **İzleyiciye prompt:** "Projemde durumları `_` ya da default ile eşleyen switch'leri bul, `sealed` aile + `_`'siz switch ile düzelt, her biri için test yaz."
- **Kıyasla:** Kök `sealed`, her alt tip `final class`, projedeki switch'lerde `_` yok; test her alt tip için ayrı metni doğrular ve `dart analyze` temiz.

### 2. final (3.0)
- **Aç:** `examples/lib/03_class_modifiers/final_money.dart`
- **Söyle:** `final class` başka library'den construct edilir ama extend / implement edilemez (analyzer reddeder).
- **Tuzak:** `final` aynı library'de hiçbir şeyi kısıtlamaz ve `implements`'i de kapatır; mock gereken sınıfı `final` yaparsan test yazamazsın (bkz. bölüm 3). Testte yalnızca "dışarıdan construct edilir ve eşitlik çalışır" kanıtlanır; extend/implement reddi analyzer'dadır.
- **İzleyiciye prompt:** "Projemde alt tiplenmemesi gereken değer sınıflarını bul, `final class` + `==`/`hashCode` ile düzelt, her biri için test yaz."
- **Kıyasla:** Bulunan sınıflar `final`, `==` ve `hashCode` birlikte override edilmiş; test eşit/eşit olmayan durumları doğrular.

### 3. interface vs base (3.0)
- **Aç:** `examples/lib/03_class_modifiers/interface_vs_base.dart`
- **Söyle:** `abstract interface class` dışarıda yalnızca `implements` edilir; `abstract base class` yalnızca `extends` edilir ve **base transitivity** uygulanır: alt tip `base`, `final` veya `sealed` olmak zorunda (düz `class` analyzer'da hata).
- **Tuzak:** `base` sınıfı başka library'de düz `class` ile extend edemezsin; alt tipi `final class` yaz (testteki `_CountingRepository`). Interface'i ise test library'sinde sahte olarak implement edebilirsin (`_FakeRepository`).
- **İzleyiciye prompt:** "Projemde repository sözleşmelerini ve ortak mantıklı tabanları bul, `abstract interface class` / `abstract base class` ile ayır, her biri için test yaz."
- **Kıyasla:** Test, interface'i `implements` ile sahteler; base'i `final class ... extends` ile kullanır; paylaşılan mantık test edilir.

### 4. mixin class (3.0)
- **Aç:** `examples/lib/03_class_modifiers/mixin_class.dart`
- **Söyle:** `mixin class` hem `with` hem `extends` ile kullanılır; `abstract mixin class` ise construct edilemez.
- **Tuzak:** Mixin gibi kullanılan sınıfın `extends` / `implements` yapması ya da constructor parametresi olması `mixin class` bildirimini geçersiz kılar (analyzer reddeder); state'i private tut, dışarıya kopya ver (`List.unmodifiable`).
- **İzleyiciye prompt:** "Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları bul, `mixin class` ile birleştir, her biri için test yaz."
- **Kıyasla:** Test aynı sınıfı `with` ve `extends` ile kullanır; dışarıdan dönen liste değiştirilemez.


---

## Bölüm 04 · Libraries, part ve metadata

**Neden:** Flutter'da `@immutable`, `@protected` ve `part` her yerde görünür, ama `_` ve annotation'ların neyi gerçekten korumadığını bilmeden yanlış güvenlik varsayımı yapılır.

### 1. Library seviyesinde gizlilik (her sürüm)
- **Aç:** `examples/lib/04_libraries_metadata/library_privacy.dart`
- **Söyle:** `_` ile başlayan isim sınıfa değil library'ye özeldir; aynı dosyadaki her sınıf görür, başka dosya (test dahil) göremez.
- **Tuzak:** `WalletAuditor` aynı dosyada olduğu için `Wallet._balanceCents` alanını okuyup yazar (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde `_` alanına aynı dosyadaki başka sınıfın eriştiği yerleri bul, library gizliliği kuralıyla ayır veya bilerek kabul et, her biri için test yaz."
- **Kıyasla:** Aynı dosyadan `_` erişimi ya ayrı dosyaya taşınarak derleme hatasına çevrildi ya da bilerek bırakıldı ve testle sabitlendi; `dart analyze` temiz.

### 2. `part` / `part of` (2.0)
- **Aç:** `examples/lib/04_libraries_metadata/part_files/order_builder.dart`
- **Söyle:** Bir library'yi birden çok dosyaya böler; part dosyası library'nin private isimlerini ve import'larını paylaşır.
- **Tuzak:** Part'taki `_Line` tipi ve `Queue` (ana dosyanın `dart:collection` import'u) ana dosyada kullanılır; part import'suz çalışır (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde elle yazılmış sınıfı `part` ile böldüğüm yerleri bul, `part of` string URI ve import kurallarıyla düzelt, her biri için test yaz."
- **Kıyasla:** Part dosyasında `import` yok, `part of '<dosya>.dart';` string URI ile; el yazımı bölünmeler küçük library'lere ayrıldı veya gerekçelendirildi; davranış testle doğrulanır.

### 3. `@immutable` ve `@useResult` (package:meta)
- **Aç:** `examples/lib/04_libraries_metadata/result_annotations.dart`
- **Söyle:** `@immutable` sınıfta non-final alanı, `@useResult` ise sonucu atılan çağrıyı analyzer'a raporlatır.
- **Tuzak:** `add` orijinali değiştirmez, yeni `Money` döner; sonucu atmak sessizce hiçbir şey yapmaz (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde değer nesnesi sınıfları ve sonucu atılabilen metotları bul, `@immutable` ve `@useResult` ekle, her biri için test yaz."
- **Kıyasla:** Bulunan sınıflarda tüm alanlar final ve `const` constructor var; `@useResult` metotlarında sonucu atan satır analyzer'da raporlanır; test orijinalin değişmediğini doğrular.

### 4. `@protected` ve `@mustCallSuper` (package:meta)
- **Aç:** `examples/lib/04_libraries_metadata/protected_members.dart`
- **Söyle:** `@protected` üyeyi yalnızca alt sınıflara ayırır; `@mustCallSuper` override'ın `super` çağırmasını zorlar.
- **Tuzak:** Alt sınıf `emit`'i kendi içinde serbestçe çağırır; `dispose` override'ı `super.dispose()` çağırmazsa dinleyiciler temizlenmez (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde taban store sınıflarında alt sınıfa ait metotları ve dispose zincirini bul, `@protected` ve `@mustCallSuper` ekle, her biri için test yaz."
- **Kıyasla:** Dışarıdan çağrı ve `super.dispose()` eksik override analyzer uyarısı verir; test alt sınıf üzerinden durum değişimini ve temizliği doğrular.


---

## Bölüm 05 · Koleksiyonlar

**Neden:** Flutter'da boş listede `first` ile çöken ekranlar, yerinde `sort()` ile bozulan state ve identity `==` yüzünden gereksiz rebuild'ler en sık koleksiyon hatalarıdır.

### 1. Core mu paket mi (3.0)
- **Aç:** `examples/lib/05_collection/first_or_null.dart`
- **Söyle:** `firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull` core'da; predicate'li `firstWhereOrNull` hâlâ `package:collection`'da.
- **Tuzak:** `first`/`firstWhere` boşta `StateError` atar (test: "first and firstWhere throw StateError ..."); `singleOrNull` iki veya daha fazla elemanda da null döner, hata vermez (test: "singleOrNull is null for zero and for two or more elements").
- **İzleyiciye prompt:** "Projemde `first`/`firstWhere`/`try-catch StateError` ile arama yapan yerleri bul, `firstOrNull`/`firstWhereOrNull` ile düzelt, her biri için test yaz."
- **Kıyasla:** Boş listede ve eşleşme yokta exception atmıyor; `first`/`firstWhere`/`StateError` yakalama kalmadı; `firstOrNull` için paket import'u yok, predicate'li arama için var; her değişiklik için test, `dart analyze` temiz.

### 2. Gruplama ve sıralama (package:collection)
- **Aç:** `examples/lib/05_collection/group_and_sort.dart`
- **Söyle:** `groupListsBy`, `sortedBy`/`sortedByCompare`, `mapIndexed`, `compareNatural`.
- **Tuzak:** `sort()` girdi listesini değiştirir (test: "sort() mutates the input ..."); `sort()` yerinde çalışır ve `void` döner; `sorted*` yeni liste verir, kaynak değişmez (test: "sorting helpers return a new list and leave the source alone").
- **İzleyiciye prompt:** "Projemde `list.sort()` ile yerinde sıralayan veya elle gruplayan yerleri bul, `sortedBy`/`groupListsBy` ile düzelt, her biri için test yaz."
- **Kıyasla:** Gruplar ilk görülme sırasında; kaynak liste `sort()` ile değişmiyor (yerinde sıralama kalmadı); her değişen yer için test, `dart analyze` temiz.

### 3. İçerik eşitliği
- **Aç:** `examples/lib/05_collection/content_equality.dart`
- **Söyle:** `List`/`Map`/`Set` `==` ile identity karşılaştırır; içerik için `ListEquality`, `DeepCollectionEquality` kullanılır.
- **Tuzak:** `Map`/`List` üzerinde `==` aynı içerikte bile false'tur (test: "== on maps is false ..."); `ListEquality<List<int>>` iç listeleri identity ile karşılaştırır; iç içe veri için `DeepCollectionEquality` gerekir (test: "ListEquality without deep support ..."). `hashCode` da aynı Equality ile üretilmeli.
- **İzleyiciye prompt:** "Projemde `List`/`Map` alanlı sınıflarda `==`/`hashCode` yazan yerleri bul, `DeepCollectionEquality` ile düzelt, her biri için test yaz."
- **Kıyasla:** `==` ve `hashCode` aynı `DeepCollectionEquality` örneğini kullanıyor; aynı içerikli iki ayrı nesne için eşitlik ve hash testi geçiyor; koleksiyon alanlarında çıplak `==` kalmadı.

### 4. Değişmez state: kopya mı görünüm mü
- **Aç:** `examples/lib/05_collection/immutable_state.dart`
- **Söyle:** `List.unmodifiable` kopya alır; `UnmodifiableListView` canlı, salt-okunur görünümdür.
- **Tuzak:** Listeyi doğrudan saklamak çağıranın değişikliğini state'e sızdırır (test: "the leaky state follows the caller list"); `UnmodifiableListView` kopya değildir; sahibi listeyi değiştirirse görünüm de değişir (test: "the view rejects changes but follows the owner").
- **İzleyiciye prompt:** "Projemde state/ViewModel'de `List` alanını doğrudan saklayan ya da açan yerleri bul, `List.unmodifiable`/`UnmodifiableListView` ile düzelt, test yaz."
- **Kıyasla:** State'e verilen kaynak liste sonradan değişse state değişmiyor; dışarı açılan listeye `add` `UnsupportedError` atıyor; her değişen yer için test, `dart analyze` temiz.

### 5. Öncelik kuyruğu
- **Aç:** `examples/lib/05_collection/task_scheduler.dart`
- **Söyle:** `HeapPriorityQueue` en küçük (karşılaştırıcıya göre ilk) elemanı verir.
- **Tuzak:** Eşit öncelikte FIFO garanti edilmez (test: "priority-only comparator does not keep FIFO on ties"); `sequence` alanı ile karşılaştırıcıya ikinci ölçüt eklenir (test: "runs the highest priority first and FIFO within a priority").
- **İzleyiciye prompt:** "Projemde öncelikli işi `sort()` ya da tek ölçütlü karşılaştırıcıyla sıralayan yerleri bul, `HeapPriorityQueue` + sıra numarası ile düzelt, test yaz."
- **Kıyasla:** Karşılaştırıcı önce öncelik sonra sıra numarasına bakıyor; aynı öncelikte geliş sırası testle kanıtlı; `drain()` sonrası kuyruk boş.


---

## Bölüm 06 · Event loop ve Future

**Neden:** Sıralı `await` ve sessizce yutulan ateşle-unut hatalar Flutter'da yavaş ekran ve görünmeyen hata olarak karşına çıkar.

### 1. Event loop sırası (her sürüm)
- **Aç:** `examples/lib/06_event_loop_future/event_loop_order.dart`
- **Söyle:** Önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu (`Timer.run`, `Future()`) çalışır.
- **Tuzak:** `async` fonksiyon ilk `await`'e kadar senkron çalışır; çağıran, `await` etmese bile o kısmı hemen görür.
- **İzleyiciye prompt:** "Projemde `scheduleMicrotask`, `Timer.run` veya `Future(...)` ile sıra varsayan yerleri bul, event loop sırasına göre düzelt, her biri için test yaz."
- **Kıyasla:** Test sırayı `sync → microtask → event` olarak doğrular; sıra varsayımı `await` ile açık hale gelmiş; `dart analyze` temiz.

### 2. Future.wait ve record `.wait` (3.0)
- **Aç:** `examples/lib/06_event_loop_future/parallel_wait.dart`
- **Söyle:** Bağımsız istekleri aynı anda başlatıp bekler; record `.wait` her alanın tipini korur.
- **Tuzak:** `Future.wait` sonuçları verilen sırayla döner ve yalnız ilk hatayı bildirir; başarılı değerlere `ParallelWaitError.values` ile ulaşılır.
- **İzleyiciye prompt:** "Projemde birbirine bağlı olmayan `await`'leri art arda yazan repository yerlerini bul, record `.wait` ile paralel yap, her biri için test yaz."
- **Kıyasla:** Test bağımsız çağrıların birlikte başladığını (başlangıç sırası) ve kısmi başarıyı (`values`) kapsar; `dart analyze` temiz.

### 3. timeout ve Completer (her sürüm)
- **Aç:** `examples/lib/06_event_loop_future/timeout_completer.dart`
- **Söyle:** `Completer` callback API'sini `Future`'a çevirir; `.timeout` bekleme süresini sınırlar.
- **Tuzak:** `timeout` kaynak future'ı iptal etmez; geç gelen sonuç yok sayılır, `Completer` ikinci kez tamamlanırsa `StateError` atar (`isCompleted` ile koru).
- **İzleyiciye prompt:** "Projemde callback tabanlı eski API'leri, süresiz bekleyen çağrıları bul, `Completer` ile Future'a çevir, `timeout` ile sınırla, her biri için test yaz."
- **Kıyasla:** Test sessiz SDK'de `TimeoutException`'ı, çift callback'te yalnız ilk sonucu doğrular; süresiz bekleyen çağrı kalmaz.

### 4. unawaited, ignore ve ateşle-unut hatalar (unawaited 2.15, ignore 2.14)
- **Aç:** `examples/lib/06_event_loop_future/fire_and_forget.dart`
- **Söyle:** `unawaited` "bilerek beklemiyorum" der; `ignore()` hatayı da yutar.
- **Tuzak:** `unawaited` hatayı yutmaz; hata yine işlenmemiş (unhandled) olur, `ignore()` ise sessizce yutar.
- **İzleyiciye prompt:** "Projemde beklenmeden çağrılan Future'ları (`unawaited`) bul, hatasını `catchError` ile ele alacak şekilde düzelt, her biri için test yaz."
- **Kıyasla:** Test hatanın zone'a sızmadığını ve `catchError` ile raporlandığını doğrular; `dart analyze` temiz.


---

## Bölüm 07 · Streams

**Neden:** Flutter'da sızan `listen`, ikinci dinleyicide `StateError` ve dinlenmeden açılan kaynak en sık görülen stream hatalarıdır; bu beş desen hepsini kapatır.

### 1. Single-subscription ve broadcast (2.x)
- **Aç:** `examples/lib/07_streams/stream_kinds.dart`
- **Söyle:** Varsayılan stream tek dinleyici kabul eder; `StreamController.broadcast()` çok dinleyici kabul eder ve dinleyicisiz olayları düşürür.
- **Tuzak:** Single-subscription'a ikinci `listen` `StateError` atar, ilk abonelik cancel edilse bile (test kanıtlıyor).
- **İzleyiciye prompt:** "Projemde aynı stream'i birden çok yerde dinleyen yerleri bul, single-subscription/broadcast ayrımıyla düzelt, her biri için test yaz."
- **Kıyasla:** Çoklu dinlenen akış `isBroadcast`; iki dinleyici aynı olayı aldı; ikinci `listen` `StateError` atmıyor; mevcut testler ve `dart analyze` yeşil.

### 2. `async*` generator (2.x)
- **Aç:** `examples/lib/07_streams/async_generator.dart`
- **Söyle:** `async*` + `yield` ile tembel stream üretir; dinleyici durunca `finally` çalışır ve sonraki sayfa istenmez.
- **Tuzak:** `take(3)` gibi erken durma sonraki sayfayı çağırmaz ve `finally` bir kez çalışır (test kanıtlıyor).
- **İzleyiciye prompt:** "Projemde sayfaları hepsini çekip listeye dönen yerleri bul, `async*` ile tembel Stream'e çevir, erken iptalde temizliği de kapsayan test yaz."
- **Kıyasla:** Dönüştürülen her yerde sayfalar sırayla geldi; `take(n)` sonrası fazladan sayfa istenmedi; temizlik bir kez çalıştı; analyze temiz.

### 3. StreamController callback'leri (2.x)
- **Aç:** `examples/lib/07_streams/controller_callbacks.dart`
- **Söyle:** `onListen`, `onPause`, `onResume`, `onCancel` ile kaynak yalnız birisi dinlerken çalışır.
- **Tuzak:** Dinleyici gelene kadar `onListen` çalışmaz; kaynak kapalı kalır (test kanıtlıyor).
- **İzleyiciye prompt:** "Projemde Timer, soket veya sensörü stream dinlenmeden başlatan yerleri bul, `StreamController` onListen/onCancel ile düzelt, her biri için test yaz."
- **Kıyasla:** Dinleyici gelmeden kaynak açılmıyor; log sırası `onListen`, `onPause`, `onResume`, `onCancel`; cancel sonrası yeni olay yok.

### 4. `StreamTransformer` (2.x)
- **Aç:** `examples/lib/07_streams/message_transformer.dart`
- **Söyle:** `transform()` ile stream'i yeniden biçimlendirir; `fromHandlers` olay başına sink'e 0..n çıktı yazar.
- **Tuzak:** Sink'e eklemediğin olay sessizce düşer; kırpılan boş mesaj çıktıda yoktur (test kanıtlıyor).
- **İzleyiciye prompt:** "Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul, `StreamTransformer.fromHandlers` ile dönüştür, her biri için test yaz."
- **Kıyasla:** Dönüşen her akışta davranış aynı: beklenen olaylar sırayla geldi, süzülenler düştü; testler yeşil.

### 5. Dinleyen state sınıfı ve dispose (2.x)
- **Aç:** `examples/lib/07_streams/price_watcher.dart`
- **Söyle:** Subscription alanda tutulur, `dispose()`'da `await cancel()` ve `null` yapılır; düz Dart, kütüphane yok.
- **Tuzak:** `dispose` sonrası gelen olay state'i değiştirmez; `start` iki kez çağrılsa tek abonelik olur (`??=`) (test kanıtlıyor).
- **İzleyiciye prompt:** "Projemde stream dinleyip dispose'da cancel etmeyen state'leri bul, subscription'ı alanda tutup `await cancel()` ile düzelt, her biri için test yaz."
- **Kıyasla:** Bulunan her state sınıfında `dispose` sonrası kaynağın `onCancel`'ı çalıştı; geç gelen olay state'i değiştirmedi.


---

## Bölüm 08 · package:async

**Neden:** Arama kutusu, config yükleme ve stream okuma kodları sessizce eski yanıtı gösterir ya da aynı işi tekrar tekrar yapar; `package:async` bunları tek satırda çözer.

### 1. CancelableOperation (2.x)
- **Aç:** `examples/lib/08_async_package/cancelable_search.dart`
- **Söyle:** Bir `Future`'ı iptal edilebilir sarar; iptalde sonuç atılır, `valueOrCancellation()` `null` döner.
- **Tuzak:** Naif sürümde yavaş eski cevap en son gelip ekranı ezer. İptal alttaki isteği durdurmaz, yalnızca sonucunu yok sayar; tamamlanmış işte `cancel()` bir şey yapmaz (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde her tuş vuruşunda istek atan arama yerlerini bul, CancelableOperation (package:async) ile son sorgu kazansın, her biri için test yaz."
- **Kıyasla:** Eski çağrı `null`, yeni çağrı değer döner; eski cevabın geç gelmesi sonucu ezmez; `hide Result` kullanılır; `dart analyze` temiz.

### 2. AsyncMemoizer (2.x)
- **Aç:** `examples/lib/08_async_package/async_memoizer.dart`
- **Söyle:** Async işi bir kez çalıştırır, sonraki/eşzamanlı çağıranlar aynı future'ı alır.
- **Tuzak:** Hata da sonsuza kadar saklanır, tekrar denenmez (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde tekrar tekrar yüklenen config/liste yerlerini bul, AsyncMemoizer (package:async) ile tek seferlik yap, her biri için test yaz."
- **Kıyasla:** Eşzamanlı ve sonraki çağrılarda yükleyici sayacı 1 kalır; `hasRun` doğrulanır.

### 3. AsyncCache (2.x)
- **Aç:** `examples/lib/08_async_package/async_cache.dart`
- **Söyle:** Sonucu süre boyunca taze tutar; `invalidate()` ile sıfırlanır.
- **Tuzak:** Başarısız istek de TTL boyunca önbellekte kalır (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde kur/fiyat/stok gibi veriyi her okumada çeken yerleri bul, AsyncCache (package:async) ile TTL'li önbelleğe al, her biri için test yaz."
- **Kıyasla:** TTL içinde tek fetch; `invalidate` sonrası ikinci fetch; `Duration.zero` ile her seferinde yenilenir.

### 4. StreamQueue (2.x)
- **Aç:** `examples/lib/08_async_package/stream_queue.dart`
- **Söyle:** Stream'i pull-based okutur: `next`, `take(n)`, `peek`, `hasNext`, `rest`.
- **Tuzak:** Stream biterse `next` `StateError` fırlatır; önce `hasNext` sor, işin bitince `cancel()` et (testte kanıtlı).
- **İzleyiciye prompt:** "Projemde başlık+gövde sırayla okunan stream parse yerlerini bul, StreamQueue (package:async) ile düzelt, her biri için test yaz."
- **Kıyasla:** Başlıktaki sayı kadar öğe döner; `finally` içinde `queue.cancel()` vardır; tek-abonelikli stream'e ikinci `listen` yoktur.

### 5. StreamGroup ve StreamSplitter (2.x)
- **Aç:** `examples/lib/08_async_package/stream_group.dart`
- **Söyle:** `StreamGroup.merge` birçok kaynağı tek stream yapar; `StreamSplitter` tek-abonelikli stream'i birden çok tüketiciye tüm olaylarla verir.
- **Tuzak:** `asBroadcastStream` geç dinleyiciye eski olayları vermez, splitter verir (testte kanıtlı); merge ancak tüm kaynaklar kapanınca kapanır.
- **İzleyiciye prompt:** "Projemde aynı stream'i iki kez dinleyen yerleri bul, StreamSplitter ve StreamGroup (package:async) ile düzelt, her biri için test yaz."
- **Kıyasla:** Splitter'ın her kolu tüm olayları görür (naif çift dinleme `StateError` verirdi); merge iki kaynaktan da olay iletir, ikisi kapanınca biter.


---

## Bölüm 09 · Isolates

**Neden:** Flutter'da JSON/parse işi frame kaçırtır; `compute` ve `Isolate.run` closure'ın ne yakaladığına bakmadan yazılınca sessizce yavaşlar ya da patlar.

### 1. Eşikli ağır parse: `Isolate.run` (2.19)
- **Aç:** `examples/lib/09_isolates/decode_orders.dart`
- **Söyle:** Büyük gövde `Isolate.run` ile çözülür, küçük gövde inline kalır.
- **Tuzak:** `Isolate.run` içinde fırlayan hata aynı tipte ana isolate'e gelir (`FormatException` testte tipiyle yakalanır); `Result`'a çevirmeyi RepositoryImpl yapar. Parse fonksiyonu top-level ve saf olmalı.
- **İzleyiciye prompt:** "Projemde ana isolate'te büyük JSON/CSV/GPX çözen yerleri bul, eşikli `Isolate.run` ile taşı, her biri için test yaz."
- **Kıyasla:** Her bulunan yerde eşik 1 ve büyük eşik aynı sonucu verir; bozuk girdide `FormatException` tipiyle fırlar; parse fonksiyonu top-level ve saf; `dart analyze` temiz.

### 2. Ne gönderilir, closure ne yakalar (2.19)
- **Aç:** `examples/lib/09_isolates/capture_rules.dart`
- **Söyle:** Mesajlar kopyalanır, global değişken isolate'te ayrı kopyadır, bazı nesneler hiç gönderilemez.
- **Tuzak:** `ReceivePort`, `Socket`, `Pointer`, `Finalizer` gibi nesneyi yakalayan closure `ArgumentError` ile patlar (testli). API dokümanı (dartbug 36983): closure gerekenden fazla durum yakalayabilir; instance metodu içinde closure yazmak `this`'i taşıyabilir. Çözüm: gereken durumu parametre alan ayrı bir fonksiyonda closure kur (testi yok, API notudur).
- **İzleyiciye prompt:** "Projemde `Isolate.run`/`compute` closure'larını bul, ne yakaladıklarını ve global duruma bağımlılığı `dart:isolate` kurallarıyla düzelt, her biri için test yaz."
- **Kıyasla:** Her closure yalnızca gereken parametreyi yakalar; çağıranın verisi değişmez (testli); global mutable duruma bağımlılık kalmaz; `ReceivePort`/`Socket` yakalayan closure yok.

### 3. Sağlam worker: ports, hata ve çıkış (3.0)
- **Aç:** `examples/lib/09_isolates/price_worker.dart`
- **Söyle:** Tekrar eden işi, `onExit` ve ports ile kurulan uzun ömürlü bir isolate'e verir.
- **Tuzak:** Ölü worker asla yanıt vermez; isteği `exited` ile yarıştırmazsan çağıran sonsuza kadar bekler. Worker'daki hata `RemoteError` değeri olarak döner; `close()` sonrası istek `StateError` verir (üçü de testli).
- **İzleyiciye prompt:** "Projemde her mesaj/satır için tekrar tekrar isolate açan yerleri bul, ports ve `onExit` ile uzun ömürlü worker'a çevir, her biri için test yaz."
- **Kıyasla:** Her dönüştürülen yerde sıralı ve eşzamanlı istekler doğru cevaplanır; hata `RemoteError` gelir; `close()` sonrası `exited` tamamlanır ve yeni istek `StateError` verir.

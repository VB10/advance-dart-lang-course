# Çekim notları

Her bölüm aynı döngü: **Aç** (tek dosya) → **Söyle** (2 cümle) → **Skill'e ver** (ikinci pencere, prompt aşağıda) → **Kıyasla** (Kabul satırı).
Skill çıktısı her seferinde birebir aynı olmaz; canlıdan önce promptu bir kez dene.

Hazırlık: `dart pub get` · `dart run dartadvance_tool:dartadvance verify --all` · demo projesi için `dart create -t console demo_app`
(gerekirse `dart pub add collection async characters meta`). Dosyalar `examples/lib/NN_*/`, testler `examples/test/NN_*/`;
testi çalıştır: `cd examples && dart test test/NN_*`.

Her bölümün sonunda kural dosyasındaki **Pekiştirme** iki alıştırmasını ver; çözümü sonraki bölümün başında skill ile birlikte yap.


---

## Bölüm 01 · Built-in types

### 1. Grapheme uzunluğu (`package:characters`)
- **Aç:** `examples/lib/01_builtin_types/grapheme_length.dart`
- **Söyle:** `String.length` UTF-16 kod birimi sayar; kullanıcının gördüğü karakter için `characters` kullanılır.
- **Tuzak:** `'👋🏽'.length` 4'tür, `substring` emojiyi ortadan bölüp yalnız bir surrogate bırakır (test: "substring by code units splits...").
- **Skill'e ver:** "Bir ürün yorumu için 280 karakterlik sınır koyan `remainingCharacters(String review)` ve sınırı aşınca emoji bölmeden kesen `clipReview` yaz."
- **Kıyasla:** `length`/`runes`/`substring` kullanılmaz; `'👨‍👩‍👦'` 1 karakter sayılır; `dart analyze` temiz.

### 2. Tamsayı bölme ve kalan
- **Aç:** `examples/lib/01_builtin_types/integer_division.dart`
- **Söyle:** `~/` `int` döndürür ve sıfıra doğru keser; `%` asla negatif olmaz, `remainder` bölünenin işaretini korur.
- **Tuzak:** `-7 ~/ 2` değeri -3'tür (Python'daki gibi -4 değil) ve `(-1).remainder(5)` -1 verirken `-1 % 5` 4 verir (testler: "~/ truncates toward zero...", "% is never negative...").
- **Skill'e ver:** "Bir sepetteki ürünleri kutulara `boxSize` adetlik gruplayan `boxesNeeded(int items, int boxSize)` yaz; `double` ve `.ceil()` kullanma."
- **Kıyasla:** sonuç `int`; 0 ürün 0 kutu, 25 ürün ve 10'luk kutu 3 kutu verir; `dart analyze` temiz.

### 3. `final` / `const` / `late final`
- **Aç:** `examples/lib/01_builtin_types/variable_kinds.dart`
- **Söyle:** `final` bir kez atanır ama nesne değişebilir; `const` derleme zamanı sabiti ve derin değişmezdir; `late final` ilk okumada hesaplanır.
- **Tuzak:** `final` liste `add` kabul eder, `const` liste `UnsupportedError` fırlatır (test: "a final list can still be mutated...").
- **Skill'e ver:** "Bir `Invoice` sınıfı yaz: KDV oranı `const`, satırlardan hesaplanan `total` ilk okumada bir kez hesaplanan `late final` olsun."
- **Kıyasla:** hesaplama sayacı iki okumadan sonra 1; `const` liste değiştirilemez; `dart analyze` temiz.

### 4. Wildcard `_` ve null-aware cascade (3.7)
- **Aç:** `examples/lib/01_builtin_types/wildcards_and_null_aware.dart`
- **Söyle:** `_` kullanılmayan değeri yok sayar ve artık birden fazla olabilir; `?..` cascade'i yalnızca alıcı null değilse çalıştırır; `...?` null listeyi boş sayar.
- **Tuzak:** `cart?..note = x` null alıcıda null döner, yeni nesne üretmez (test: "?.. skips the cascade on null...").
- **Skill'e ver:** "Nullable bir `UserProfile?` alıp `?..` ile `displayName` atayan ve `(_, _)` kullanan bir `onTap` callback'i yazan küçük bir örnek üret."
- **Kıyasla:** null girdide sonuç null; `for (final _ in ...)` ve `(_, _)` derlenir; `dart analyze` temiz.


---

## Bölüm 02 · Typedefs

### 1. Fonksiyon typedef'i: mapper ve validator (her sürüm)
- **Aç:** `examples/lib/02_typedefs/function_typedefs.dart`
- **Söyle:** Bir fonksiyon imzasına isim verir; imzası uyan her fonksiyon o typedef'in örneğidir.
- **Tuzak:** Eski sözdizimi (`typedef T Name(S s)`) yasaktır; `typedef Name<S, T> = T Function(S s)` yaz. Düz fonksiyon `isA<Mapper<...>>()` ile doğrulanır.
- **Skill'e ver:** "Fatura Model'lerini Entity'lere çeviren generic bir `Mapper<S, T>` typedef'i, listeyi çeviren `mapAll` yardımcısı ve kupon alanı için `String? Function(String?)` tipinde bir validator typedef'i ile form state sınıfı yaz."
- **Kıyasla:** Somut mapper ve validator düz fonksiyon olarak verilir; `isA<Mapper<...>>()` / `isA<Validator<String>>()` geçer; liste sırası korunur; `dart analyze` temiz.

### 2. Fonksiyon olmayan typedef: Json ve generic alias (2.13)
- **Aç:** `examples/lib/02_typedefs/json_alias.dart`
- **Söyle:** `Map<String, Object?>` gibi uzun tiplere kısa isim verir, generic parametre alabilir.
- **Tuzak:** Alias orijinal tiple birebir aynıdır (`Json == Map<String, Object?>`); `dynamic` değil `Object?` kullan, yoksa `strict-casts` bile seni koruyamaz. JSON sayısı `int` de gelebilir: `(x as num).toDouble()`.
- **Skill'e ver:** "Kargo API'sinin Data katmanı için `Json` ve `JsonList` alias'ları, `Shipment` sınıfı, `fromJson`/`toJson` fonksiyonları ve `Map<String, List<Shipment>>` için generic bir `ByCity<T>` alias'ı yaz."
- **Kıyasla:** Test `Json == Map<String, Object?>` ve generic alias eşitliğini doğrular; `int` ve `double` ağırlık değerleri kabul edilir; `dynamic` yok.

### 3. Typedef yeni tip değildir: ID için extension type (3.3)
- **Aç:** `examples/lib/02_typedefs/alias_not_new_type.dart`
- **Söyle:** `typedef UserIdAlias = int` yalnızca isimdir; `int` kabul eden her yer onu kabul eder.
- **Tuzak:** `UserIdAlias == int` ve alias'lı fonksiyon ürün sayısı gibi sıradan bir `int`'i sessizce kabul eder; `UserId` alan fonksiyona `int` vermeyi analyzer reddeder (testlenemez, yalnızca prose).
- **Skill'e ver:** "Sipariş ID'si ve ürün ID'si için iki ayrı extension type yaz; ikisini de alias ile yapınca karışmanın derlendiğini, extension type ile analyzer'ın reddettiğini testle ve prose ile göster."
- **Kıyasla:** Test alias'ın `int`'e eşit olduğunu ve yanlış değerin kabul edildiğini gösterir; extension type `.value` ile sarılı değeri verir; yanlış ID için derleme hatasının analyzer tarafından verildiği yorumda yazılıdır.


---

## Bölüm 03 · Class modifiers

### 1. sealed + exhaustive switch (3.0)
- **Aç:** `examples/lib/03_class_modifiers/sealed_order_state.dart`
- **Söyle:** `sealed` kök doğrudan construct edilemez, alt tipleri aynı library'de kapalıdır; `switch` tüm alt tipleri kapsamazsa analyzer reddeder.
- **Tuzak:** `_` eklersen yeni alt tip eklendiğinde switch sessizce ona düşer, hata vermez; `_` yazma. `sealed` geçişli değildir: alt tipi `final` yapmazsan dışarıdan extend edilir (analyzer buna itiraz etmez).
- **Skill'e ver:** "Kargo takibi için bekliyor, yolda (kurye adıyla) ve teslim edildi (tarihle) durumlarını taşıyan bir sealed aile ve her durumu metne çeviren, `_` kullanmayan bir fonksiyon yaz."
- **Kıyasla:** Kök `sealed`, her alt tip `final class`, switch'te `_` yok; test her alt tip için ayrı metni doğrular.

### 2. final (3.0)
- **Aç:** `examples/lib/03_class_modifiers/final_money.dart`
- **Söyle:** `final class` başka library'den construct edilir ama extend / implement edilemez (analyzer reddeder).
- **Tuzak:** `final` aynı library'de hiçbir şeyi kısıtlamaz ve `implements`'i de kapatır; mock gereken sınıfı `final` yaparsan test yazamazsın (bkz. bölüm 3). Testte yalnızca "dışarıdan construct edilir ve eşitlik çalışır" kanıtlanır; extend/implement reddi analyzer'dadır.
- **Skill'e ver:** "Ürün profili için `Email` adında, geçersiz adresi constructor'da reddeden, değer eşitliği olan ve dışarıdan alt tiplenemeyen bir sınıf yaz."
- **Kıyasla:** Sınıf `final`, `==` ve `hashCode` birlikte override edilmiş, test eşit/eşit olmayan durumları doğrular.

### 3. interface vs base (3.0)
- **Aç:** `examples/lib/03_class_modifiers/interface_vs_base.dart`
- **Söyle:** `abstract interface class` dışarıda yalnızca `implements` edilir; `abstract base class` yalnızca `extends` edilir ve **base transitivity** uygulanır: alt tip `base`, `final` veya `sealed` olmak zorunda (düz `class` analyzer'da hata).
- **Tuzak:** `base` sınıfı başka library'de düz `class` ile extend edemezsin; alt tipi `final class` yaz (testteki `_CountingRepository`). Interface'i ise test library'sinde sahte olarak implement edebilirsin (`_FakeRepository`).
- **Skill'e ver:** "Fatura modülü için `abstract interface class InvoiceRepository`, hesaplanan toplamları bellekte tutan `abstract base class` bir taban ve onu extend eden `final` bir sınıf yaz."
- **Kıyasla:** Test, interface'i `implements` ile sahteler; base'i `final class ... extends` ile kullanır; paylaşılan mantık test edilir.

### 4. mixin class (3.0)
- **Aç:** `examples/lib/03_class_modifiers/mixin_class.dart`
- **Söyle:** `mixin class` hem `with` hem `extends` ile kullanılır; `abstract mixin class` ise construct edilemez.
- **Tuzak:** Mixin gibi kullanılan sınıfın `extends` / `implements` yapması ya da constructor parametresi olması `mixin class` bildirimini geçersiz kılar (analyzer reddeder); state'i private tut, dışarıya kopya ver (`List.unmodifiable`).
- **Skill'e ver:** "Sepet ve ödeme sınıflarının ikisinde de işlem geçmişi tutmak için hem `with` hem `extends` ile kullanılabilen bir `mixin class` yaz."
- **Kıyasla:** Test aynı sınıfı `with` ve `extends` ile kullanır; dışarıdan dönen liste değiştirilemez.


---

## Bölüm 04 · Libraries, part ve metadata

### 1. Library seviyesinde gizlilik (her sürüm)
- **Aç:** `examples/lib/04_libraries_metadata/library_privacy.dart`
- **Söyle:** `_` ile başlayan isim sınıfa değil library'ye özeldir; aynı dosyadaki her sınıf görür, başka dosya (test dahil) göremez.
- **Tuzak:** `WalletAuditor` aynı dosyada olduğu için `Wallet._balanceCents` alanını okuyup yazar (testte kanıtlı).
- **Skill'e ver:** "Bir `Product` stok modeli yaz: `_stock` yalnızca aynı dosyadaki `StockAuditor` tarafından sıfırlanabilsin, dışarıya sadece getter açık olsun."
- **Kıyasla:** Private alan başka dosyadan derlenmez; aynı dosyadaki sınıf erişir; `dart analyze` temiz.

### 2. `part` / `part of` (2.0)
- **Aç:** `examples/lib/04_libraries_metadata/part_files/order_builder.dart`
- **Söyle:** Bir library'yi birden çok dosyaya böler; part dosyası library'nin private isimlerini ve import'larını paylaşır.
- **Tuzak:** Part'taki `_Line` tipi ve `Queue` (ana dosyanın `dart:collection` import'u) ana dosyada kullanılır; part import'suz çalışır (testte kanıtlı).
- **Skill'e ver:** "Bir `InvoiceBuilder` sınıfını `part` ile iki dosyaya böl: private `_InvoiceLine` tipi part dosyasında, builder ana dosyada olsun."
- **Kıyasla:** Part dosyasında `import` yok, `part of '<dosya>.dart';` string URI ile; testte davranış doğrulanır.

### 3. `@immutable` ve `@useResult` (package:meta)
- **Aç:** `examples/lib/04_libraries_metadata/result_annotations.dart`
- **Söyle:** `@immutable` sınıfta non-final alanı, `@useResult` ise sonucu atılan çağrıyı analyzer'a raporlatır.
- **Tuzak:** `add` orijinali değiştirmez, yeni `Money` döner; sonucu atmak sessizce hiçbir şey yapmaz (testte kanıtlı).
- **Skill'e ver:** "`Discount` adında `@immutable` bir değer nesnesi yaz; `applyTo(Price)` metodu `@useResult` ile yeni `Price` döndürsün."
- **Kıyasla:** Tüm alanlar final, `const` constructor; `applyTo` sonucu atan satır analyzer tarafından raporlanır.

### 4. `@protected` ve `@mustCallSuper` (package:meta)
- **Aç:** `examples/lib/04_libraries_metadata/protected_members.dart`
- **Söyle:** `@protected` üyeyi yalnızca alt sınıflara ayırır; `@mustCallSuper` override'ın `super` çağırmasını zorlar.
- **Tuzak:** Alt sınıf `emit`'i kendi içinde serbestçe çağırır; `dispose` override'ı `super.dispose()` çağırmazsa dinleyiciler temizlenmez (testte kanıtlı).
- **Skill'e ver:** "`CheckoutStore` taban sınıfı yaz: `@protected setStatus`, `@mustCallSuper close()`; bir `PaymentStore` alt sınıfı bunları doğru kullansın."
- **Kıyasla:** Dışarıdan `setStatus` çağrısı ve `super.close()` eksik override analyzer uyarısı verir; test alt sınıf üzerinden çalışır.


---

## Bölüm 05 · Koleksiyonlar

### 1. Core mu paket mi (3.0)
- **Aç:** `examples/lib/05_collection/first_or_null.dart`
- **Söyle:** `firstOrNull`/`lastOrNull`/`singleOrNull`/`elementAtOrNull` core'da; predicate'li `firstWhereOrNull` hâlâ `package:collection`'da.
- **Tuzak:** `singleOrNull` iki veya daha fazla elemanda da null döner, hata vermez (test: "singleOrNull is null for zero and for two or more elements").
- **Skill'e ver:** "Bir kullanıcının kayıtlı adresleri listesinde varsayılan adresi bulan, yoksa null dönen fonksiyon yaz; listenin ilk elemanını da yazmadan null güvenli al."
- **Kıyasla:** Boş listede exception atmaz; `firstOrNull` için paket import'u yok, predicate'li arama için var; `dart analyze` temiz.

### 2. Gruplama ve sıralama (package:collection)
- **Aç:** `examples/lib/05_collection/group_and_sort.dart`
- **Söyle:** `groupListsBy`, `sortedBy`/`sortedByCompare`, `mapIndexed`, `compareNatural`.
- **Tuzak:** `sort()` yerinde çalışır ve `void` döner; `sorted*` yeni liste verir, kaynak değişmez (test: "sorting helpers return a new list and leave the source alone").
- **Skill'e ver:** "Bir kütüphane uygulamasında kitapları yazara göre grupla, her grubu yayın yılına göre yeniden eskiye sırala ve satırları '1. Başlık' diye numarala."
- **Kıyasla:** Grup anahtarları ilk görülme sırasında; kaynak liste değişmemiş; numara 1'den başlıyor.

### 3. İçerik eşitliği
- **Aç:** `examples/lib/05_collection/content_equality.dart`
- **Söyle:** `List`/`Map`/`Set` `==` ile identity karşılaştırır; içerik için `ListEquality`, `DeepCollectionEquality` kullanılır.
- **Tuzak:** `ListEquality<List<int>>` iç listeleri identity ile karşılaştırır; iç içe veri için `DeepCollectionEquality` gerekir (test: "ListEquality without deep support ..."). `hashCode` da aynı Equality ile üretilmeli.
- **Skill'e ver:** "Bir `Invoice` sınıfı yaz: `lines` (`List<Map<String, int>>`) alanı olsun; iki fatura içerik olarak aynıysa eşit, hashCode'ları da aynı olsun."
- **Kıyasla:** `==` ve `hashCode` aynı `DeepCollectionEquality` örneğini kullanıyor; iki ayrı ama aynı içerikli nesne için eşitlik ve hash testi geçiyor.

### 4. Değişmez state: kopya mı görünüm mü
- **Aç:** `examples/lib/05_collection/immutable_state.dart`
- **Söyle:** `List.unmodifiable` kopya alır; `UnmodifiableListView` canlı, salt-okunur görünümdür.
- **Tuzak:** `UnmodifiableListView` kopya değildir; sahibi listeyi değiştirirse görünüm de değişir (test: "the view rejects changes but follows the owner").
- **Skill'e ver:** "Bir oynatma listesi ekranı için `PlaylistState` (değişmez, `add` yeni state döner) ve iç listeyi salt-okunur açan bir `PlaylistViewModel` yaz."
- **Kıyasla:** State'e verilen kaynak liste sonradan değişse state değişmiyor; dışarı açılan listeye `add` `UnsupportedError` atıyor.

### 5. Öncelik kuyruğu
- **Aç:** `examples/lib/05_collection/task_scheduler.dart`
- **Söyle:** `HeapPriorityQueue` en küçük (karşılaştırıcıya göre ilk) elemanı verir.
- **Tuzak:** Eşit öncelikte FIFO garanti edilmez; `sequence` alanı ile karşılaştırıcıya ikinci ölçüt eklenir (test: "runs the highest priority first and FIFO within a priority").
- **Skill'e ver:** "Bir bildirim servisinde acil bildirimler önce, aynı aciliyette olanlar geliş sırasıyla gönderilen bir `NotificationScheduler` yaz."
- **Kıyasla:** Karşılaştırıcı öncelik sonra sıra numarasına bakıyor; `drain()` sonrası kuyruk boş.


---

## Bölüm 06 · Event loop ve Future

### 1. Event loop sırası (her sürüm)
- **Aç:** `examples/lib/06_event_loop_future/event_loop_order.dart`
- **Söyle:** Önce senkron kod, sonra **tüm** microtask'lar, sonra event kuyruğu (`Timer.run`, `Future()`) çalışır.
- **Tuzak:** `async` fonksiyon ilk `await`'e kadar senkron çalışır; çağıran, `await` etmese bile o kısmı hemen görür.
- **Skill'e ver:** "Bir sipariş takip ekranı için: senkron log, microtask ve Timer.run ile iki bildirimin hangi sırada çalıştığını kaydeden `orderOfNotifications()` yaz."
- **Kıyasla:** Test sırayı `sync → microtask → event` olarak doğrular; `dart analyze` temiz.

### 2. Future.wait ve record `.wait` (3.0)
- **Aç:** `examples/lib/06_event_loop_future/parallel_wait.dart`
- **Söyle:** Bağımsız istekleri aynı anda başlatıp bekler; record `.wait` her alanın tipini korur.
- **Tuzak:** `Future.wait` sonuçları verilen sırayla döner ve yalnız ilk hatayı bildirir; başarılı değerlere `ParallelWaitError.values` ile ulaşılır.
- **Skill'e ver:** "Ürün detay ekranı için `(Future<Product>, Future<int>) stock` çiftini record `.wait` ile bekleyen ve stok hata verirse ürünü yine gösteren `loadProductPage` yaz."
- **Kıyasla:** Test hem tam başarıyı hem kısmi başarıyı (`values`) kapsar; istekler `try`'dan önce başlatılır.

### 3. timeout ve Completer (her sürüm)
- **Aç:** `examples/lib/06_event_loop_future/timeout_completer.dart`
- **Söyle:** `Completer` callback API'sini `Future`'a çevirir; `.timeout` bekleme süresini sınırlar.
- **Tuzak:** `timeout` kaynak future'ı iptal etmez; geç gelen sonuç yok sayılır, `Completer` ikinci kez tamamlanırsa `StateError` atar (`isCompleted` ile koru).
- **Skill'e ver:** "Callback tabanlı bir `PaymentSdk.charge(onDone)` API'sini `Future<Receipt>`'e çeviren ve 5 saniyede `TimeoutException` fırlatan `chargeOrThrow` yaz."
- **Kıyasla:** Test sessiz SDK'de `TimeoutException`'ı, çift callback'te yalnız ilk sonucu doğrular.

### 4. unawaited, ignore ve ateşle-unut hatalar (unawaited 2.15, ignore 2.14)
- **Aç:** `examples/lib/06_event_loop_future/fire_and_forget.dart`
- **Söyle:** `unawaited` "bilerek beklemiyorum" der; `ignore()` hatayı da yutar.
- **Tuzak:** `unawaited` hatayı yutmaz; hata yine işlenmemiş (unhandled) olur, `ignore()` ise sessizce yutar.
- **Skill'e ver:** "Sepet ekranı açılınca `CartSync.push()` çağrısını ateşle-unut yapan `onCartOpened` yaz; hata olursa `logError`'a düşsün, uygulama çökmesin."
- **Kıyasla:** Test hatanın zone'a sızmadığını ve `logError`'a ulaştığını doğrular.


---

## Bölüm 07 · Streams

### 1. Single-subscription ve broadcast (2.x)
- **Aç:** `examples/lib/07_streams/stream_kinds.dart`
- **Söyle:** Varsayılan stream tek dinleyici kabul eder; `StreamController.broadcast()` çok dinleyici kabul eder ve dinleyicisiz olayları düşürür.
- **Tuzak:** Single-subscription'a ikinci `listen` `StateError` atar, ilk abonelik cancel edilse bile (test kanıtlıyor).
- **Skill'e ver:** "Kargo takibinde konum güncellemelerini birden çok ekrana dağıtan bir `ShipmentLocationFeed` yaz; kimse dinlemezken gelen konum düşsün."
- **Kıyasla:** `isBroadcast` true; iki dinleyici aynı olayı aldı; dinleyicisiz olay kayboldu.

### 2. `async*` generator (2.x)
- **Aç:** `examples/lib/07_streams/async_generator.dart`
- **Söyle:** `async*` + `yield` ile tembel stream üretir; dinleyici durunca `finally` çalışır ve sonraki sayfa istenmez.
- **Tuzak:** `take(3)` gibi erken durma sonraki sayfayı çağırmaz ve `finally` bir kez çalışır (test kanıtlıyor).
- **Skill'e ver:** "Ürün kataloğunu sayfa sayfa çeken `Stream<Product> products(fetchPage)` yaz; boş sayfada bitsin, erken iptalde temizlik callback'i çalışsın."
- **Kıyasla:** Sayfalar sırayla geldi; `take(n)` sonrası fazladan sayfa istenmedi; `onReleased` bir kez çağrıldı.

### 3. StreamController callback'leri (2.x)
- **Aç:** `examples/lib/07_streams/controller_callbacks.dart`
- **Söyle:** `onListen`, `onPause`, `onResume`, `onCancel` ile kaynak yalnız birisi dinlerken çalışır.
- **Tuzak:** Dinleyici gelene kadar `onListen` çalışmaz; kaynak kapalı kalır (test kanıtlıyor).
- **Skill'e ver:** "Her saniye pil yüzdesi yayan bir `Stream<int> batteryLevels` yaz; dinleyici gelince ölçüm başlasın, pause ve cancel'da dursun."
- **Kıyasla:** Log sırası `onListen`, `onPause`, `onResume`, `onCancel`; cancel sonrası yeni olay gelmedi.

### 4. `StreamTransformer` (2.x)
- **Aç:** `examples/lib/07_streams/message_transformer.dart`
- **Söyle:** `transform()` ile stream'i yeniden biçimlendirir; `fromHandlers` olay başına sink'e 0..n çıktı yazar.
- **Tuzak:** Sink'e eklemediğin olay sessizce düşer; kırpılan boş mesaj çıktıda yoktur (test kanıtlıyor).
- **Skill'e ver:** "Sipariş notlarını küçük harfe çevirip 3 karakterden kısa olanları atan bir `StreamTransformer<String, String>` yaz."
- **Kıyasla:** `transform` sonrası beklenen olaylar sırayla geldi, kısa not düştü.

### 5. Dinleyen state sınıfı ve dispose (2.x)
- **Aç:** `examples/lib/07_streams/price_watcher.dart`
- **Söyle:** Subscription alanda tutulur, `dispose()`'da `await cancel()` ve `null` yapılır; düz Dart, kütüphane yok.
- **Tuzak:** `dispose` sonrası gelen olay state'i değiştirmez; `start` iki kez çağrılsa tek abonelik olur (`??=`) (test kanıtlıyor).
- **Skill'e ver:** "Profil çevrimiçi durumunu dinleyen `PresenceWatcher` state sınıfı yaz; `start`, `dispose` ve son durumu tutsun."
- **Kıyasla:** `dispose` sonrası kaynağın `onCancel`'ı çalıştı; geç gelen olay değeri değiştirmedi.


---

## Bölüm 08 · package:async

### 1. CancelableOperation (2.x)
- **Aç:** `examples/lib/08_async_package/cancelable_search.dart`
- **Söyle:** Bir `Future`'ı iptal edilebilir sarar; iptalde sonuç atılır, `valueOrCancellation()` `null` döner.
- **Tuzak:** İptal alttaki isteği durdurmaz, yalnızca sonucunu yok sayar; tamamlanmış işte `cancel()` bir şey yapmaz (testte kanıtlı).
- **Skill'e ver:** "Bir profil ekranında kullanıcı adı müsaitlik kontrolü yaz: her tuş vuruşunda yeni istek atılsın, yalnızca son yazılanın sonucu `bool?` olarak dönsün, eskiler `null` dönsün."
- **Kıyasla:** Eski çağrı `null`, yeni çağrı değer döner; `hide Result` kullanılır; `dart analyze` temiz.

### 2. AsyncMemoizer (2.x)
- **Aç:** `examples/lib/08_async_package/async_memoizer.dart`
- **Söyle:** Async işi bir kez çalıştırır, sonraki/eşzamanlı çağıranlar aynı future'ı alır.
- **Tuzak:** Hata da sonsuza kadar saklanır, tekrar denenmez (testte kanıtlı).
- **Skill'e ver:** "Sepet servisi için kampanya listesini uygulama açılışında bir kez yükleyen `CampaignLoader` yaz; aynı anda üç ekran isterse tek istek atılsın."
- **Kıyasla:** Yükleyici fonksiyon sayacı 1 kalır (eşzamanlı ve sonraki çağrılarda); `hasRun` doğrulanır.

### 3. AsyncCache (2.x)
- **Aç:** `examples/lib/08_async_package/async_cache.dart`
- **Söyle:** Sonucu süre boyunca taze tutar; `invalidate()` ile sıfırlanır.
- **Tuzak:** Başarısız istek de TTL boyunca önbellekte kalır (testte kanıtlı).
- **Skill'e ver:** "Ürün stok durumu için 30 saniye TTL'li bir `StockCache` yaz; `refresh()` çağrısı bir sonraki okumada yeniden istek attırsın."
- **Kıyasla:** TTL içinde tek fetch; `invalidate` sonrası ikinci fetch; `Duration.zero` ile her seferinde yenilenir.

### 4. StreamQueue (2.x)
- **Aç:** `examples/lib/08_async_package/stream_queue.dart`
- **Söyle:** Stream'i pull-based okutur: `next`, `take(n)`, `peek`, `hasNext`, `rest`.
- **Tuzak:** Stream biterse `next` `StateError` fırlatır; önce `hasNext` sor, işin bitince `cancel()` et (testte kanıtlı).
- **Skill'e ver:** "Bir kargo takip stream'inden önce `STATUS 3` başlığını, sonra tam 3 adım satırını okuyan fonksiyon yaz."
- **Kıyasla:** Başlıktaki sayı kadar öğe döner; `finally` içinde `queue.cancel()` vardır.

### 5. StreamGroup ve StreamSplitter (2.x)
- **Aç:** `examples/lib/08_async_package/stream_group.dart`
- **Söyle:** `StreamGroup.merge` birçok kaynağı tek stream yapar; `StreamSplitter` tek-abonelikli stream'i birden çok tüketiciye tüm olaylarla verir.
- **Tuzak:** `asBroadcastStream` geç dinleyiciye eski olayları vermez, splitter verir (testte kanıtlı); merge ancak tüm kaynaklar kapanınca kapanır.
- **Skill'e ver:** "Mesajlaşma ekranı için iki WebSocket benzeri `Stream<String>` kaynağını birleştir; ayrıca gelen mesaj akışından hem okunmamış sayısı hem son mesajı üret."
- **Kıyasla:** Merge iki kaynaktan da olay iletir, ikisi kapanınca biter; splitter'ın her kolu tüm olayları görür.


---

## Bölüm 09 · Isolates

### 1. Eşikli ağır parse: `Isolate.run` (2.19)
- **Aç:** `examples/lib/09_isolates/decode_orders.dart`
- **Söyle:** Büyük gövde `Isolate.run` ile çözülür, küçük gövde inline kalır.
- **Tuzak:** `Isolate.run` içinde fırlayan hata aynı tipte ana isolate'e gelir (`FormatException` testte tipiyle yakalanır); `Result`'a çevirmeyi RepositoryImpl yapar. Parse fonksiyonu top-level ve saf olmalı.
- **Skill'e ver:** "Büyük bir GPX rota dosyasını nokta listesine çeviren `decodeRoute(String gpx)` yaz: 100 KB altında ana isolate'te, üstünde `Isolate.run` ile çalışsın; eşik parametre olsun, closure yalnızca `gpx`'i yakalasın."
- **Kıyasla:** Eşik 1 ve eşik büyük iken aynı sonucu verir; bozuk girdide `FormatException` tipiyle fırlar; parse fonksiyonu top-level; `dart analyze` temiz.

### 2. Ne gönderilir, closure ne yakalar (2.19)
- **Aç:** `examples/lib/09_isolates/capture_rules.dart`
- **Söyle:** Mesajlar kopyalanır, global değişken isolate'te ayrı kopyadır, bazı nesneler hiç gönderilemez.
- **Tuzak:** `ReceivePort`, `Socket`, `Pointer`, `Finalizer` gibi nesneyi yakalayan closure `ArgumentError` ile patlar (testli). API dokümanı (dartbug 36983): closure gerekenden fazla durum yakalayabilir; instance metodu içinde closure yazmak `this`'i taşıyabilir. Çözüm: gereken durumu parametre alan ayrı bir fonksiyonda closure kur (testi yok, API notudur).
- **Skill'e ver:** "Bir kullanıcı profilinin paylaşım kartı için piksel verisini (`List<int>`) `Isolate.run` ile gri tonlamaya çeviren `Future<List<int>> toGrayscale(List<int> pixels)` yaz; çağıranın listesi değişmemeli ve closure başka hiçbir alan yakalamamalı."
- **Kıyasla:** Dönen liste dönüşmüş, çağıranın listesi aynı; closure yalnızca parametreyi yakalıyor; global mutable duruma bağımlılık yok.

### 3. Sağlam worker: ports, hata ve çıkış (3.0)
- **Aç:** `examples/lib/09_isolates/price_worker.dart`
- **Söyle:** Tekrar eden işi, `onExit` ve ports ile kurulan uzun ömürlü bir isolate'e verir.
- **Tuzak:** Ölü worker asla yanıt vermez; isteği `exited` ile yarıştırmazsan çağıran sonsuza kadar bekler. Worker'daki hata `RemoteError` değeri olarak döner; `close()` sonrası istek `StateError` verir (üçü de testli).
- **Skill'e ver:** "Log satırlarını `LogEntry`'ye çeviren uzun ömürlü bir `LogWorker` yaz: `spawn()`, `parse(String line)`, `close()`; bozuk satır `RemoteError` olarak gelsin, worker kapanınca bekleyen/yeni istek `StateError` alsın."
- **Kıyasla:** Sıralı ve eşzamanlı istekler doğru cevabı alır; bozuk satır `RemoteError`; `close()` sonrası `exited` tamamlanır ve yeni istek `StateError` verir.

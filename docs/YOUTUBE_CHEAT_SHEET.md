# YouTube Çekim & Teknik Hazırlık Kartı (Master Cheat-Sheet)

> **Amaç:** Video kaydına girmeden önce her bölümün teknik özünü, ekran açılışlarını, canlı demolarını ve vurucu noktalarını tek sayfada görmek.

---

## Genel Çekim Formülü (~20 Dk)

```
[00:00] Önceki Alıştırma Çözümü  -->  testi çalıştır (1 dk)
[01:30] Hook (Shorts Kancası)    -->  ekranda şaşırtıcı test/hata (30 sn)
[02:00] Ne & Neden + Min. SDK    -->  1 cümle tanım
[03:00] Ne Zaman / Gerekmez      -->  karar tablosu
[04:00] Yapı Döngüsü             -->  Göster -> Anlat -> Skill'e yaptır -> Karşılaştır
[15:00] Flutter'da Gerçek Kanıt  -->  GitHub permalink aç
[17:00] Linter & Kontrol Listesi -->  best-practice kuralları
[18:00] 3 Yeni Alıştırma         -->  izleyiciye ödev ver, kapat
```

---

## 1. Sezon: 10 Bölümün Teknik Özeti

### Bölüm 0 · Tanıtım: AI'a Dart'ı Kanıtla Öğretmek (~10 dk)
- **Ana Fikir:** AI modelleri Dart'ta halüsinasyon görüyor (eski syntax, uydurma API). Çözüm: Testle kanıtlanmış "Güven Zinciri" (dart.dev $\rightarrow$ model kod $\rightarrow$ test $\rightarrow$ snippets).
- **Canlı Demo:** `examples/lib/02_typedefs/json_alias.dart` sonuna `typedef JsonMap = Json;` yaz $\rightarrow$ `dart run dartadvance_tool:dartadvance verify 02_typedefs` çalıştır $\rightarrow$ Hata göster $\rightarrow$ `snippets` komutuyla otomatik onar.
- **SDK Guard:** Projedeki SDK sınırına göre öneri yapma mantığı (Dart 3.8 projesine 3.10 özelliği önermemek).

---

### Bölüm 1 · Built-in Types: "'👋🏽'.length Neden 4?" (~20 dk)
- **Hook:** `'👋🏽'.length == 4` (UTF-16 code unit)! UI için `characters.length == 1` olmalı.
- **Teknik Kavramlar:**
  1. `String` vs `characters`: Metin kırpma ve SMS/bio alanlarında grapheme cluster zorunluluğu.
  2. `~/` Tamsayı Bölme: `-7 ~/ 2 == -3` (sıfıra doğru truncate eder, Python'daki gibi tabana değil).
  3. Para Hesabı: `double` asla kullanılmaz (IEEE 754 hatası) $\rightarrow$ `int` kuruş (minor unit).
  4. Web Semantiği: JS derlemesinde `1.0 is int` true döner; kod VM ile Web'de farklı davranabilir.
  5. `?..` null-aware cascade, Dart 3.7 wildcard `_`, ve asla dönmeyen kod için `Never`.
- **Ekranda Açılacak Dosya:** `examples/lib/01_builtin_types/grapheme_length.dart`
- **Flutter Kanıtı:** `LengthLimitingTextInputFormatter` $\rightarrow$ `characters.length` kullanır.

---

### Bölüm 2 · Typedefs: "Typedef Yeni Tip DEĞİLDİR" (~20 dk)
- **Hook:** `typedef UserId = int;` $\rightarrow$ `UserId` bekleyen yere her `int` verilebilir; tip güvenliği sağlamaz!
- **Teknik Kavramlar:**
  1. Typedef = Sadece takma isim (alias), yeni tip üretmez (tip güvenliği için Dart 3.3 *Extension Type* gerekir).
  2. `typedef Json = Map<String, Object?>`: `dynamic` yerine `Object?` (strict-casts ile tip güvenliği).
  3. Generic `Mapper<S, T>`: Fonksiyon imzalarını tek tipleştirme.
  4. Private Record Alias: Dosya içi ara sonuç taşırken `typedef _Partition = ({...})` (katman dışına sızmaz).
  5. Callback Sözleşmesi vs Inline Tip: Tek yerde geçiyorsa typedef yazma, inline `void Function(T)` yaz.
- **Ekranda Açılacak Dosya:** `examples/lib/02_typedefs/json_alias.dart` ve `private_record_alias.dart`
- **Flutter Kanıtı:** Flutter framework'te tam 411 typedef var! (`_TypeOf<T> = T` hilesi).

---

### Bölüm 3 · Class Modifiers: "'sealed' Alt Sınıflara Geçmez" (~20 dk)
- **Hook:** `sealed class Vehicle {}` $\rightarrow$ Alt sınıfı `class Car extends Vehicle {}` serbestçe genişletilebilir! Modifiers alt sınıflara miras kalmaz.
- **Teknik Kavramlar:**
  1. `sealed`: Kendi kütüphanesinde tüketilir, switch'te exhaustiveness zorlar.
  2. `final`: Dışarıdan ne `extend` ne `implement` edilebilir.
  3. `base`: Yalnızca `extend` edilebilir (miras zinciri korunur, alt sınıflar da `base`/`final`/`sealed` olmalı).
  4. `interface`: Yalnızca `implement` edilebilir.
  5. `abstract interface class`: Dart'ın resmi "saf arayüz" standardı.
  6. Kısıtlamalar kütüphane bazlıdır (aynı dosyada hepsi birbirini serbestçe extend edebilir).
- **Ekranda Açılacak Dosya:** `examples/lib/03_class_modifiers/sealed_state.dart`
- **Flutter Kanıtı:** `DragGestureRecognizer` sealed'dır; `PipelineOwner` base'dir.

---

### Bölüm 4 · Libraries & Metadata: "Privacy Sınıfa Değil Library'ye Göredir" (~20 dk)
- **Hook:** Aynı dosyadaki B sınıfı, A sınıfının `_privateField` alanını doğrudan okur ve yazar! Dart'ta sınıf gizliliği yoktur, kütüphane gizliliği vardır.
- **Teknik Kavramlar:**
  1. Privacy (`_`): Dosya/kütüphane düzeyindedir.
  2. Barrel Files: `export '...' show A, B;` ile dışarıya temiz API sunma, data katmanını gizleme.
  3. `part` ve `part of`: Tek bir kütüphaneyi dosyalara bölme (modern Dart'ta nadir kullanılır).
  4. Metadata Anotasyonları: `@immutable`, `@useResult` (sonucu çöpe atmayı engeller), `@protected`, `@mustCallSuper`.
- **Ekranda Açılacak Dosya:** `examples/lib/04_libraries_metadata/privacy.dart` ve `feature_barrel.dart`
- **Flutter Kanıtı:** Flutter framework'te tam 871 `export` satırı vardır.

---

### Bölüm 5 · Collection: "'firstWhereOrNull' Core'da Değil!" (~20 dk)
- **Hook:** `firstOrNull` Dart 3.0 ile SDK'ya geldi; ama `firstWhereOrNull` hala `package:collection` paketindedir!
- **Teknik Kavramlar:**
  1. `dart:collection` (SDK) vs `package:collection` (Paket): Hangisi nereden geliyor?
  2. Nesne Eşitliği: `List` ve `Map` varsayılanda referans eşitliğine bakar $\rightarrow$ `DeepCollectionEquality()` çözümü.
  3. Gruplama & Sıralama: `groupBy(list, key)`, `sortedBy(compare)`.
  4. `UnmodifiableListView`: Dışarıya liste verirken kapsülleme (orijinal listeyi koruma).
  5. `HeapPriorityQueue`: Aynı öncelikteki elemanlar için FIFO GARANTİSİ VERMEZ!
- **Ekranda Açılacak Dosya:** `examples/lib/05_collection/equality.dart` ve `group_by.dart`
- **Flutter Kanıtı:** Flutter Scheduler öncelik kuyruğunda `HeapPriorityQueue` kullanır.

---

### Bölüm 6 · Event Loop & Future: "Dart'ta Kod Hangi Sırayla Çalışır?" (~20 dk)
- **Hook:** Sıralama: `Senkron kod` $\rightarrow$ `Microtask kuyruğu` $\rightarrow$ `Timer.run` $\rightarrow$ `Future()`.
- **Teknik Kavramlar:**
  1. `async` fonksiyon ilk `await` satırına kadar tamamen senkron çalışır!
  2. `scheduleMicrotask`: Event loop'un önüne geçme mekanizması (UI kilitlenmelerine dikkat).
  3. Paralel İstekler: `Future.wait` vs modern Record `(f1, f2).wait`.
  4. `ParallelWaitError`: Biri hata alsa bile başarıyla tamamlanan değerleri kurtarabilme.
  5. Timeout & Hata Dönüştürme: `Future.timeout` ile domain `Failure` üretimi.
- **Ekranda Açılacak Dosya:** `examples/lib/06_event_loop_future/microtask_order.dart` ve `record_wait.dart`
- **Flutter Kanıtı:** `SynchronousFuture` ve `SchedulerBinding.endOfFrame`.

---

### Bölüm 7 · Streams: "Tek Abonelik mi, Broadcast mi?" (~20 dk)
- **Hook:** Single-subscription bir stream'i `cancel()` etseniz dahi ikinci kez `listen()` çağırmak `StateError` fırlatır!
- **Teknik Kavramlar:**
  1. Single-Subscription (I/O, WebSocket) vs Broadcast (UI State, Click event).
  2. `asBroadcastStream()` tuzağı: Dinleyici yokken gelen verileri çöpe atar (drop).
  3. `async*` ve `yield*`: Stream generator fonksiyonları.
  4. `StreamController` Lifecycle: `isClosed`, `hasListener` kontrolleri ve dispose güvenliği.
- **Ekranda Açılacak Dosya:** `examples/lib/07_streams/broadcast_stream.dart` ve `single_vs_broadcast.dart`
- **Flutter Kanıtı:** `StreamBuilder` widget'ının `dispose` sırasındaki subscription temizliği.

---

### Bölüm 8 · package:async: "Future İptal Edilemez, Ama Bu Edilir" (~20 dk)
- **Hook:** Dart'ta standart `Future` iptal edilemez (un-cancellable). Ancak `package:async` içindeki `CancelableOperation` ile arama kutusundaki race-condition çözülür!
- **Teknik Kavramlar:**
  1. `CancelableOperation`: Son sorgu kazanır (eski arama isteklerinin sonucunu yutma).
  2. `AsyncMemoizer`: Ağır hesaplamayı veya init fonksiyonunu kesin olarak yalnız bir kez çalıştırma.
  3. `AsyncCache`: Belirli bir süre (TTL) boyunca Future sonucunu önbellekleme.
  4. `StreamGroup`: Birden fazla stream'i tek bir stream olarak birleştirme.
  5. `StreamQueue`: Stream olaylarını senkron kuyruk gibi adım adım (`next`) okuma.
- **Ekranda Açılacak Dosya:** `examples/lib/08_async_package/latest_search.dart` ve `memoizer.dart`
- **Flutter Kanıtı:** Flutter Autocomplete bileşeni elle yazılmış sayaç yerine `CancelableOperation` mantığını kullanır.

---

### Bölüm 9 · Isolates & Compute: "Web'de Isolate Yok!" (~20 dk)
- **Hook:** `compute` fonksiyonu Web'de ayrı bir thread/worker açmaz; ana event loop'ta çalışır!
- **Teknik Kavramlar:**
  1. Dart Tek Thread'dir: Gerçek paralellik için `Isolate` şarttır (ayrı bellek alanı).
  2. `Isolate.run`: Dart 2.19 ile gelen modern tek satırlık isolate çalıştırma yöntemi.
  3. Eşik Maliyeti (Overhead): Küçük veri için isolate başlatmak ana thread'i bekletmekten daha yavaştır (50 KB kuralı).
  4. Closure Capture Tuzağı: Isolate içine gönderilen fonksiyona ait değişkenlerin kopyalanma maliyeti.
  5. Port Mimarisi: `ReceivePort` ve `SendPort` ile sürekli çalışan worker kurma.
- **Ekranda Açılacak Dosya:** `examples/lib/09_isolates/heavy_parse.dart` ve `threshold.dart`
- **Flutter Kanıtı:** Flutter `asset_bundle.dart` 50 KB altındaki JSON'ları isolate'e göndermez, ana thread'de parse eder!

---

## 3. Hızlı Komut Özeti

| Görev | Komut |
| --- | --- |
| Çekim öncesi tam test | `dart run dartadvance_tool:dartadvance verify --all` |
| Tek bir konuyu test etme | `dart run dartadvance_tool:dartadvance verify 01_builtin_types` |
| İzleyici alıştırma testleri | `cd examples && dart test test/01_builtin_types/practice/` |
| Canlı linkleri kontrol etme | `dart run dartadvance_tool:dartadvance links` |
| Snippet senkronizasyonu | `dart run dartadvance_tool:dartadvance snippets` |

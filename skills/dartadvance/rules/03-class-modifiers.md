# 03 · Class modifiers
> Kaynak: https://dart.dev/language/class-modifiers · https://dart.dev/language/class-modifiers-for-apis · https://dart.dev/language/modifier-reference · https://dart.dev/language/mixins#class-mixin-or-mixin-class · https://dart.dev/language/branches#exhaustiveness-checking · Min. sürüm: 3.0
Neden bu konu: Flutter'da state ve repository tiplerini kapatmak, yeni bir durum eklendiğinde derleyicinin seni uyarmasını sağlar; `_` ile yazılmış switch bu uyarıyı sessizce yutar.

Class modifier'lar bir sınıfın **başka library'lerden** construct / extend / implement / mix in edilip edilemeyeceğini belirler; Domain'de kapalı aileler (state, hata), Data'da sözleşmeler ve değer sınıfları için kullanılır. Kısıtlar tanımlandığı library'nin (tek `.dart` dosyası) içinde geçerli değildir.

## 1. sealed + exhaustive switch (3.0)
**Ne:** `sealed` kök doğrudan construct edilemez, alt tipleri aynı library'de kapalıdır; `switch` tüm alt tipleri kapsamazsa analyzer reddeder.
**Ne zaman:** Sınırlı varyantlı aile (UI state, hata türleri, ödeme yöntemi). **Gerekmez:** Alt tipi olmayan tek sınıf (`final class` yeter); dışarıdan genişlemesi istenen hiyerarşi.
<!-- snippet: 03_class_modifiers/sealed_order_state -->
```dart
// Düzelt: /dartadvance Projemde durumları `_` ya da default ile eşleyen switch'leri bul,
//    `sealed` aile + `_`'siz switch ile düzelt, test yaz.
// Üret: /dartadvance Bana ödeme sonucunu (başarılı, reddedildi, beklemede) ekran metnine
//    çeviren bir fonksiyon yaz.

sealed class OrderState {
  const OrderState();
}

final class OrderPlaced extends OrderState {
  const OrderPlaced();
}

final class OrderShipped extends OrderState {
  const OrderShipped(this.trackingCode);
  final String trackingCode;
}

final class OrderCancelled extends OrderState {
  const OrderCancelled(this.reason);
  final String reason;
}

String lazyText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  _ => 'Unknown', // cancelled order: 'Unknown'
};

String statusText(OrderState state) => switch (state) {
  OrderPlaced() => 'Preparing your order',
  OrderShipped(:final trackingCode) => 'On the way: $trackingCode',
  OrderCancelled(:final reason) => 'Cancelled: $reason',
};
```
**Tuzak:** `_` eklersen yeni alt tip eklendiğinde switch sessizce ona düşer, hata vermez; `_` yazma. `sealed` geçişli değildir: alt tipi `final` yapmazsan dışarıdan extend edilir (analyzer buna itiraz etmez).
**Düzelt (mevcut proje):** > "/dartadvance Projemde durumları `_` ya da default ile eşleyen switch'leri bul, `sealed` aile + `_`'siz switch ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ödeme sonucunu (başarılı, reddedildi, beklemede) ekran metnine çeviren bir fonksiyon yaz."
**Kabul:** Kök `sealed`, her alt tip `final class`, projedeki switch'lerde `_` yok; test her alt tip için ayrı metni doğrular ve `dart analyze` temiz.

## 2. final (3.0)
**Ne:** `final class` başka library'den construct edilir ama extend / implement edilemez (analyzer reddeder).
**Ne zaman:** Değer sınıfı, UseCase, entity: alt tiplenmemesi gereken somut sınıf. **Gerekmez:** Testte sahteleyeceğin sözleşme (onu `abstract interface class` yap).
<!-- snippet: 03_class_modifiers/final_money -->
```dart
// Düzelt: /dartadvance Projemde alt tiplenmemesi gereken değer sınıflarını bul, `final
//    class` + `==`/`hashCode` ile düzelt, test yaz.
// Üret: /dartadvance Bana faturadaki bir kalemi (ürün adı, adet, birim fiyat) tutan,
//    eşitlik karşılaştırılabilen sınıf yaz.

// ✗ class Bad extends Money {}  // analyzer: final class can't be extended
// ✗ class Fake implements Money {}  // analyzer: final class can't be implemented
final class Money {
  const Money(this.cents, this.currency);

  final int cents;
  final String currency;

  Money operator +(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
    return Money(cents + other.cents, currency); // 100 + 250 TRY: 350
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.cents == cents && other.currency == currency;

  @override
  int get hashCode => Object.hash(cents, currency);
}
```
**Tuzak:** `final` aynı library'de hiçbir şeyi kısıtlamaz ve `implements`'i de kapatır; mock gereken sınıfı `final` yaparsan test yazamazsın (bkz. bölüm 3). Testte yalnızca "dışarıdan construct edilir ve eşitlik çalışır" kanıtlanır; extend/implement reddi analyzer'dadır.
**Düzelt (mevcut proje):** > "/dartadvance Projemde alt tiplenmemesi gereken değer sınıflarını bul, `final class` + `==`/`hashCode` ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana faturadaki bir kalemi (ürün adı, adet, birim fiyat) tutan, eşitlik karşılaştırılabilen sınıf yaz."
**Kabul:** Bulunan sınıflar `final`, `==` ve `hashCode` birlikte override edilmiş; test eşit/eşit olmayan durumları doğrular.

## 3. interface vs base (3.0)
**Ne:** `abstract interface class` dışarıda yalnızca `implements` edilir; `abstract base class` yalnızca `extends` edilir ve **base transitivity** uygulanır: alt tip `base`, `final` veya `sealed` olmak zorunda (düz `class` analyzer'da hata).
**Ne zaman:** Repository sözleşmesi = `abstract interface class`; ortak mantık (cache, listener listesi) = `abstract base class`. **Gerekmez:** Tek metotlu sözleşme, fonksiyon tipi yeter.
<!-- snippet: 03_class_modifiers/interface_vs_base -->
```dart
// Düzelt: /dartadvance Projemde repository sözleşmelerini ve ortak mantıklı tabanları bul,
//    `abstract interface class` / `abstract base class` ile ayır, test yaz.
// Üret: /dartadvance Bana siparişleri getiren bir repository sözleşmesi ve sonuçları
//    önbellekleyen ortak bir taban yaz.

// ✗ class Bad extends ProductRepository {}  // analyzer: interface can't be extended
// Pure contract: outside code can only `implements` it (e.g. a test fake).
abstract interface class ProductRepository {
  Future<String?> findName(String productId);
}

// ✗ class Fake implements CachedProductRepository {}  // analyzer: base can't be implemented
// Shared logic: outside code can only `extends` it (as `base`/`final`).
abstract base class CachedProductRepository implements ProductRepository {
  final Map<String, String> _cache = {};

  @override
  Future<String?> findName(String productId) async {
    final cached = _cache[productId];
    if (cached != null) return cached; // 2nd call: no fetch
    final fetched = await fetchName(productId);
    if (fetched != null) _cache[productId] = fetched;
    return fetched;
  }

  Future<String?> fetchName(String productId);
}
```
**Tuzak:** `base` sınıfı başka library'de düz `class` ile extend edemezsin; alt tipi `final class` yaz (testteki `_CountingRepository`). Interface'i ise test library'sinde sahte olarak implement edebilirsin (`_FakeRepository`).
**Düzelt (mevcut proje):** > "/dartadvance Projemde repository sözleşmelerini ve ortak mantıklı tabanları bul, `abstract interface class` / `abstract base class` ile ayır, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana siparişleri getiren bir repository sözleşmesi ve sonuçları önbellekleyen ortak bir taban yaz."
**Kabul:** Test, interface'i `implements` ile sahteler; base'i `final class ... extends` ile kullanır; paylaşılan mantık test edilir.

## 4. mixin class (3.0)
**Ne:** `mixin class` hem `with` hem `extends` ile kullanılır; `abstract mixin class` ise construct edilemez.
**Ne zaman:** Eski bir sınıfı mixin olarak da açmak gerekiyorsa (Flutter'da `ChangeNotifier`). **Gerekmez:** Yeni kodda saf `mixin` veya saf `class` tercih et (Effective Dart); `mixin class` ikisini birden taahhüt eder.
<!-- snippet: 03_class_modifiers/mixin_class -->
```dart
// Düzelt: /dartadvance Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları
//    bul, `mixin class` ile birleştir, test yaz.
// Üret: /dartadvance Bana hem bir sınıfa karıştırılabilen hem miras alınabilen, çalma
//    listesi değişikliklerini kaydeden sınıf yaz.

// ✗ class Checkout with PlainAudit {}  // analyzer: plain class can't be mixed in
// `mixin class` works both as `with Auditable` and as `extends Auditable`.
mixin class Auditable {
  final List<String> _entries = [];

  List<String> get auditLog => List.unmodifiable(_entries); // add() throws

  void audit(String entry) => _entries.add(entry);
}
```
**Tuzak:** Mixin gibi kullanılan sınıfın `extends` / `implements` yapması ya da constructor parametresi olması `mixin class` bildirimini geçersiz kılar (analyzer reddeder); state'i private tut, dışarıya kopya ver (`List.unmodifiable`).
**Düzelt (mevcut proje):** > "/dartadvance Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları bul, `mixin class` ile birleştir, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana hem bir sınıfa karıştırılabilen hem miras alınabilen, çalma listesi değişikliklerini kaydeden sınıf yaz."
**Kabul:** Test aynı sınıfı `with` ve `extends` ile kullanır; dışarıdan dönen liste değiştirilemez.

## Flutter'da kanıt
- `sealed class IOSSystemContextMenuItem` + `final class` alt tipler: [system_context_menu.dart#L240](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/system_context_menu.dart#L240)
- `sealed class DragGestureRecognizer`, alt tipleri düz `class` (sealed geçişli değil): [monodrag.dart#L81](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/monodrag.dart#L81)
- `abstract interface class HitTestTarget`: [hit_test.dart#L44](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/hit_test.dart#L44); `base class PipelineOwner`: [object.dart#L1019](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/object.dart#L1019)
- `final class IconData`: [icon_data.dart#L23](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/icon_data.dart#L23); `mixin class ChangeNotifier`: [change_notifier.dart#L139](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L139)

## Kontrol listesi
- [ ] Kapalı aile `sealed` kök + `final class` alt tiplerle kuruldu, switch'te `_` yok.
- [ ] Değer sınıfı / UseCase `final class`.
- [ ] Mock gereken sözleşme `abstract interface class` (`final` değil).
- [ ] `base` sınıfın alt tipleri `base`/`final`/`sealed`.
- [ ] `mixin class` yalnızca hem `with` hem `extends` gerçekten gerekiyorsa.
- [ ] `pubspec.yaml` SDK alt sınırı >= 3.0.

## Pekiştirme
- **Kolay:** Ödeme yöntemi (kart, havale, kapıda ödeme) için sealed aile + `_`'siz switch yaz; her yöntem için bir test yeter.
- **Zor:** Bir `abstract base class` bildirim altyapısı (listener listesi) ve onu ayrı dosyada extend eden `final` bir sepet notifier'ı yaz; listener'ların "yükleniyor → yüklendi" sırasını gördüğünü test et.

# 03 · Class tasarımı
> Kaynak: https://dart.dev/language/class-modifiers · https://dart.dev/language/class-modifiers-for-apis · https://dart.dev/language/modifier-reference · https://dart.dev/language/mixins#class-mixin-or-mixin-class · https://dart.dev/language/branches#exhaustiveness-checking · https://dart.dev/language/metadata · https://pub.dev/documentation/meta/latest/meta/meta-library.html · https://dart.dev/language/libraries · https://dart.dev/effective-dart/usage#do-use-strings-in-part-of-directives · Min. sürüm: 3.0
Neden bu konu: bir sınıfın dışarıya nasıl açıldığı üç araçla söylenir: modifier (kim extend/implement eder), `package:meta` annotation'ı (analyzer neyi uyarır) ve library sınırı (`_`, `part`). Üçü birlikte, yeni bir durum eklendiğinde ya da bir kural çiğnendiğinde hatayı ekrana çıkmadan yakalatır.

Class modifier'lar bir sınıfın **başka library'lerden** construct / extend / implement / mix in edilip edilemeyeceğini belirler. Annotation'lar (`@immutable`, `@useResult`, `@protected`, `@mustCallSuper`) derlemeyi durdurmaz, analyzer uyarısı verir. Dart'ta `public/private/protected` yoktur; sınırı library (dosya) çizer.

## 1. sealed + exhaustive switch (3.0)
**Ne:** `sealed` kök doğrudan construct edilemez, alt tipleri aynı library'de kapalıdır; `switch` tüm alt tipleri kapsamazsa analyzer reddeder.
**Ne zaman:** Sınırlı varyantlı aile (UI state, hata türleri, ödeme yöntemi). **Gerekmez:** Alt tipi olmayan tek sınıf (`final class` yeter); dışarıdan genişlemesi istenen hiyerarşi.
<!-- snippet: 03_class_design/sealed_order_state -->
```dart
// Düzelt: /dartadvance Projemde durumu `_`/default'lu switch ya da if-else zinciriyle
//    ayıran yerleri bul, `sealed` aile + `_`'siz switch ile düzelt, test yaz.
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

// ✗ kopyalama: `_` yeni durumu sessizce yutar
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
**Düzelt (mevcut proje):** > "/dartadvance Projemde durumu `_`/default'lu switch ya da if-else zinciriyle ayıran yerleri bul, `sealed` aile + `_`'siz switch ile düzelt, test yaz."
**Üret (yeni kod):** > "/dartadvance Bana ödeme sonucunu (başarılı, reddedildi, beklemede) ekran metnine çeviren bir fonksiyon yaz."
**Kabul:** Kök `sealed`, her alt tip `final class`, projedeki switch'lerde `_` yok; test her alt tip için ayrı metni doğrular; geçici olarak yeni bir alt tip ekle, `dart analyze` `non_exhaustive_switch_expression` hatasını göstersin, sonra geri al.

## 2. final (3.0)
**Ne:** `final class` başka library'den construct edilir ama extend / implement edilemez (analyzer reddeder).
**Ne zaman:** Değer sınıfı, UseCase, entity: alt tiplenmemesi gereken somut sınıf. **Gerekmez:** Testte sahteleyeceğin sözleşme (onu `abstract interface class` yap).
<!-- snippet: 03_class_design/final_money -->
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
<!-- snippet: 03_class_design/interface_vs_base -->
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
<!-- snippet: 03_class_design/mixin_class -->
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

## 5. `@immutable`: state yerinde değişmez (package:meta)
**Ne:** `@immutable` sınıfta final olmayan alanı `must_be_immutable` ile raporlar. Değişiklik `copyWith` ile yeni nesne olur; `ValueNotifier` ve benzerleri aynı nesneyi yeniden yayınlayınca ekranı yenilemez. **Ne zaman:** state, değer nesnesi (para, satır, filtre). **Gerekmez:** kısa ömürlü, dışarı verilmeyen yardımcı nesne.
<!-- snippet: 03_class_design/cart_line -->
```dart
// Düzelt: /dartadvance Projemde state ve değer nesnesi sınıflarında final olmayan alanları ve
//    bu alanları yerinde değiştirip aynı nesneyi yeniden yayınlayan yerleri bul. @immutable ve
//    copyWith ile düzelt, yeni nesnenin yayınlandığını test et.
// Üret: /dartadvance Bana sepet satırı için @immutable bir state sınıfı ve adet artıran,
//    her değişiklikte yeni nesne yayınlayan bir store yaz.
import 'package:meta/meta.dart';

/// A cart line; the screen shows the quantity of the last published line.
@immutable
final class CartLine {
  const CartLine(this.name, this.quantity);

  final String name;
  final int quantity;

  @useResult
  CartLine copyWith({int? quantity}) => CartLine(name, quantity ?? this.quantity);
}

// ✗ A mutable field; @immutable reports it, the ignore hides the warning.
@immutable
// ignore: must_be_immutable
final class CartLineWrong {
  CartLineWrong(this.name, this.quantity);

  final String name;
  int quantity;
}

/// Publishes a new line only when it is a different object (like ValueNotifier).
final class CartStore<T> {
  CartStore(this._line, this.render) : shown = render(_line);

  T _line;

  /// Builds the text the screen shows for a line.
  final String Function(T line) render;

  /// What the screen last rebuilt with.
  String shown;

  T get line => _line;

  set line(T next) {
    if (identical(next, _line)) return; // same object: no rebuild
    _line = next;
    shown = render(next);
  }
}

final class QuantityButton {
  // ✗ Mutates in place and republishes the same object: the screen is not rebuilt.
  void increaseWrong(CartStore<CartLineWrong> store) {
    store.line.quantity++;
    store.line = store.line;
  }

  void increase(CartStore<CartLine> store) =>
      store.line = store.line.copyWith(quantity: store.line.quantity + 1);
}
```
**Tuzak:** sepet satırında adet yerinde artırılıp aynı nesne yayınlanır; ekran yenilenmez, adet 1'de kalır (test: "mutating in place republishes the same object...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde state ve değer nesnesi sınıflarında final olmayan alanları ve bu alanları yerinde değiştirip aynı nesneyi yeniden yayınlayan yerleri bul. @immutable ve copyWith ile düzelt, yeni nesnenin yayınlandığını test et."
**Üret (yeni kod):** > "/dartadvance Bana sepet satırı için @immutable bir state sınıfı ve adet artıran, her değişiklikte yeni nesne yayınlayan bir store yaz."
**Kabul:** state sınıflarında final olmayan alan kalmaz; değişiklik yeni nesneyle yayınlanır; `dart analyze` temiz.

## 6. `@useResult`: dönen değer atılmaz (package:meta)
**Ne:** `@useResult` sonucu kullanılmayan çağrıyı `unused_result` ile raporlar. Yeni değer döndüren metot (`copyWith`, `withX`, `add`) orijinali değiştirmez; sonucu atmak sessizce hiçbir şey yapmaz. **Ne zaman:** değiştirilemez nesnede yeni değer döndüren her metot. **Gerekmez:** yan etkisi olan, dönüşü bilgi amaçlı metot (ör. `bool` dönen `remove`).
<!-- snippet: 03_class_design/coupon_total -->
```dart
// Düzelt: /dartadvance Projemde yeni değer döndüren (copyWith, withX, add, apply) metotları
//    ve sonucunu atan çağrıları bul. @useResult ekle, atılan sonuçları düzelt, toplamın
//    değiştiğini test et.
// Üret: /dartadvance Bana sepet toplamı için kupon indirimini uygulayıp yeni toplam döndüren
//    bir sınıf yaz; sonucu atılırsa analyzer uyarsın.
import 'package:meta/meta.dart';

/// Checkout total in cents; applying a coupon returns a new total.
@immutable
final class CheckoutTotal {
  const CheckoutTotal(this.cents);

  final int cents;

  @useResult
  CheckoutTotal withDiscount(int discountCents) => CheckoutTotal(cents - discountCents);
}

final class CouponField {
  CouponField(this.total);

  CheckoutTotal total;
  bool applied = false;

  // ✗ The new total is dropped: "Kupon uygulandı", yet the total is unchanged.
  void applyWrong(int discountCents) {
    // ignore: unused_result
    total.withDiscount(discountCents);
    applied = true;
  }

  void apply(int discountCents) {
    total = total.withDiscount(discountCents);
    applied = true;
  }
}
```
**Tuzak:** "YAZ50 kuponu uygulandı" yazar ama ödenecek tutar 250,00 ₺ kalır (test: "a dropped @useResult value leaves the total unchanged").
**Düzelt (mevcut proje):** > "/dartadvance Projemde yeni değer döndüren (copyWith, withX, add, apply) metotları ve sonucunu atan çağrıları bul. @useResult ekle, atılan sonuçları düzelt, toplamın değiştiğini test et."
**Üret (yeni kod):** > "/dartadvance Bana sepet toplamı için kupon indirimini uygulayıp yeni toplam döndüren bir sınıf yaz; sonucu atılırsa analyzer uyarsın."
**Kabul:** yeni değer döndüren metotlarda `@useResult` var; atılan sonuç kalmaz; tutarın değiştiği test edilir; `dart analyze` temiz.

## 7. `@protected`: durumu yalnız alt sınıf değiştirir (package:meta)
**Ne:** `@protected` üyeyi alt sınıflara ayırır; başka library'den çağrı `invalid_use_of_protected_member` uyarısı verir. Store'un `emit`'i korunur, ekran yalnız iş metodunu (`pay`, `submit`) çağırır; doğrulama atlanamaz. **Ne zaman:** store/controller taban sınıfı; state'i değiştiren alt seviye metot. **Gerekmez:** gerçek erişim kontrolü gerekiyorsa (`@protected` yalnız uyarıdır): library gizliliği `_`.
<!-- snippet: 03_class_design/order_store -->
```dart
// Düzelt: /dartadvance Projemde store/controller taban sınıflarında durumu doğrudan değiştiren
//    (emit, setState, value =) public metotları ve bunları ekrandan çağıran yerleri bul.
//    @protected ekle, ekranın yalnız iş metodunu çağırdığını test et (pay_button.dart).
// Üret: /dartadvance Bana ödeme durumu tutan bir store yaz: durumu yalnız pay metodu
//    değiştirsin, kart reddedilirse "reddedildi" olsun.
import 'package:meta/meta.dart';

enum PaymentStatus { waiting, paid, declined }

/// Base store: subclasses change the state, screens only read it.
abstract base class Store<S> {
  Store(this._state);

  S _state;

  S get state => _state;

  @protected
  void emit(S next) => _state = next;
}

final class PaymentStore extends Store<PaymentStatus> {
  PaymentStore() : super(PaymentStatus.waiting);

  /// Validates the card, then emits.
  void pay({required bool cardAccepted}) =>
      emit(cardAccepted ? PaymentStatus.paid : PaymentStatus.declined);
}
```
<!-- snippet: 03_class_design/pay_button -->
```dart
// Düzelt: /dartadvance Projemde ekran, widget ya da başka bir library'den store'un emit /
//    setState / value = metodunu doğrudan çağıran yerleri bul. Taban metoda @protected ekle,
//    ekranın iş metodunu (pay, submit) çağırdığını test et.
// Üret: /dartadvance Bana ödeme ekranı için yalnız store.pay çağıran bir buton sınıfı yaz.
import 'package:dartadvance_examples/03_class_design/order_store.dart';

/// The pay button on the checkout screen; lives outside the store's library.
final class PayButton {
  // ✗ The screen skips pay() and emits directly: a declined card shows "Ödendi".
  void onTapWrong(PaymentStore store) {
    // ignore: invalid_use_of_protected_member
    store.emit(PaymentStatus.paid);
  }

  void onTap(PaymentStore store, {required bool cardAccepted}) =>
      store.pay(cardAccepted: cardAccepted);
}
```
**Tuzak:** ekran `emit(paid)`'i doğrudan çağırır; kart reddedildiği hâlde "Ödendi · Sipariş hazırlanıyor" görünür (test: "emitting from the screen skips validation...").
**Düzelt (mevcut proje):** > "/dartadvance Projemde ekran, widget ya da başka bir library'den store'un emit / setState / value = metodunu doğrudan çağıran yerleri bul. Taban metoda @protected ekle, ekranın iş metodunu (pay, submit) çağırdığını test et."
**Üret (yeni kod):** > "/dartadvance Bana ödeme ekranı için yalnız store.pay çağıran bir buton sınıfı yaz."
**Kabul:** taban sınıfta durum değiştiren metot `@protected`; ekran/widget katmanında `emit` çağrısı kalmaz; `dart analyze` temiz.

## 8. `@mustCallSuper`: temizlik atlanmaz (package:meta)
**Ne:** `@mustCallSuper` override'ın `super` çağırmasını zorlar; eksikse `must_call_super` uyarısı verir. Taban sınıfın `dispose`'u abonelik, timer, listener kapatır; alt sınıf unutursa ekran kapandıktan sonra da çalışırlar. **Ne zaman:** `dispose`, `close`, `cancel`, `initState` gibi zincir metotları. **Gerekmez:** taban metot boşsa ve boş kalacaksa.
<!-- snippet: 03_class_design/chat_controller -->
```dart
// Düzelt: /dartadvance Projemde dispose, close, cancel gibi temizlik yapan taban sınıf
//    metotlarını ve override edip super çağırmayan alt sınıfları bul. Tabana @mustCallSuper
//    ekle, ekrandan çıkınca dinleyicinin kapandığını test et.
// Üret: /dartadvance Bana gelen mesajları dinleyen bir sohbet controller'ı yaz; taban sınıf
//    dispose'da aboneliği kapatsın, alt sınıflar super.dispose() çağırmak zorunda olsun.
import 'package:meta/meta.dart';

/// Base controller: listens to incoming messages until dispose.
abstract base class MessageListener {
  bool listening = true;
  int markedRead = 0;

  /// Called by the socket for every incoming message.
  void onMessage() {
    if (listening) markedRead++; // the open chat marks messages as read
  }

  @mustCallSuper
  void dispose() => listening = false;
}

// ✗ Overrides dispose without super: the closed chat keeps marking messages as read.
final class ChatControllerWrong extends MessageListener {
  bool typingCleared = false;

  @override
  // ignore: must_call_super
  void dispose() => typingCleared = true;
}

final class ChatController extends MessageListener {
  bool typingCleared = false;

  @override
  void dispose() {
    typingCleared = true;
    super.dispose();
  }
}
```
**Tuzak:** sohbetten çıkınca gelen 3 mesaj "okundu" işaretlenir; karşı taraf "görüldü" görür (test: "dispose without super keeps marking messages as read").
**Düzelt (mevcut proje):** > "/dartadvance Projemde dispose, close, cancel gibi temizlik yapan taban sınıf metotlarını ve override edip super çağırmayan alt sınıfları bul. Tabana @mustCallSuper ekle, ekrandan çıkınca dinleyicinin kapandığını test et."
**Üret (yeni kod):** > "/dartadvance Bana gelen mesajları dinleyen bir sohbet controller'ı yaz; taban sınıf dispose'da aboneliği kapatsın, alt sınıflar super.dispose() çağırmak zorunda olsun."
**Kabul:** temizlik yapan taban metotlarda `@mustCallSuper`; tüm override'lar `super` çağırır; ekrandan çıkınca dinleyicinin kapandığı test edilir; `dart analyze` temiz.

## 9. Library seviyesinde gizlilik (her sürüm)
**Ne:** `_` ile başlayan isim sınıfa değil library'ye özeldir; aynı dosyadaki her sınıf görür, başka dosya (test dahil) göremez.
**Ne zaman:** Durumu tek yerden değiştirmek istediğinde; sıkı ilişkili yardımcı sınıfı (auditor, validator) aynı dosyaya koy.
**Gerekmez:** "Sınıfı özel yapmak" için `_` kullanma; sadece sınıfın kendisinden saklamak mümkün değil.
<!-- snippet: 03_class_design/library_privacy -->
```dart
// Düzelt: /dartadvance Projemde `_` alanına aynı dosyadaki başka sınıfın eriştiği yerleri
//    bul, library gizliliği kuralıyla ayır veya bilerek kabul et, her biri için test yaz.
// Üret: /dartadvance Bana bakiyesi gizli tutulan bir Coupon sınıfı ve eksiye düşeni
//    sıfırlayan denetçisini yaz.
// Same file = same library: no per-class privacy.
final class Wallet {
  Wallet(this._balanceCents);

  int _balanceCents;

  int get balanceCents => _balanceCents;

  void spend(int cents) => _balanceCents -= cents;
}

// ✗ other_file.dart: wallet._balanceCents = 0;  // analyzer: undefined_getter, `_` is library-private
// WalletAuditor lives in this file, so it may touch the private field.
final class WalletAuditor {
  const WalletAuditor();

  bool isOverdrawn(Wallet wallet) => wallet._balanceCents < 0; // true

  void writeOff(Wallet wallet) {
    if (isOverdrawn(wallet)) wallet._balanceCents = 0; // balance: 0
  }
}
```
**Tuzak:** `WalletAuditor` aynı dosyada olduğu için `Wallet._balanceCents` alanını okuyup yazar (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde `_` alanına aynı dosyadaki başka sınıfın eriştiği yerleri bul, library gizliliği kuralıyla ayır veya bilerek kabul et, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana bakiyesi gizli tutulan bir Coupon sınıfı ve eksiye düşeni sıfırlayan denetçisini yaz."
**Kabul:** Aynı dosyadan `_` erişimi ya ayrı dosyaya taşınarak derleme hatasına çevrildi ya da bilerek bırakıldı ve testle sabitlendi; `dart analyze` temiz.

## 10. `part` / `part of` (2.0)
**Ne:** Bir library'yi birden çok dosyaya böler; part dosyası library'nin private isimlerini ve import'larını paylaşır.
**Ne zaman:** Üretilmiş kod (`*.g.dart`, `*.freezed.dart`) veya private paylaşımı şart olan bölünme.
**Gerekmez:** El yazımı kodu bölmek için: önce küçük library'lere ayır. Part dosyası kendi `import`'unu yazamaz; Effective Dart `part of` için string URI ister.
Not: `part_files/order_builder_lines.dart` yalnızca `part` örneğinin eşlik eden dosyasıdır.
<!-- snippet: 03_class_design/part_files/order_builder -->
```dart
// Düzelt: /dartadvance Projemde elle yazılmış sınıfı `part` ile böldüğüm yerleri bul, `part
//    of` string URI ve import kurallarıyla düzelt, her biri için test yaz.
// Üret: /dartadvance Bana fatura satırı hesaplarını ayrı dosyaya bölen bir InvoiceBuilder
//    sınıfı yaz.
import 'dart:collection';

part 'order_builder_lines.dart';

final class OrderBuilder {
  final Queue<_Line> _lines = Queue<_Line>();

  void add(String sku, {int quantity = 1}) => _addLine(this, sku, quantity);

  int get totalQuantity => _lines.fold(0, (sum, line) => sum + line.quantity); // 3 + 1: 4

  List<String> get skus => [for (final line in _lines) line.sku];
}
```
**Tuzak:** Part'taki `_Line` tipi ve `Queue` (ana dosyanın `dart:collection` import'u) ana dosyada kullanılır; part import'suz çalışır (testte kanıtlı).
**Düzelt (mevcut proje):** > "/dartadvance Projemde elle yazılmış sınıfı `part` ile böldüğüm yerleri bul, `part of` string URI ve import kurallarıyla düzelt, her biri için test yaz."
**Üret (yeni kod):** > "/dartadvance Bana fatura satırı hesaplarını ayrı dosyaya bölen bir InvoiceBuilder sınıfı yaz."
**Kabul:** Part dosyasında `import` yok, `part of '<dosya>.dart';` string URI ile; el yazımı bölünmeler küçük library'lere ayrıldı veya gerekçelendirildi; davranış testle doğrulanır.

## Flutter'da kanıt
- `sealed class IOSSystemContextMenuItem` + `final class` alt tipler: [system_context_menu.dart#L240](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/system_context_menu.dart#L240)
- `sealed class DragGestureRecognizer`, alt tipleri düz `class` (sealed geçişli değil): [monodrag.dart#L81](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/monodrag.dart#L81)
- `abstract interface class HitTestTarget`: [hit_test.dart#L44](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/hit_test.dart#L44); `base class PipelineOwner`: [object.dart#L1019](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/object.dart#L1019)
- `final class IconData`: [icon_data.dart#L23](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/icon_data.dart#L23); `mixin class ChangeNotifier`: [change_notifier.dart#L139](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L139)
- `@immutable abstract class Widget`: [framework.dart#L311](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L311)
- `@protected @mustCallSuper void initState()`: [framework.dart#L1008](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L1008)
- Barrel + `export ... show`: [foundation.dart#L12](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/foundation.dart#L12)
- Framework'teki tek `part` kullanımı (üretilmiş veri): [animated_icons.dart#L10](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/animated_icons.dart#L10)

## Kontrol listesi
- [ ] Kapalı aile `sealed` kök + `final class` alt tiplerle kuruldu, switch'te `_` yok.
- [ ] Değer sınıfı / UseCase `final class`.
- [ ] Mock gereken sözleşme `abstract interface class` (`final` değil).
- [ ] `base` sınıfın alt tipleri `base`/`final`/`sealed`.
- [ ] `mixin class` yalnızca hem `with` hem `extends` gerçekten gerekiyorsa.
- [ ] `pubspec.yaml` SDK alt sınırı >= 3.0.
- [ ] State sınıfı `@immutable`, değişiklik `copyWith` ile yeni nesne.
- [ ] Yeni değer döndüren metotta `@useResult`; atılan sonuç yok.
- [ ] Store'un durum değiştiren metodu `@protected`; ekran yalnız iş metodunu çağırıyor.
- [ ] Temizlik yapan taban metotta `@mustCallSuper`; her override `super` çağırıyor.
- [ ] Private isim gerektiğinde `_` kullandım ve aynı dosyadaki erişimi bilerek kabul ettim.
- [ ] `part` yalnızca üretilmiş kod veya zorunlu private paylaşımı için; `part of` string URI.
- [ ] Barrel dosyada `export ... show` ile yalnızca public API açıldı; `src/` dışarı import edilmedi.

## Pekiştirme
- **Kolay:** Ödeme yöntemi (kart, havale, kapıda ödeme) için sealed aile + `_`'siz switch yaz; her yöntem için bir test yeter.
- **Zor:** Bir `abstract base class` bildirim altyapısı (listener listesi) ve onu ayrı dosyada extend eden `final` bir sepet notifier'ı yaz; listener'ların "yükleniyor → yüklendi" sırasını gördüğünü test et.
- Kolay: `Temperature` değer nesnesi yaz (`@immutable`, `@useResult` ile `plus`). Bitti: alanlar final, sonucu atan satır analyzer'da uyarı veriyor.
- Zor: Bir feature klasöründe `src/` altına iki sınıf koyup barrel dosyadan `export ... show` ile yalnızca birini aç. Bitti: dışarıdan `src/` import'u yok, gizli sınıf barrel'dan görünmüyor.

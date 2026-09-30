# 04 · Libraries, part ve metadata
> Kaynak: https://dart.dev/language/libraries · https://dart.dev/language/metadata · https://dart.dev/tools/pub/create-packages#organizing-a-package · https://dart.dev/effective-dart/usage#do-use-strings-in-part-of-directives · https://pub.dev/documentation/meta/latest/meta/meta-library.html · Min. sürüm: Dart 3.0 (`part of '<uri>'` 2.0)

Dart'ta `public/private/protected` yoktur; sınırı library (dosya) çizer, analyzer ise `package:meta` annotation'larıyla niyeti denetler. Domain'de değer nesnelerini ve gizli durumu, State katmanında store sözleşmesini korur.

## 1. Library seviyesinde gizlilik (her sürüm)
**Ne:** `_` ile başlayan isim sınıfa değil library'ye özeldir; aynı dosyadaki her sınıf görür, başka dosya (test dahil) göremez.
**Ne zaman:** Durumu tek yerden değiştirmek istediğinde; sıkı ilişkili yardımcı sınıfı (auditor, validator) aynı dosyaya koy.
**Gerekmez:** "Sınıfı özel yapmak" için `_` kullanma; sadece sınıfın kendisinden saklamak mümkün değil.
<!-- snippet: 04_libraries_metadata/library_privacy -->
```dart
// Privacy is per LIBRARY (file), not per class.
final class Wallet {
  Wallet(this._balanceCents);

  int _balanceCents;

  int get balanceCents => _balanceCents;

  void spend(int cents) => _balanceCents -= cents;
}

// Another class in the same file may touch Wallet's private field.
final class WalletAuditor {
  const WalletAuditor();

  bool isOverdrawn(Wallet wallet) => wallet._balanceCents < 0;

  void writeOff(Wallet wallet) {
    if (isOverdrawn(wallet)) wallet._balanceCents = 0;
  }
}
```
**Tuzak:** `WalletAuditor` aynı dosyada olduğu için `Wallet._balanceCents` alanını okuyup yazar (testte kanıtlı).
**Skill'e ver:** > "Bir `Product` stok modeli yaz: `_stock` yalnızca aynı dosyadaki `StockAuditor` tarafından sıfırlanabilsin, dışarıya sadece getter açık olsun."
**Kabul:** Private alan başka dosyadan derlenmez; aynı dosyadaki sınıf erişir; `dart analyze` temiz.

## 2. `part` / `part of` (2.0)
**Ne:** Bir library'yi birden çok dosyaya böler; part dosyası library'nin private isimlerini ve import'larını paylaşır.
**Ne zaman:** Üretilmiş kod (`*.g.dart`, `*.freezed.dart`) veya private paylaşımı şart olan bölünme.
**Gerekmez:** El yazımı kodu bölmek için: önce küçük library'lere ayır. Part dosyası kendi `import`'unu yazamaz; Effective Dart `part of` için string URI ister.
Not: `part_files/order_builder_lines.dart` yalnızca `part` örneğinin eşlik eden dosyasıdır.
<!-- snippet: 04_libraries_metadata/part_files/order_builder -->
```dart
import 'dart:collection';

part 'order_builder_lines.dart';

final class OrderBuilder {
  final Queue<_Line> _lines = Queue<_Line>();

  void add(String sku, {int quantity = 1}) => _addLine(this, sku, quantity);

  int get totalQuantity => _lines.fold(0, (sum, line) => sum + line.quantity);

  List<String> get skus => [for (final line in _lines) line.sku];
}
```
**Tuzak:** Part'taki `_Line` tipi ve `Queue` (ana dosyanın `dart:collection` import'u) ana dosyada kullanılır; part import'suz çalışır (testte kanıtlı).
**Skill'e ver:** > "Bir `InvoiceBuilder` sınıfını `part` ile iki dosyaya böl: private `_InvoiceLine` tipi part dosyasında, builder ana dosyada olsun."
**Kabul:** Part dosyasında `import` yok, `part of '<dosya>.dart';` string URI ile; testte davranış doğrulanır.

## 3. `@immutable` ve `@useResult` (package:meta)
**Ne:** `@immutable` sınıfta non-final alanı, `@useResult` ise sonucu atılan çağrıyı analyzer'a raporlatır.
**Ne zaman:** Değer nesneleri (para, ölçü, fiyat) ve "yeni değer döndüren" metotlar.
**Gerekmez:** Runtime koruması değildir; analyzer uyarısıdır, derlemeyi durdurmaz.
<!-- snippet: 04_libraries_metadata/result_annotations -->
```dart
import 'package:meta/meta.dart';

// The analyzer warns if a field here is not final.
@immutable
final class Money {
  const Money(this.cents, this.currency);
  final int cents;
  final String currency;

  // `total.add(fee);` alone is reported: the result is dropped.
  @useResult
  Money add(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(other.currency, 'other', 'Currency mismatch');
    }
    return Money(cents + other.cents, currency);
  }
}
```
**Tuzak:** `add` orijinali değiştirmez, yeni `Money` döner; sonucu atmak sessizce hiçbir şey yapmaz (testte kanıtlı).
**Skill'e ver:** > "`Discount` adında `@immutable` bir değer nesnesi yaz; `applyTo(Price)` metodu `@useResult` ile yeni `Price` döndürsün."
**Kabul:** Tüm alanlar final, `const` constructor; `applyTo` sonucu atan satır analyzer tarafından raporlanır.

## 4. `@protected` ve `@mustCallSuper` (package:meta)
**Ne:** `@protected` üyeyi yalnızca alt sınıflara ayırır; `@mustCallSuper` override'ın `super` çağırmasını zorlar.
**Ne zaman:** Store/controller taban sınıfı: durum değişimi alt sınıfta, `dispose` temizliği garanti.
**Gerekmez:** Gerçek erişim kontrolü değildir; dışarıdan çağrı derlenir, sadece uyarı alır.
<!-- snippet: 04_libraries_metadata/protected_members -->
```dart
import 'package:meta/meta.dart';

abstract base class CartStore<S> {
  CartStore(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void listen(void Function(S state) listener) => _listeners.add(listener);

  // Only subclasses should change state; outside callers get a warning.
  @protected
  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }

  // Overrides that forget super.dispose() are reported.
  @mustCallSuper
  void dispose() => _listeners.clear();
}
```
**Tuzak:** Alt sınıf `emit`'i kendi içinde serbestçe çağırır; `dispose` override'ı `super.dispose()` çağırmazsa dinleyiciler temizlenmez (testte kanıtlı).
**Skill'e ver:** > "`CheckoutStore` taban sınıfı yaz: `@protected setStatus`, `@mustCallSuper close()`; bir `PaymentStore` alt sınıfı bunları doğru kullansın."
**Kabul:** Dışarıdan `setStatus` çağrısı ve `super.close()` eksik override analyzer uyarısı verir; test alt sınıf üzerinden çalışır.

## Flutter'da kanıt
- `@immutable abstract class Widget`: [framework.dart#L311](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L311)
- `@protected @mustCallSuper void initState()`: [framework.dart#L1008](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L1008)
- Barrel + `export ... show`: [foundation.dart#L12](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/foundation.dart#L12)
- Framework'teki tek `part` kullanımı (üretilmiş veri): [animated_icons.dart#L10](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/animated_icons.dart#L10)

## Kontrol listesi
- [ ] Private isim gerektiğinde `_` kullandım ve aynı dosyadaki erişimi bilerek kabul ettim.
- [ ] `part` yalnızca üretilmiş kod veya zorunlu private paylaşımı için; `part of` string URI.
- [ ] Değer nesnelerinde `@immutable` + final alanlar.
- [ ] Yeni değer döndüren metotlarda `@useResult`.
- [ ] Taban sınıf yaşam döngüsünde `@protected` / `@mustCallSuper`.
- [ ] Barrel dosyada `export ... show` ile yalnızca public API açıldı; `src/` dışarı import edilmedi.

## Pekiştirme
- Kolay: `Temperature` değer nesnesi yaz (`@immutable`, `@useResult` ile `plus`). Bitti: alanlar final, sonucu atan satır analyzer'da uyarı veriyor.
- Zor: Bir feature klasöründe `src/` altına iki sınıf koyup barrel dosyadan `export ... show` ile yalnızca birini aç. Bitti: dışarıdan `src/` import'u yok, gizli sınıf barrel'dan görünmüyor.

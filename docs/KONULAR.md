# Konular: neden bunlar, neden bu sırada

Seçim ölçütü: Flutter geliştiricisinin **her gün yazdığı** ve **sessizce yanlış yaptığı** şeyler. Önce her satırda çıkan temeller,
sonra tasarım (tipler, modifier'lar, library), sonra veri (koleksiyon), en sonda asenkron zincir (her konu bir öncekine dayanır).

| # | Konu | Neden bu konu | Neden bu sırada |
| --- | --- | --- | --- |
| 01 | Built-in types | Bildiğini sandığın tipler: kuruş `int`, `%`, JSON `num`, `tryParse`, `characters`, Türkçe slug, record anahtar, UTC saat, `late final`/getter, cascade ve `?..`; hepsi derlenir, hata ekranda çıkar | Her sonraki konunun kodu bunları kullanır |
| 02 | Typedefs | Callback ve JSON tipleri her yerde; "alias yeni tip değildir" sürprizi kısa ve etkili | Küçük, hızlı kazanım; Json ve callback tipleri sonraki konularda geçer |
| 03 | Class tasarımı | Bir sınıfın dışarıya nasıl açıldığı: modifier (`sealed` state, `final`/`base` API sınırı), annotation (`@immutable`, `@useResult`, `@protected`, `@mustCallSuper`) ve library sınırı (`_`, `part`); hepsi hatayı ekrana çıkmadan yakalatır | Tip tasarımı; temel tiplerden sonra, veriden önce |
| 04 | Collection | `package:collection` (`firstWhereOrNull`, `groupBy`, Equality, `slices`, `sortedBy`, `PriorityQueue`), `fast_immutable_collections` `IList`, null-aware element | Günlük veri işlemi; async konulardan önce eldeki veri güvenli olmalı |
| 05 | Event loop ve Future | Sıralı `await`, yutulan hatalar | Async zincirin temeli |
| 06 | Streams | Sızan `listen`, tek/çok abonelik | Future'ı bilmeden anlaşılmaz |
| 07 | `package:async` | `dart:async`'in çözmediği iptal, önbellek, sıralı okuma | Future ve Stream bilindikten sonra eksikleri tamamlar |
| 08 | Isolates | Ağır işte frame kaçar; closure ne yakalar | En ileri seviye; async zincirin sonu |

## Sonra gelecekler (önerilen sıra)

Generics ve tip sistemi · Null safety ve type promotion · Records · Patterns · Enhanced enums · Extension types ·
Constructors ve modern sözdizimi · Hata yönetimi (`Result`/`Failure`) · Iterables ve `sync*` · diğer core paketler.
Yeni konu sıradaki numarayı alır (boşluk yok).

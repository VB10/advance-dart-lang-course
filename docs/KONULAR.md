# Konular: neden bunlar, neden bu sırada

Seçim ölçütü: Flutter geliştiricisinin **her gün yazdığı** ve **sessizce yanlış yaptığı** şeyler. Önce her satırda çıkan temeller,
sonra tasarım (tipler, modifier'lar, library), sonra veri (koleksiyon), en sonda asenkron zincir (her konu bir öncekine dayanır).

| # | Konu | Neden bu konu | Neden bu sırada |
| --- | --- | --- | --- |
| 01 | Built-in types | Metin uzunluğu, bölme, `final`/`const`: her dosyada çıkar, hataları sessizdir | Her sonraki konunun kodu bunları kullanır |
| 02 | Typedefs | Callback ve JSON tipleri her yerde; "alias yeni tip değildir" sürprizi kısa ve etkili | Küçük, hızlı kazanım; Json ve callback tipleri sonraki konularda geçer |
| 03 | Class modifiers | State ve repository tiplerini kapatıp derleyiciyle güvenlik almak | Tip tasarımı; `sealed` state, `final`/`base` API sınırı |
| 04 | Libraries, `part`, metadata | Gizlilik sınıfa değil library'ye göre; `part` ve annotation'lar yanlış güvenlik verir | 03'teki kısıtların library sınırıyla nasıl çalıştığını tamamlar |
| 05 | Koleksiyonlar | Boş listede `first`, yerinde `sort()`, `==` tuzakları en sık görülen hatalar | Günlük veri işlemi; async konulardan önce eldeki veri güvenli olmalı |
| 06 | Event loop ve Future | Sıralı `await`, yutulan hatalar | Async zincirin temeli |
| 07 | Streams | Sızan `listen`, tek/çok abonelik | Future'ı bilmeden anlaşılmaz |
| 08 | `package:async` | `dart:async`'in çözmediği iptal, önbellek, sıralı okuma | Future ve Stream bilindikten sonra eksikleri tamamlar |
| 09 | Isolates | Ağır işte frame kaçar; closure ne yakalar | En ileri seviye; async zincirin sonu |

## Sonra gelecekler (önerilen sıra)

Generics ve tip sistemi · Null safety ve type promotion · Records · Patterns · Enhanced enums · Extension types ·
Constructors ve modern sözdizimi · Hata yönetimi (`Result`/`Failure`) · Iterables ve `sync*` · diğer core paketler.
Yeni konu sıradaki numarayı alır (boşluk yok).

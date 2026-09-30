# İzleyici Alıştırma Rehberi (Practice Workflow)

Bu repo, YouTube **"Advance Dart"** serisini izleyen geliştiricilerin her bölüm sonundaki pekiştirme alıştırmalarını kendi bilgisayarlarında çözüp otomatik testlerle doğrulamaları için tasarlanmıştır.

---

## 1. Hazırlık & Kurulum

1. Repoyu klonlayın veya fork'layın:
   ```sh
   git clone https://github.com/vb10/advance-dart-lang-course.git
   cd advance-dart-lang-course
   ```
2. Bağımlılıkları yükleyin:
   ```sh
   dart pub get
   cd examples && dart pub get && cd ..
   ```
3. Testlerin çalıştığını doğrulayın:
   ```sh
   cd examples
   dart test
   ```

---

## 2. Alıştırma Döngüsü

Her konu (`01` - `09`) için 3 kademeli alıştırma bulunur:
- **Alıştırma 1 (Kolay):** Kavramın temeli ve yaygın tuzaklar.
- **Alıştırma 2 (Orta):** Katmanlı mimaride (Domain / Data / Presentation) gerçek kullanım.
- **Alıştırma 3 (Zor):** Önceki bölümlerle birleşik senaryo.

### Alıştırmayı Nasıl Çözersiniz?

1. İlgili konunun reference dosyasını (`skills/dartadvance/references/NN-*.md`) açın ve en alttaki **Pekiştirme** başlığını okuyun.
2. Alıştırmanın testini inceleyin:
   ```sh
   # Örnek: Bölüm 01 Alıştırma 1 testi
   cat examples/test/01_builtin_types/practice/ex1_price_label_test.dart
   ```
3. Testin beklediği fonksiyonu veya sınıfı kendi kodunuzda yazın.
4. Yalnızca ilgili konunun alıştırma testlerini çalıştırın:
   ```sh
   cd examples
   dart test test/01_builtin_types/practice/
   ```
5. Testler yeşile döndüğünde çözümünüz tamamdır!
6. Referans çözümü görmek isterseniz:
   - Reference dosyasındaki `<details><summary>Çözüm</summary>` kutusunu açabilir,
   - veya `examples/lib/NN_*/practice/exN_*.dart` dosyasını inceleyebilirsiniz.

---

## 3. Bölüm Bazında Test Komutları

| Bölüm | Konu | Alıştırma Testi Komutu (examples dizininde) |
| --- | --- | --- |
| **01** | Built-in Types | `dart test test/01_builtin_types/practice/` |
| **02** | Typedefs | `dart test test/02_typedefs/practice/` |
| **03** | Class Modifiers | `dart test test/03_class_modifiers/practice/` |
| **04** | Libraries & Metadata | `dart test test/04_libraries_metadata/practice/` |
| **05** | Collection | `dart test test/05_collection/practice/` |
| **06** | Event Loop & Future | `dart test test/06_event_loop_future/practice/` |
| **07** | Streams | `dart test test/07_streams/practice/` |
| **08** | Async Package | `dart test test/08_async_package/practice/` |
| **09** | Isolates | `dart test test/09_isolates/practice/` |

---

## 4. Kod Standartları ("Ekran Kodu")

Alıştırmaları çözerken serinin benimsediği kurallara uyun:
1. **Tek kavram:** Fonksiyon veya sınıf tek bir amaca hizmet etsin.
2. **Kısa ve net:** Çözüm dosyanız $\le 50$ satır kalsın.
3. **Erken dönüş (early return):** Derin if-else blokları yerine guard clause veya switch expression tercih edin (en fazla 3 seviye iç içelik).
4. **Tip güvenliği:** `dynamic` kullanmayın; `strict-casts` ve `strict-inference` uyarılarını sıfırda tutun:
   ```sh
   dart analyze --fatal-infos
   ```

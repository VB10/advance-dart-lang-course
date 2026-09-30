# Bölüm 0 · Çekim Kartı: "AI'a Dart'ı Kanıtla Öğretmek"

**Süre:** ~10-12 dakika  
**Format:** Giriş / Tanıtım & Kulis  
**Ana Fikir:** AI modelleri halüsinasyon görüyor, eski syntax üretiyor veya Flutter kodunu kafasından uyduruyor. Çözüm: Testle kanıtlanmış güven zinciri (dart.dev $\rightarrow$ examples $\rightarrow$ test $\rightarrow$ snippets $\rightarrow$ permalink).

---

## 1. Akış & Zaman Kodları

### 00:00 - 02:00 | Giriş & Büyük Problem (Hook)
- **Konuşma Özeti:** "Yapay zekaya kod yazdırırken hiç 'bu fonksiyon hangi sürümde geldi?' ya da 'böyle bir API gerçekten var mı?' diye şüpheye düştünüz mü? Çoğu LLM Dart 2 alışkanlıklarıyla kod yazıyor ya da henüz çıkmamış özellikleri varmış gibi uyduruyor."
- **Ekranda:** Yanlış üretilmiş bir kod örneği veya `pubspec`'te olmayan uydurma bir paket kullanımı.

### 02:00 - 04:30 | Güven Zinciri (Proof-Chain) Mimarisi
- **Konuşma Özeti:** "Bu serideki tek bir satır kod bile rastgele yazılmadı. Kurduğumuz mimaride:
  1. Resmi dart.dev dokümanı kaynak alınır.
  2. Her kavram için $\le 50$ satırlık tekil bir model dosya yazılır.
  3. Bu dosya otomatik bir birim test ile doğrulanır.
  4. Dokümantasyondaki kod blokları bir tool (`dartadvance snippets`) ile doğrudan test edilmiş koddan kopyalanır.
  5. Flutter'da 'böyle kullanılır' dediğimiz her şey GitHub'daki sabit tag'li gerçek framework satırına dayanır."

### 04:30 - 08:00 | Canlı Demo (Otomasyonun Gücü)
Terminalde canlı gösteri:
1. `examples/lib/02_typedefs/json_alias.dart` dosyasını aç.
2. Dosyanın sonuna yeni bir alias satırı ekle:
   ```dart
   typedef JsonMap = Json;
   ```
3. Terminalde doğrulamayı çalıştır:
   ```sh
   dart run dartadvance_tool:dartadvance verify 02_typedefs
   ```
   *Ekranda kırmızı hata çıktısı görünür:* `verify(02_typedefs): FAILED at snippets`
4. İzleyiciye anlat: "Gördüğünüz gibi, referans doküman ile test edilen kod uyuşmadığında sistem alarm verdi!"
5. Snippet aracını çalıştır:
   ```sh
   dart run dartadvance_tool:dartadvance snippets
   ```
6. Şimdi tekrar doğrula:
   ```sh
   dart run dartadvance_tool:dartadvance verify 02_typedefs
   ```
   *Sonuç:* `verify(02_typedefs): PASSED`
7. Değişikliği geri al:
   ```sh
   git checkout .
   ```

### 08:00 - 10:00 | SDK Guard & Sezon 1 Vizyonu
- **SDK Guard:** `pubspec.yaml`'daki SDK alt sınırı okunur; örneğin Dart 3.8 projesine 3.10'un dot-shorthand'leri önerilmez.
- **Sezon 1 Kapsamı:** 1'den 9'a kadar her bölümde tek bir ileri seviye konu, arkasından canlı agent demosu ve 3 adet pekiştirme alıştırması.

---

## 2. YouTube Video Bilgileri (Açıklama & Etiketler)

### Başlık Önerileri
- AI'a Dart'ı Kanıtla Öğretmek: Halüsinasyonsuz İleri Seviye Dart!
- Yapay Zekaya Dart Kodlatırken Neden Yanılıyoruz? (Güven Zinciri Mimarisi)

### Açıklama Metni (Description)
```text
Advance Dart serisine hoş geldiniz! Bu seride yüzeysel "Hello World" örneklerini geride bırakıyor, modern Dart dilinin (3.0+) derinliklerine iniyoruz.

Bu bölümde:
- AI modellerinin Dart kodlarken neden halüsinasyon gördüğünü,
- Sıfır hata ile çalışan "Güven Zinciri" mimarisini,
- Doküman, test ve gerçek kodun nasıl senkronize edildiğini inceliyoruz.

Zaman Damgaları:
0:00 - Neden İleri Seviye Dart?
2:00 - Güven Zinciri (Proof-Chain) Nedir?
4:30 - Canlı Demo: Snippet ve Doğrulama Otomasyonu
8:00 - SDK Guard Mekanizması
9:30 - Sezon 1 Müfredatı & Gelecek Bölüm

GitHub Reposu: https://github.com/vb10/advance-dart-lang-course
#dart #flutter #ai #advancedart #cleanarchitecture
```

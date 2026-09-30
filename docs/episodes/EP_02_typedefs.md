# Bölüm 2 · Çekim Kartı: "Typedef Yeni Tip DEĞİLDİR"

**Süre:** ~20 dakika  
**Format:** Standart Bölüm Döngüsü  
**Konu:** Typedefs (alias vs yeni tip), `typedef Json = Map<String, Object?>`, generic mapper, private record alias, callback sözleşmeleri, inline tip tercihi.  
**Reference:** [`skills/dartadvance/references/02-typedefs.md`](../../skills/dartadvance/references/02-typedefs.md)

---

## 1. Zaman Çizelgesi & Canlı Akış

### 00:00 - 01:30 | Önceki Bölümün Alıştırma Çözümü
- Bölüm 1 alıştırmalarının hızlıca gösterilmesi (`practice/ex1_price_label.dart`, `ex2_user_profile.dart`, `ex3_safe_amount.dart`).
- Testlerin çalıştırılması:
  ```sh
  cd examples && dart test test/01_builtin_types/practice/
  ```

### 01:30 - 03:00 | Hook (Shorts Formatı)
- **Ekran:** Sol pencerede kod ve test:
  ```dart
  typedef UserId = int;
  typedef OrderId = int;

  void payOrder(OrderId id) { ... }

  UserId myUser = 42;
  payOrder(myUser); // HATA VERMEZ! Derlenir ve çalışır!
  ```
- **Vurgu:** "`typedef UserId = int;` yazdığınızda tip güvenliği sağladığınızı sanıyorsanız yanılıyorsunuz! Typedef yeni bir tip üretmez; sadece var olan bir tipe lakap (alias) takar."

### 03:00 - 04:00 | Ne Zaman Kullan / Ne Zaman Gerekmez
| Kullan | Gerekmez / Başka Araç |
| --- | --- |
| Uzun veya sık tekrarlanan tip: `Map<String, Object?>` $\rightarrow$ `Json` | Tek yerde geçen fonksiyon tipi $\rightarrow$ **Inline** yaz |
| Dışarıya sunulan callback sözleşmesi: `UserTapCallback` | Tip güvenli ID / Value Object $\rightarrow$ **Extension type** |
| Dosya içi private record alias: `_Partition` | Katmanlar arası public API $\rightarrow$ Entity / Sınıf |

### 04:00 - 15:00 | Yapı Döngüsü (Kod + Canlı AI Demoları)

#### Yapı 1: JSON Alias & `dynamic` Yerine `Object?`
- **Göster:** `examples/lib/02_typedefs/json_alias.dart`
- **Vurgu:** Neden `Object?`? Çünkü `strict-casts` açıkken kontrolsüz erişimi engeller, pattern matching'e zorlar.

#### Yapı 2: Generic Mapper Typedef
- **Göster:** `examples/lib/02_typedefs/generic_mapper.dart`
- **Skill'e yaptır (Sağ pencere):**
  > "Fatura Model'lerini Entity'lere çeviren tüm mapper'lar için tek bir generic fonksiyon tipi (`Mapper<S, T>`) ve listeyi çeviren yardımcıyı yaz."

#### Yapı 3: Private Record Alias ile Dosya İçi Temizlik
- **Göster:** `examples/lib/02_typedefs/private_record_alias.dart`
- **Vurgu:** Dosya içinde geçerli ve atlanan kayıtları ayırırken `typedef _Partition = ({...})` kullanılır; public API'ye record sızdırılmaz.

#### Yapı 4: Callback Sözleşmeleri vs Inline Tipler
- **Göster:** `callback_typedefs.dart` ve `inline_function_type.dart`
- **Kural:** Eğer bir fonksiyon tipi tek bir yerde parametre olarak geçiyorsa typedef yazıp kodu kirletmeyin; `void Function(String query)` şeklinde inline tanımlayın.

### 15:00 - 17:00 | Flutter Framework'ten Gerçek Kanıt
- Tarayıcıda aç: [flutter/src/foundation/key.dart#L165](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/key.dart#L165)
- **Göster:** Flutter'da tam **411 adet typedef** var!
- Özellikle `_TypeOf<T> = T` hilesi: Tip ifadesi elde etmek için generic typedef'in nasıl ustalıkla kullanıldığını göster.

### 17:00 - 18:00 | Linter & Kontrol Listesi
- `prefer_generic_function_type_aliases` (Eski `typedef int F(int a);` sözdizimini yasaklar).
- `use_function_type_syntax_for_parameters`
- `avoid_private_typedef_functions`

### 18:00 - 20:00 | Pekiştirme: 3 Alıştırma
1. **Alıştırma 1 (Kolay):** Birim alias'ı tuzağı (`Celsius` vs `Fahrenheit`).
2. **Alıştırma 2 (Orta):** Form validasyonu için `Validator<T>` ve `combine` fonksiyonu.
3. **Alıştırma 3 (Zor):** Puan özeti: private record alias + JSON sayıları (Built-in types ile birleşik).

---

## 2. Shorts / Reels Senaryosu (60 Saniye)

```text
[Kamera Karşısı - 0-5 sn]:
"Dart'ta typedef yazdığınızda yeni bir tip yarattığınızı mı sanıyorsunuz?"

[Ekran Kaydı - 5-25 sn]:
"Bakın:
typedef UserId = int;
typedef OrderId = int;

void pay(OrderId id) => print('Ödendi');

UserId user = 100;
pay(user); // Derlenir! Sıfır hata!

Çünkü typedef bir tip yaratmaz. Sadece o tipe takma bir isim (alias) verir."

[Ekran Kaydı - 25-45 sn]:
"Peki gerçekten tip güvenliği istiyorsak ne yapmalıyız?
Dart 3.3 ile gelen 'extension type' kullanmalıyız!
extension type OrderId(int value) {}
Artık sıradan bir int veya UserId verdiğinizde derleyici anında kırmızı çizer!"

[Kamera Karşısı - 45-60 sn]:
"Typedef nerede kullanılır, nerede kullanılmaz?
Flutter kaynak kodundaki 411 typedef örneğiyle kanalda anlattık. İzlemeyi unutmayın!"
```

---

## 3. YouTube Açıklama Metni (Description)

```text
Dart dilinde typedef'lerin ne olduğunu, ne olmadığını ve Flutter framework'ünde nasıl kullanıldığını inceliyoruz!

Bu bölümde:
- Typedef neden yeni bir tip DEĞİLDİR?
- Tip güvenli ID'ler için typedef yerine ne kullanılmalı?
- JSON işlemede Map<String, dynamic> yerine neden Map<String, Object?>?
- Generic Mapper fonksiyonları
- Private record alias ile dosya içi temiz mimari
- Flutter kaynak kodundaki 411 typedef ve meşhur _TypeOf<T> taktiği
- 3 adet pekiştirme alıştırması

Zaman Kodları:
0:00 - Önceki Bölümün Alıştırma Çözümleri
1:30 - Hook: Typedef Neden Yeni Bir Tip Değildir?
3:00 - Ne Zaman Kullanılır / Ne Zaman Gerekmez?
4:00 - Yapı 1: Json Alias ve Object? Tercihi
7:30 - Yapı 2: Generic Mapper Typedef'leri
11:00 - Yapı 3: Private Record Alias ile Temiz Veri Ayrıştırma
14:00 - Yapı 4: Callback Sözleşmeleri vs Inline Tipler
15:30 - Flutter Framework'teki 411 Typedef & _TypeOf İncelemesi
17:30 - Linter Kuralları & Checklist
18:30 - Yeni Alıştırmalar (Ödevler)

Kodlar & Testler:
https://github.com/vb10/advance-dart-lang-course/tree/main/examples/lib/02_typedefs

#dart #flutter #typedef #cleancode #programming
```

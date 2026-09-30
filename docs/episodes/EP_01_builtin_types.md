# Bölüm 1 · Çekim Kartı: "'👋🏽'.length Neden 4? Herkesin Atladığı Temeller"

**Süre:** ~20 dakika  
**Format:** Standart Bölüm Döngüsü  
**Konu:** Built-in types, String/UTF-16/Grapheme, int/double/web, operatörler (`?..`, `~/`), `Never`, wildcard `_`.  
**Reference:** [`skills/dartadvance/references/01-builtin-types.md`](../../skills/dartadvance/references/01-builtin-types.md)

---

## 1. Zaman Çizelgesi & Canlı Akış

### 00:00 - 01:30 | Giriş
- Giriş, kanal selamlama ve serinin mantığını hatırlatma: "Her iddia testle kanıtlı, her yapı bir mimari ihtiyacı çözüyor."

### 01:30 - 03:00 | Hook (Shorts Formatı)
- **Ekran:** Sol pencerede test çalıştırılır:
  ```dart
  expect('👋🏽'.length, 4); // UTF-16 code units!
  expect('👋🏽'.characters.length, 1); // Grapheme cluster
  ```
- **Vurgu:** "Tek bir emoji ekranda 1 karakter gibi duruyor ama `.length` dediğinizde 4 dönüyor. Eğer bir SMS veya tweet karakter sınırı koyuyorsanız ve `.length` kullanıyorsanız uygulamanız bug dolu demektir!"

### 03:00 - 04:00 | Ne Zaman Kullan / Ne Zaman Gerekmez
| Kullan | Gerekmez / Başka Araç |
| --- | --- |
| Kullanıcıya görünen metin sınırı (UI) $\rightarrow$ `package:characters` | Dahili ASCII / slug işleme $\rightarrow$ `String.length` yeterli |
| Para hesabı $\rightarrow$ Kuruş/cent bazında `int` | `double` ile para hesabı $\rightarrow$ IEEE 754 yuvarlama hatası |
| Asla dönmeyen hata fırlatıcı $\rightarrow$ `Never` | Boş dönen fonksiyon $\rightarrow$ `void` |

### 04:00 - 15:00 | Yapı Döngüsü (Kod + Canlı AI Demoları)

#### Yapı 1: Grapheme vs String Length
- **Göster:** `examples/lib/01_builtin_types/grapheme_length.dart`
- **Test:** `dart test test/01_builtin_types/grapheme_test.dart`
- **Skill'e yaptır (Sağ pencere):**
  > "Bir bio metnini en fazla 10 kullanıcı karakteri (grapheme) olacak şekilde kesip sonuna '...' ekleyen bir yardımcı fonksiyon yaz ve testini oluştur."

#### Yapı 2: Tamsayı Bölme (`~/`) ve Negatif Sayı Tuzağı
- **Göster:** `examples/lib/01_builtin_types/integer_division.dart`
- **Test:** `dart test test/01_builtin_types/division_test.dart`
- **Vurgu:** `~/` sıfıra doğru yuvarlar (truncate): `-7 ~/ 2 == -3`. Python'daki `//` (`-4`) gibi değildir.

#### Yapı 3: Null-Aware Cascade (`?..`) & Wildcards (`_`)
- **Göster:** `examples/lib/01_builtin_types/cascades.dart` ve `wildcards.dart`
- **Vurgu:** Dart 3.7 ile gelen `_` artık re-declaration hatası vermez; birden çok kullanılmayan değişken için tek tip isimdir.

### 15:00 - 17:00 | Flutter Framework'ten Gerçek Kanıt
- Tarayıcıda aç: [flutter/src/services/text_formatter.dart#L442](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/text_formatter.dart#L442)
- Göster: Flutter'ın `LengthLimitingTextInputFormatter` sınıfı `characters` paketini kullanır. Uydurma değil, framework standardı!

### 17:00 - 18:00 | Linter & Kontrol Listesi
- `avoid_escaping_inner_quotes`
- `prefer_int_literals`
- Para tutarken asla `double` kullanma $\rightarrow$ `int minor units`.

### 18:00 - 20:00 | Pekiştirme: 3 Alıştırma (Gelecek Bölümün Ödevi)
1. **Kolay:** `formatPrice(int cents)` ile kuruşu TL'ye çevirme.
2. **Orta:** `UserProfile` bio kırpma (grapheme) ve web uyumlu yaş kontrolü.
3. **Zor:** `SafeAmount` ile `~/` ve `%` kullanarak güvenli para birimi ayrıştırma.
- Çözümler repo'da `practice/` altında; çözümler bir sonraki videonun ilk 2 dakikasında!

---

## 2. Shorts / Reels Senaryosu (60 Saniye)

```text
[Kamera Karşısı - 0-5 sn]:
"Dart'ta tek bir emojinin boyutu neden 4 çıkar?"

[Ekran Kaydı - 5-20 sn]:
"Bakın, 'el sallayan emoji' 👋🏽 ekliyorum. .length çağırıyorum: Sonuç 4!
Çünkü Dart String'leri UTF-16 code unit dizisidir. 
Ten rengi modifiyeri ve temel emoji ikişer birimden toplam 4 birim eder!"

[Ekran Kaydı - 20-45 sn]:
"Peki kullanıcı bunu nasıl görüyor? 1 karakter!
Bunu çözmek için Flutter ekibinin 'characters' paketini kullanıyoruz:
'👋🏽'.characters.length -> Sonuç tam 1!
Eğer TextField sınırlandırmanızda veya SMS doğrulamanızda düz .length kullanıyorsanız, 
emojiler metninizi kırpar veya patlatır."

[Kamera Karşısı - 45-60 sn]:
"Flutter'ın TextField kodu da aynen bu paketi kullanıyor.
İleri seviye Dart serisinin ilk bölümü kanalda yayında, link biyografide!"
```

---

## 3. YouTube Açıklama Metni (Description)

```text
Dart dilinde çoğu geliştiricinin "biliyorum" dediği ama production'da hatalara yol açan temel yapıları inceliyoruz!

Bu bölümde:
- '👋🏽'.length neden 4 çıkar? UTF-16, Runes ve Grapheme cluster farkı
- Para tutarken neden double kullanılmaz?
- Tamsayı bölme operatörü (~/) ve negatif sayı tuzağı
- Null-aware cascade (?..) ve modern wildcard (_) kullanımı
- Flutter kaynak kodunda LengthLimitingTextInputFormatter incelemesi
- 3 adet ödüllü pekiştirme alıştırması

Zaman Kodları:
0:00 - Giriş
1:30 - Hook: Emojilerin Gerçek Boyutu
4:00 - Yapı 1: Grapheme vs String Length (Canlı Demo)
8:30 - Yapı 2: ~/ Bölme Operatörü & Web Semantiği
12:00 - Yapı 3: ?.. Cascade ve Dart 3.7 Wildcard (_)
15:00 - Flutter Framework Kaynak Kod Kanıtı
17:00 - Linter & En İyi Pratikler
18:00 - Pekiştirme Alıştırmaları (Ödevler)

Alıştırma Çözümleri & Kodlar:
https://github.com/vb10/advance-dart-lang-course/tree/main/examples/lib/01_builtin_types

#dart #flutter #advancedart #utf16 #programming
```

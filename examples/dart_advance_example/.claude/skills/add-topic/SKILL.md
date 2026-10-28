---
name: add-topic
description: "dart_advance_example uygulamasına bir dartadvance bölümünü (01–08) ana sayfada butonu olan bir örnek sayfa olarak ekler: her kural gerçek bir Flutter ekranında, aynı girdiyle olumsuz (bozuk ekran) ve olumlu (düzgün ekran) yan yana, nedeni ekranda yazılı. Kullanıcı \"yeni topic ekle\", \"bölüm 02'yi ekle\", \"add-topic\", \"bu bölümün örnek sayfasını yap\" dediğinde ya da dartadvance Üret/bölüm promptunu bu projede çalıştırdığında kullan."
---

# add-topic

Bu proje YouTube videosunda ekranda açılır. İzleyici kartı görünce **hangi ekranın neden bozulduğunu** tek bakışta anlamalı.
Referans uygulama: `lib/features/01_builtin_types/`. Yeni bölümü onun kalıbıyla kur.

## Girdi

- Bölüm numarası (`01`–`08`). Kuralı ve senaryoyu `../../skills/dartadvance/rules/NN-*.md` içinden al; yalnız ilgili `## N.` bölümlerini oku (`grep -n "^## "`).
- Kuralın snippet'i `../../examples/lib/NN_*/` altındadır; uygulamadaki model aynı kuralı, aynı girdiyle gösterir.

## Kart kuralları

- **Gerçek ekran:** her kart bir Flutter ekranındaki işi anlatır (grup adı alanı, sepet özeti, OTP butonu, PATCH gövdesi…). "Demo", "örnek liste", sayı oyunu yok.
- **Hata başlıktaki özellik olmalı:** kartın başlığı `late final` diyorsa bozulmayı `late final` yapar; başka bir hata (cast, null) değil.
- **"Aynı sonuç, daha az kod" kartı yok.** İki taraf aynı çıktıyı veriyorsa o kural bu sayfaya girmez. Yalnız sözdizimi kısaltan özellik (`?..`, `_`) kural dosyasında kalır, kart olmaz.
- **Olumsuz taraf görünür biçimde bozuk:** kapalı buton, alan hatası, yanlış dilde çip, silinen alan, hata mesajı. Doğru sonucu veren kodu olumsuz yazma.
- **Hata fırlatan olumsuz kod** (`TypeError`, `FormatException`) örnek kurucuda `on <Tip> catch (e)` ile yakalanır ve mesajı önizlemede gösterilir; sayfa çökmez. Flutter'ın kendisi patlıyorsa (ör. yarım surrogate'ı `Text` ile çizmek) önizleme hata ikonu ve tooltip'le gösterir.
- Müşteri projelerinin adı ya da kodu hiçbir dosyada geçmez; yalnız kalıp kullanılır.

## Yapı

`<topic>` snake_case bölüm adıdır (ör. `builtin_types`); klasör `NN_<topic>`.

```
lib/features/NN_<topic>/
  model/
    <feature>.dart                       # kural başına BİR final class, Flutter import'u yok
  view/
    <topic>_view.dart                    # library: import'lar, part'lar (sıralı), ince StatelessWidget
    <topic>_examples.dart                # part: <Topic>Examples { build() => [_PriceExample().build(), ...] }
    example/NN_<feature>_example.dart    # part: kart başına BİR dosya: _<Feature>Example + _<Feature>Preview
test/features/NN_<topic>/
  <feature>_test.dart                    # kural başına bir model testi
  <topic>_view_test.dart                 # her sayfa açılır, istisna yok
```

Kart dosyası kart numarasıyla başlar (`01_price_example.dart`); klasörde sayfa sırasıyla dizilir, videoda kolay bulunur.
Kartın ekran parçası (`_<Feature>Preview`) aynı dosyadadır; ayrı `widget/` klasörü yok.

Top-level fonksiyon yok; `static` yalnız `const` sabit için. Kök dizine demo dosyası, `bolum_NN/` klasörü, `main()` kopyası yazma.

## Model

- Sınıf gerçek uygulama nesnesi: `GroupNameField`, `CartSummary`, `StoreLocation`. Üstünde bir `///` cümlesi: hangi ekran, hangi iş.
- Her kural için metot çifti `xxxWrong` ve `xxx`; aynı girdiyi alır. Üstlerinde en fazla iki satır:
  `// Olumsuz: <ne yapıyor> → <ekrandaki somut sonuç>` · `// Olumlu: <araç> <neden çözüyor>`.
- Dosya ≤ 50 satır. Sayaç gibi ölçüm alanı (`sorts`) olabilir.

## Kart: `TopicExample`

`lib/features/home/model/topic_example.dart` hazır; değiştirme. Yalnız üç alan var: `title`, `negative`, `positive`.
`negative` / `positive` ekran parçası widget'ıdır; açıklama, neden, kod satırı **yazılmaz** (onlar kural dosyasında ve artifact'ta).
Ekran kendini anlatmalı: bozuk taraf görünür biçimde bozuk, düzgün taraf aynı girdiyle doğru.

`_<Feature>Example.build()` girdiyi bir kez tanımlar, iki metodu aynı nesnede çağırır ve iki önizlemeye
aynı girdiyi verir. Başlık kısa ve kuralı söyler ("Fiyat: double değil kuruş int"); numara yazılmaz, sayfa sayacı gösterir.
Kartlar dart.dev'deki bölüm sırasıyla dizilir.

## View

- `<Topic>View` yalnız `TopicExamplesView(title:, examples:)` döndürür. O sayfa `PageView`: her kart bir sayfa, sağa kaydırınca sonraki; altta `‹ 3 / 12 ›`. Düzeni yeniden yazma.
- Önizleme widget'ları gerçek Material widget'ları kullanır (`TextFormField` + `errorText`, `FilledButton` `onPressed: null`, `ListTile`, `FilterChip`).
- Renk `Theme.of(context).colorScheme`'dan, boşluk `<Topic>View._gap` gibi `static const double`. Yanlış metodun adı `xxxWrong`; "naive" ya da "naif" kullanma.
- `lib/features/home/model/home_topic.dart` içindeki `homeTopics` listesine bölümü ekle; listede yoksa iş bitmemiştir.

## Test

- Model testi: aynı girdiyle olumsuz metodun yanlış, olumlu metodun beklenen sonucu (kural dosyasındaki **Kabul**'ün kanıtı).
- View testi: `chevron_right`'a basarak her sayfayı aç; başlık ve `N / toplam` görünür, `tester.takeException()` null.
  Bir test sola `drag` ile 2. sayfaya geçer. Önemli kartlarda iki tarafın metni ayrıca beklenir (ör. `'24999.9 ₺'` ve `'24.999,90 ₺'`).

## Bitir

1. `dart format .` · `flutter analyze` (sıfır sorun) · `flutter test`; çıktıyı göster.
2. Uygulama açıksa hot reload; yeni kartları simülatörde bir kez gör (geçici giriş dosyası kullandıysan sil).
3. Üç satır özet: hangi bölüm, hangi kartlar, her biri hangi ekran.

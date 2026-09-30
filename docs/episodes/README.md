# YouTube Çekim & Prodüksiyon Rehberi (Episode Cue Cards)

Bu klasör, **"Advance Dart"** serisinin her bölümü için hazırlanmış hazır çekim kartlarını (teleprompter / cue-sheet), ekran yerleşim düzenini, YouTube video açıklamalarını ve Shorts formatındaki dikey video senaryolarını içerir.

---

## 1. Ekran & Stüdyo Yerleşimi (Split-Screen Layout)

Her bölümde izleyiciye **"Göster $\rightarrow$ Anlat $\rightarrow$ Skill'e yaptır $\rightarrow$ Karşılaştır"** döngüsü yaşatılır.

```
+-------------------------------------------------------------------+
|                        1920x1080 / 4K (60 FPS)                    |
|                                                                   |
|   SOL PENCERE (%55 Genişlik)      |  SAĞ PENCERE (%45 Genişlik)   |
|   VS Code / Cursor                |  İkinci Proje & AI Agent      |
|   - Model dosya (≤50 satır)       |  (Terminal / Claude / Cursor) |
|   - İlgili test dosyası           |  - Boş Dart projesi           |
|   - Font boyutu: 18-20 pt         |  - Skill promptu girişi       |
|   - Tema: Temiz, yüksek kontrast  |  - Canlı kod üretimi & test   |
|                                   |                               |
+-------------------------------------------------------------------+
```

---

## 2. 20 Dakikalık Ritim Çizelgesi

```mermaid
gantt
    title Bölüm Zaman Çizelgesi (~20 Dk)
    dateFormat  m:s
    axisFormat %M:%S
    Önceki Bölüm Çözümü       :00:00, 90s
    Hook (Shorts Kancası)     :01:30, 30s
    Ne & Neden + Min. SDK     :02:00, 60s
    Ne Zaman / Gerekmez       :03:00, 60s
    Yapı Döngüsü (Kod + Demo) :04:00, 660s
    Flutter'da Gerçek Kanıt   :15:00, 120s
    Lint'ler & Kontrol Listesi:17:00, 60s
    Pekiştirme Alıştırmaları  :18:00, 120s
```

---

## 3. Bölüm Kartları Dizini

- [EP_00_intro_ai_dart.md](EP_00_intro_ai_dart.md) · **Bölüm 0:** AI'a Dart'ı Kanıtla Öğretmek (Güven Zinciri)
- [EP_01_builtin_types.md](EP_01_builtin_types.md) · **Bölüm 1:** `'👋🏽'.length` Neden 4? Herkesin Atladığı Temeller
- [EP_02_typedefs.md](EP_02_typedefs.md) · **Bölüm 2:** Typedef Yeni Tip DEĞİLDİR

---

## 4. Çekim Öncesi Hızlı Kontrol

Kayıt düğmesine basmadan önce terminalde çalıştırın:

```sh
dart pub get
dart run dartadvance_tool:dartadvance verify --all
dart run dartadvance_tool:dartadvance links
```

- [ ] Git temiz (`git status` $\rightarrow$ clean)
- [ ] Model dosya ve testi sol pencerede açık
- [ ] Tarayıcıda ilgili Flutter GitHub permalink'i hazır (tag: 3.47.5)
- [ ] Önceki bölüm alıştırma çözümü açık

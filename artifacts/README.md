# Artifacts

Kurs sayfalarının kaynağı. Her dosya claude.ai'de bir artifact olarak yayınlanır; değişiklik burada yapılır, aynı URL'ye yeniden yayınlanır.

| Dosya | Sayfa | URL |
| --- | --- | --- |
| [landing.html](landing.html) | Kurs haritası (bölüm ızgarası) | https://claude.ai/artifact/Tg9xgzVDeNbGvGjv4NA3yU |
| [01-built-in-types.html](01-built-in-types.html) | Bölüm 01 · Built-in types (13 kart) | https://claude.ai/artifact/1ftjaakLwccfcG1NVHanh3 |
| [03-class-design.html](03-class-design.html) | Bölüm 03 · Class tasarımı (annotation kartları 5–8) | https://claude.ai/artifact/L7uxuQD7VqgRJgjVHA61rM |
| [04-collection.html](04-collection.html) | Bölüm 04 · Collection (7 kart) | https://claude.ai/artifact/RCdHrWMCwiwTtRJLg8yDxE |

Bölüm sayfalarındaki kartlar akordeondur (aynı anda tek kart açık). Yeni sayfa `<article class="card">` ile yazılıp `python3 accordion.py <dosya>` ile dönüştürülür.

Kurallar:
- Bir bölüm sayfası `examples/dart_advance_example` uygulamasındaki kartlarla aynı sırada ve aynı başlıklarla durur; uygulamada kart değişirse sayfa da değişir.
- Yeni bölüm sayfası yayınlanınca `landing.html`'deki kartı linke çevir ve bu tabloya ekle.
- Müşteri projelerinin adı ya da kodu hiçbir sayfada geçmez.

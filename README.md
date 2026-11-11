# dartadvance

İleri seviye Dart: dil + Dart ekibinin core paketleri (collection, async, characters, meta).
Her özellik için **tek bir Dart dosyası** (ekranda gösterilir), kısa bir **kural** ve bir **skill**:
örneği gösterip anlatırsın, sonra skill aynı kuralı başka bir alanda sıfırdan yazar.

## Yapı

| Yol | Ne |
| --- | --- |
| `examples/lib/NN_konu/özellik.dart` | Gösterilen dosya: başında kendi projende kullanılacak prompt, sürpriz ekranda, bağımsız, ≤ 38 satır |
| `examples/test/NN_konu/` | Konunun testi (her iddia testle kanıtlı) |
| `skills/dartadvance/rules/NN-konu.md` | Kural: ne, ne zaman, ne zaman gerekmez, tuzak, skill promptu, kabul kriteri |
| `skills/dartadvance/SKILL.md` | Skill'in girişi: SDK kontrolü, nasıl çalışır, dizin |
| `examples/dart_advance_example/` | Flutter uygulaması: her kural gerçek bir ekranda, bozuk ve düzgün hali yan yana |
| `artifacts/` | Kurs sayfalarının HTML kaynağı (landing + bölüm sayfaları) |
| `docs/KONULAR.md` | Neden bu konular, neden bu sırada |
| `docs/FILMING.md` | Çekim notları: bölüm bölüm aç → söyle → izleyiciye prompt → kıyasla |
| `tool/` | Kural dosyalarındaki kodu `examples/`'tan dolduran ve doğrulayan CLI |

## Kurs sayfaları

- [Kurs haritası](https://claude.ai/artifact/Tg9xgzVDeNbGvGjv4NA3yU)
- [01 · Built-in types](https://claude.ai/artifact/1ftjaakLwccfcG1NVHanh3)
- [02 · Typedefs](https://claude.ai/artifact/61B94mB1hg7siYg4YJcgtb)
- [03 · Class tasarımı](https://claude.ai/artifact/L7uxuQD7VqgRJgjVHA61rM)
- [04 · Collection](https://claude.ai/artifact/RCdHrWMCwiwTtRJLg8yDxE)

Kaynak HTML ve tam liste: [artifacts/README.md](artifacts/README.md).

## Konular

01 Built-in types · 02 Typedefs · 03 Class tasarımı (modifier, annotation, library) · 04 Collection ·
05 Event loop ve Future · 06 Streams · 07 package:async · 08 Isolates

## Kurulum

```sh
dart pub get
ln -sfn "$PWD/skills/dartadvance" ~/.claude/skills/dartadvance   # skill her projede kullanılabilir
```

## Komutlar

`dart run dartadvance_tool:dartadvance <komut>` (repo kökünden):

| Komut | Ne yapar |
| --- | --- |
| `snippets [--check]` | Kural dosyalarındaki `<!-- snippet: id -->` bloklarını `examples/`'tan doldurur / kontrol eder |
| `verify <NN_konu>` / `verify --all` | format · analyze · test · snippet'ler güncel mi |
| `links` | Kural dosyalarındaki dart.dev `#anchor` linkleri canlı sayfada var mı |

## Yeni konu ekleme

1. Sıradaki numarayı al (boşluk yok).
2. dart.dev sayfasını oku; her özellik için `examples/lib/NN_konu/<özellik>.dart` yaz (bağımsız, ≤ 35 satır) ve tek test dosyası.
3. `rules/NN-konu.md` yaz; mevcut bir kural dosyasının iskeletini izle; kod yalnız snippet marker'ıyla.
4. `snippets` → `verify NN_konu` → `links`; SKILL.md dizinine ve `docs/FILMING.md`'ye ekle.

Sonraki konular: Generics · Null safety · Records · Patterns · Enhanced enums · Extension types · Constructors ·
Hata yönetimi · Iterables ve `sync*` · diğer core paketler.

# dartadvance

İleri seviye Dart: dil + Dart ekibinin core paketleri. Her konu bir agent skill reference'ı
(`skills/dartadvance`) ve bir YouTube bölümü. Her kod bloğu testli bir örnekten gelir; her konu pekiştirme
alıştırmalarıyla biter.

- Konular ve kapsam: [docs/CURRICULUM.md](docs/CURRICULUM.md)
- Video serisi ve çekim rehberi: [docs/SERIES.md](docs/SERIES.md)
- **Teknik Çekim Kartı (Cheat-Sheet):** [docs/YOUTUBE_CHEAT_SHEET.md](docs/YOUTUBE_CHEAT_SHEET.md)
- Bölüm çekim kartları: [docs/episodes/](docs/episodes/README.md)
- İzleyici alıştırma rehberi: [docs/PRACTICE.md](docs/PRACTICE.md)

## Kurulum

```sh
dart --version                                            # 3.13.x
dart pub get                                              # tüm workspace
dart run dartadvance_tool:dartadvance flutter-src sync    # flutter/flutter@3.47.5 sparse clone → .cache/flutter
ln -sfn "$PWD/skills/dartadvance" ~/.claude/skills/dartadvance   # skill'i her projede kullan
```

## Yapı

| Yol | Ne |
| --- | --- |
| `skills/dartadvance/SKILL.md` | Router: SDK kontrolü, sabit kararlar, katman → konu haritası |
| `skills/dartadvance/references/NN-*.md` | Konu anlatımı (numara = öğrenme sırası) |
| `examples/lib/NN_*/` | Konunun kodu (dosya başına tek kavram); `practice/` = alıştırma çözümleri |
| `examples/test/NN_*/` | Konunun testleri |
| `examples/lib/00_architecture/` | Ortak iskelet: `Result<T>`, `Failure`, UseCase, Repository |
| `tool/` | `dartadvance` CLI |

## Komutlar

`dart run dartadvance_tool:dartadvance <komut>` (repo kökünden):

| Komut | Ne yapar |
| --- | --- |
| `snippets [--check]` | Reference'lardaki `<!-- snippet: id -->` bloklarını `examples/`'tan doldurur / kontrol eder |
| `verify <NN_konu>` / `verify --all` | format · `analyze --fatal-infos` · test · snippet'ler güncel mi |
| `links` | Skill'deki her `https://dart.dev/...#anchor` canlı sayfada var mı |
| `flutter-src sync` / `grep [--json\|--count] <regex>` | Flutter kaynağında gerçek kullanım + sabit tag'li permalink |

## Yeni konu ekleme

1. Sıradaki numarayı al (boşluk bırakma): `NN`.
2. dart.dev'in raw markdown'ını oku (`dart-lang/site-www/src/content`); API için api.dart.dev.
3. `examples/lib/NN_konu/<kavram>.dart` (dosya başına tek kavram, ≤50 satır, az yorum) + `examples/test/NN_konu/`.
4. `skills/dartadvance/references/NN-konu.md`: `02-typedefs.md` iskeletini izle. Kod blokları yalnız snippet marker'ıyla.
5. **Skill ile üret** tarifleri (her yapı için) ve **Pekiştirme** (3 alıştırma; çözümler `practice/exN_*.dart` + testleri).
6. `snippets` → `verify NN_konu` → `links`; SKILL.md §3 ve CURRICULUM.md §1'e ekle.

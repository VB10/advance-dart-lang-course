# dartadvance

İleri seviye Dart: dil + Dart ekibinin core paketleri (collection, async, characters, meta).
Her özellik için **tek bir Dart dosyası** (ekranda gösterilir), kısa bir **kural** ve bir **skill**:
örneği gösterip anlatırsın, sonra skill aynı kuralı başka bir alanda sıfırdan yazar.

## Yapı

| Yol | Ne |
| --- | --- |
| `examples/lib/NN_konu/özellik.dart` | Gösterilen dosya: tek kavram, bağımsız, ≤ 35 satır |
| `examples/test/NN_konu/` | Konunun testi (her iddia testle kanıtlı) |
| `skills/dartadvance/rules/NN-konu.md` | Kural: ne, ne zaman, ne zaman gerekmez, tuzak, skill promptu, kabul kriteri |
| `skills/dartadvance/SKILL.md` | Skill'in girişi: SDK kontrolü, nasıl çalışır, dizin |
| `docs/FILMING.md` | Çekim notları: bölüm bölüm aç → söyle → skill'e ver → kıyasla |
| `tool/` | Kural dosyalarındaki kodu `examples/`'tan dolduran ve doğrulayan CLI |

## Konular

01 Built-in types · 02 Typedefs · 03 Class modifiers · 04 Libraries ve metadata · 05 Koleksiyonlar ·
06 Event loop ve Future · 07 Streams · 08 package:async · 09 Isolates

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

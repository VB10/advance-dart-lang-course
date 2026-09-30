# YouTube serisi: "Advance Dart"

**Bölüm N = Konu N** (`skills/dartadvance/references/NN-*.md`). Her bölüm tek başına izlenebilir.
Rakamlar repodan doğrulandı; çekimden önce §5'teki kontrolü çalıştır.
Hazır çekim kartları ve YouTube açıklamaları: [docs/episodes/](episodes/README.md) · İzleyici alıştırma rehberi: [docs/PRACTICE.md](PRACTICE.md).

---

## 1. Her bölümün iskeleti (~20 dk)

| Dakika | Parça | Kaynak |
| --- | --- | --- |
| 0:00 | **Önceki bölümün alıştırma çözümü** (1–2 dk) | önceki konunun `practice/` dosyaları + testleri |
| 1:30 | **Hook:** testle kanıtlanan bir sürpriz | reference'taki "yanlış varsayımlar" / Flutter tablosu |
| 2:00 | Ne ve neden + min. dil sürümü | reference başlığı |
| 3:00 | Ne zaman kullan / ne zaman gerekmez | reference tablosu |
| 4:00 | **Yapı döngüsü** (her yapı için tekrar, aşağıda) | `examples/lib/NN_*` + "Skill ile üret" |
| 15:00 | Flutter'da gerçek kullanım (permalink'ten canlı) | reference Flutter tablosu |
| 17:00 | Lint'ler + kontrol listesi | reference sonu |
| 18:00 | **Pekiştirme:** 3 alıştırmayı ver, çözüm sonraki bölümde | reference "Pekiştirme" |

**Yapı döngüsü:** bölümdeki her yapı (ör. broadcast stream, `CancelableOperation`) için ~3 dk:

1. **Göster:** model dosyayı aç (tek kavram, ≤50 satır). Testini çalıştır: `cd examples && dart test test/NN_*/<dosya>_test.dart`.
2. **Anlat:** 1–2 cümle, neden ve ne zaman.
3. **Skill'e yaptır:** ikinci pencerede (boş bir Dart projesi ya da kendi projen) reference'taki **"Tarif → Demo promptu"**nu
   yapıştır. Skill Görev modunda (SKILL.md §4) şunları yapar: SDK kontrolü → model dosyayı okur → başka alanda kod
   yazar → test yazar → `format` / `analyze` / `test` çalıştırır.
4. **Karşılaştır:** skill'in ürettiği kod aynı kuralı izliyor mu (kabul kriteri testte kanıtlı mı)?

> Canlı demodan önce promptu bir kez dene; AI çıktısı her seferinde birebir aynı olmaz.
> Demo projesi için: `dart create -t console demo_app` (gerekirse `dart pub add collection async`).

## 2. Bölümler

### Bölüm 0 · Tanıtım: "AI'a Dart'ı kanıtla öğretmek" (~10 dk; uzun kulis hali serinin sonuna)
- **Problem:** AI API uyduruyor, SDK sürümünü bilmiyor, Flutter örneklerini kendisi yazıyor.
- **Çözüm, güven zinciri:** dart.dev → `examples/` → test → `snippets` → canlı link kontrolü.
  Hiçbir kod bloğu elle yazılmadı.
- **Canlı demo:**
  1. `examples/lib/02_typedefs/json_alias.dart` dosyasının sonuna `typedef JsonMap = Json;` satırını ekle.
  2. `dart run dartadvance_tool:dartadvance verify 02_typedefs`
     → `verify(02_typedefs): FAILED at snippets`
  3. `dart run dartadvance_tool:dartadvance snippets` → tekrar `verify` → PASSED.
     Değişiklik reference'a kendiliğinden geçti. Sonra `git checkout .` ile geri al.
- **SDK guard:** skill önce `pubspec`'i okur. 3.8 projesine 3.10 özelliği (dot shorthands) önermez.

### 1. Sezon: hazır

| # | Başlık önerisi | Hook | Mimari bağ | Flutter kanıtı |
| --- | --- | --- | --- | --- |
| 1 | "`'👋🏽'.length` neden 4? Herkesin atladığı temeller" | `length` UTF-16, `characters` ile 1 | JSON'da sayı, UI'da metin kırpma | `TextField` → `characters.length` |
| 2 | "Typedef yeni tip DEĞİLDİR" | `typedef UserId = int` her int'i alır | `Json`, `Mapper`, callback | 411 typedef, `_TypeOf<T> = T` |
| 3 | "`sealed` alt sınıflara geçmez" | `DragGestureRecognizer` sealed, alt sınıfları düz | Repository, UseCase, sealed UI state | `base PipelineOwner` → `final` alt sınıf |
| 4 | "Privacy sınıfa değil library'ye göredir" | Docs'ta `part` bölümü yok | Barrel export ile feature API'si | 871 export, `part` yalnız animated icons |
| 5 | "`firstWhereOrNull` core'da değil!" | `firstOrNull` core, `firstWhereOrNull` paket | Entity eşitliği, değiştirilemez state | Scheduler'da `HeapPriorityQueue` |
| 6 | "Dart'ta kod hangi sırayla çalışır?" | sync → microtask → `Timer.run` → `Future()` | Paralel istek + timeout → Failure | `SynchronousFuture`, `endOfFrame` |
| 7 | "Stream: tek abonelik mi broadcast mi?" | Cancel sonrası da ikinci listen hata | `Stream<Result<T>>`, `dispose` → `cancel` | `StreamBuilder` dispose |
| 8 | "Future iptal edilemez, ama bu edilir" | Arama kutusunda eski sonuç yeniyi ezer | Son sorgu kazanır, tek seferlik init | Autocomplete'in elle yazılmış sayacı |
| 9 | "Web'de isolate yok!" | `compute` web'de aynı event loop'ta | Ağır parse → `Isolate.run` + eşik | `asset_bundle.dart` 50 KB eşiği |

### Sonraki sezonlar
[CURRICULUM.md](CURRICULUM.md) §1'deki "İleride" listesi sırasıyla (Generics → … → diğer core paketler).
Her konu yazılınca sıradaki bölüm numarasını alır.

## 3. Yayın ritmi

- Haftada 1 bölüm. 1. Sezon ~2 ay; bu sürede sonraki konular yazılır.
- Her bölümün hook'u ayrıca **Shorts** olur (30–60 sn, tek test, tek sürpriz).
- Alıştırma çözümü bir sonraki bölümün başında gösterilir. Bu, izleyicinin seriyi takip etmesini sağlar.

## 4. Bunları söyleme (doğrulanmadı)

| Söyleme | Doğrusu |
| --- | --- |
| "Enhanced parts kullanılabilir" | SDK CHANGELOG'da yok |
| "Const widget rebuild'i hızlandırır" | Bu repoda kanıtlanmadı |
| "Parayı double tutmak yanlış" | Docs yalnız IEEE 754 der; int minor unit bizim önerimiz |
| "Deferred loading VM'de şöyle çalışır" | Docs yalnız web'i anlatır |
| "I/O için isolate gerekir" | Docs, worker'ın I/O *yapabileceğini* söyler |
| "Web'deki sayı davranışını test ettik" | Testler VM'de; web kısmı docs tablosundan |
| "`HeapPriorityQueue` aynı öncelikte FIFO'dur" | Değil (test) |

## 5. Çekimden önce

```sh
dart pub get
dart run dartadvance_tool:dartadvance flutter-src sync
dart run dartadvance_tool:dartadvance verify --all     # verify(all): PASSED
dart run dartadvance_tool:dartadvance links            # tüm anchor'lar OK
```

- [ ] Repo commit'lenmiş (demo için `git checkout .` gerekebilir)
- [ ] Bölümün reference'ı, `examples/lib/NN_*` ve testi açık
- [ ] Flutter permalink'leri tarayıcıda açık (tag 3.47.5)
- [ ] Önceki bölümün `practice/` çözümü hazır

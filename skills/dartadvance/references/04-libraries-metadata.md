# 04 · Libraries, imports, part ve metadata

> Kaynak: https://dart.dev/language/libraries ·
> https://dart.dev/language/metadata ·
> https://dart.dev/language/versioning#library-override ·
> https://dart.dev/tools/pub/create-packages#organizing-a-package ·
> https://dart.dev/tools/pub/package-layout#implementation-files
> Effective Dart: https://dart.dev/effective-dart/usage#do-use-strings-in-part-of-directives,
> https://dart.dev/effective-dart/usage#dont-import-libraries-that-are-inside-the-src-directory-of-another-package,
> https://dart.dev/effective-dart/style#dont-explicitly-name-libraries,
> https://dart.dev/effective-dart/documentation#consider-writing-a-library-level-doc-comment
> API: [`Deprecated`](https://api.dart.dev/dart-core/Deprecated-class.html),
> [`pragma`](https://api.dart.dev/dart-core/pragma-class.html),
> [`package:meta`](https://pub.dev/documentation/meta/latest/meta/meta-library.html),
> [`Target`](https://pub.dev/documentation/meta/latest/meta_meta/Target-class.html)
> Min. dil sürümü: `import`/`export`/`show`/`hide`/`as`/`deferred as`/`part` her sürümde;
> **`part of '<uri>'` 2.0** (SDK CHANGELOG 2.0.0); **isimsiz `library;` 2.19** (SDK CHANGELOG 2.19.0);
> **wildcard prefix `as _` 3.7** (wildcard variables);
> **`@Deprecated.extend/implement/subclass/mixin/instantiate` 3.10** (SDK CHANGELOG 3.10.0).

**Library = dosya (+ `part`'ları).** Dart'ta `public`/`private`/`protected` anahtar kelimesi
yok; `_` ile başlayan her isim **library'ye** özeldir, sınıfa değil. Aynı dosyadaki iki
sınıf birbirinin `_` üyelerini görür; paketteki başka bir dosya (test dahil) göremez
([libraries](https://dart.dev/language/libraries)). Bütün kararlar bu cümleden çıkar:
06'daki class modifier kısıtları da library sınırında işler.

## Resmi dokümantasyondaki boşluk: `part`

Dil turundaki [Libraries & imports](https://dart.dev/language/libraries) sayfasında
**`part` / `part of` için bir bölüm yok**; sadece
[Implementing libraries](https://dart.dev/language/libraries#implementing-libraries)
altındaki link listesinde "When to use the `part` directive" diye geçer ve
Create Packages'a yönlendirir. Resmi bilgi üç yere dağılmış durumda:

| Kaynak | Ne söylüyor |
| --- | --- |
| [Create packages › Organizing a package](https://dart.dev/tools/pub/create-packages#organizing-a-package) (not kutusu: "You might know about the `part` directive") | `part` bir library'yi birden çok dosyaya böler; part dosyaları üretilmiş kodu library'ye katabilir, **ama Dart ekibi kullanılmasını önermiyor; bunun yerine küçük library'ler oluştur.** |
| [Effective Dart › DO use strings in `part of` directives](https://dart.dev/effective-dart/usage#do-use-strings-in-part-of-directives) | "Birçok Dart geliştiricisi `part`'tan tamamen kaçınır"; kullanılacaksa part dosyası library'yi **isimle değil URI string'iyle** gösterir: `part of '../../my_library.dart';` |
| [Dart SDK CHANGELOG 2.0.0](https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md) › Language | `part of "uri.dart";` sözdizimi 2.0'da geldi: `library` bildirimi (dolayısıyla adı) olmayan library'lerin de part'ı olabilsin ve araçlar bir part'ın library'sini kolayca bulsun diye. İsimli `part of name;` sözdizimi "supported but deprecated". |

Bir part dosyası kendi `import`'unu yazamaz; library'nin import'larını ve private
isimlerini paylaşır (aşağıdaki mekanizma örneği). "Kendi import'u olan part"
(enhanced parts) SDK CHANGELOG'unda **yer almıyor**; yayınlanmış bir özellik gibi
önerme.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
| --- | --- |
| İki isim çakışıyor (`User` hem v1 hem v2'de) → birine prefix: `import '...' as v1;` | Çakışma yoksa prefix zorunlu değil; ama `dart:math as math` gibi okunurluk için prefix de meşru ([Effective Dart style](https://dart.dev/effective-dart/style#do-name-import-prefixes-using-lowercase_with_underscores)) |
| Bir library'den tek bir ismi dışarıda bırakmak → `hide`; birkaçını almak → `show` ([importing only part](https://dart.dev/language/libraries#importing-only-part-of-a-library)) | Sırf "temiz görünsün" diye her import'a `show` yazma; bakım yükü getirir |
| Paket/feature'ın public API'si → üst seviyede barrel dosyası + `export ... show` (shelf örneği, [organizing-a-package](https://dart.dev/tools/pub/create-packages#organizing-a-package)) | Her klasöre barrel koyma; barrel **sınır** (paket, feature) içindir, her dizin için değil |
| Uygulama detayı → `lib/src/` altı ([implementation-files](https://dart.dev/tools/pub/package-layout#implementation-files)) | Başka paketin `src/`'sini import etme ([Effective Dart](https://dart.dev/effective-dart/usage#dont-import-libraries-that-are-inside-the-src-directory-of-another-package)) |
| **Üretilmiş kod** (`*.g.dart`, `*.freezed.dart`) → `part` + `part of '<uri>'` | El yazımı kodu `part` ile bölmek → **küçük library'ler** (Create packages notu). Private paylaşımı gerekiyorsa aynı dosyada tut |
| Library seviyesinde doc comment veya annotation → `library;` ([library-directive](https://dart.dev/language/libraries#library-directive)) | Doc comment/annotation yoksa `library;` gereksiz (`unnecessary_library_directive`); `library isim;` ise legacy ([style](https://dart.dev/effective-dart/style#dont-explicitly-name-libraries)) |
| Web'de nadir kullanılan ekran/özellik → `deferred as` + `loadLibrary()` | `dart` aracı web dışı hedeflerde deferred loading'i **desteklemez**; Flutter mobilde [deferred components](https://docs.flutter.dev/perf/deferred-components) ayrı bir mekanizmadır |
| Tek bir dosyayı eski dil sürümünde tutmak (migrasyon) → `// @dart = 3.x` | Yeni kodda asla; varsayılan sürüm pubspec SDK alt sınırıdır |
| Analyzer'a niyet bildirmek → `@immutable`, `@useResult`, `@protected`, `@mustCallSuper`, `@visibleForTesting` | Runtime davranışı beklemek: bu reference'taki annotation'ların hiçbiri çalışan kodu değiştirmez; onları analyzer veya bir code generator okur |

## Mimarideki yeri

| Katman / sınır | Kullanım |
| --- | --- |
| Feature modülü | `features/profile/profile.dart` barrel: yalnızca domain tipleri + use case + composition fonksiyonu `export ... show`; data implementasyonu export edilmez |
| Melos / pub workspace paketleri | Her feature/core ayrı paket olduğunda `lib/src/` konvansiyonu **gerçek** sınır olur: `implementation_imports` (recommended) başka paketin `src/`'sine import'u yakalar; `@internal` paket dışı kullanımı yakalar |
| Tek paketli uygulama | `features/x/src/` yalnızca **ekip konvansiyonudur**: aynı paket içinde hiçbir lint `src/` import'unu engellemez. Sınırı zorlamak istiyorsan feature'ı pakete çıkar |
| Domain / Entity | `@immutable` değer sınıfları; `@useResult` "yeni nesne döner" metotları (`Money.add`) |
| Application / Notifier·Store | Taban sınıfta `@protected emit`, `@mustCallSuper dispose`, `@visibleForTesting` sayaçlar |
| Data / Model | `@JsonSerializable`/`@freezed` + `part 'x.g.dart';` / `part 'x.freezed.dart';` (üretilmiş kodun tek meşru `part` kullanımı) |
| Core | `Result`/`Failure` ayrı library; feature barrel'ları core'u **yeniden export etmez**, tüketici core'u kendisi import eder |
| Framework katkısı / paylaşılan paket | Library doc comment (`library;` üstünde), `@Deprecated('mesaj')` ile kademeli kaldırma, `lib/<paket>.dart` ana barrel |

## Doğrulanmış örnekler

Tüm kod `examples/lib/04_libraries_metadata/` altında, testleri
`examples/test/04_libraries_metadata/` altında
(`dart run dartadvance_tool:dartadvance verify 04_libraries_metadata`).
Başka library'den `_x`'e erişim, `@protected` üyeyi dışarıdan çağırma gibi **hatalı**
kullanımlar kod olarak değil, metinde anlatılır; analyzer'ın ürettiği tanılar
(diagnostic kodları) aşağıda adıyla verilmiştir.

### Privacy library'ye aittir, sınıfa değil

Library doc comment'i ve annotation'ları `library;` direktifinin üstüne gelir
([library-directive](https://dart.dev/language/libraries#library-directive),
[doc comment](https://dart.dev/effective-dart/documentation#consider-writing-a-library-level-doc-comment)).
`WalletAuditor` ayrı bir sınıf olduğu hâlde aynı dosyada olduğu için `_balanceCents`'i
okuyup yazar: `friend`, `internal` veya getter gerekmez.

<!-- snippet: 04_libraries_metadata/privacy/wallet -->
```dart
/// Wallet domain: the balance can only change through this library.
///
/// Privacy is per LIBRARY, not per class: [WalletAuditor] below reads and
/// writes `Wallet._balanceCents` directly.
library;

final class Wallet {
  Wallet(this._balanceCents);

  int _balanceCents;

  int get balanceCents => _balanceCents;

  void spend(int cents) => _balanceCents -= cents;
}

final class WalletAuditor {
  const WalletAuditor();

  bool isOverdrawn(Wallet wallet) => wallet._balanceCents < 0;

  void writeOff(Wallet wallet) {
    if (isOverdrawn(wallet)) wallet._balanceCents = 0;
  }
}
```

Test dosyası ayrı bir library'dir: orada `wallet._balanceCents` yazmak
`undefined_getter` derleme hatasıdır; test yalnızca `balanceCents`/`spend`/`writeOff`
üzerinden davranışı doğrular.

### `part`: mekanizma örneği (el yazımı, yalnızca gösterim)

Aşağıdaki çift, bir part'ın library'nin **import'larını ve private üyelerini
paylaştığını** göstermek içindir. El yazımı kodda Dart ekibinin önerisi `part` değil,
küçük library'lerdir (yukarıdaki tablo).

<!-- snippet: 04_libraries_metadata/part_demo/order_builder -->
```dart
import 'dart:collection';

part 'order_builder_lines.dart';

final class OrderBuilder {
  final Queue<_Line> _lines = Queue<_Line>();

  void add(String sku, {int quantity = 1}) => _addLine(this, sku, quantity);

  int get totalQuantity => _lines.fold(0, (sum, line) => sum + line.quantity);

  List<String> get skus => [for (final line in _lines) line.sku];
}
```

<!-- snippet: 04_libraries_metadata/part_demo/order_builder_lines -->
```dart
// No imports here: `Queue` comes from the library's `dart:collection` import.
part of 'order_builder.dart';

final class _Line {
  const _Line(this.sku, this.quantity);
  final String sku;
  final int quantity;
}

void _addLine(OrderBuilder builder, String sku, int quantity) {
  final Queue<_Line> lines = builder._lines;
  lines.addLast(_Line(sku, quantity));
}
```

Part dosyasının kendi import'u yok: `Queue` library'nin `dart:collection` import'undan gelir.
`_addLine` `OrderBuilder._lines`'a dokunur, `OrderBuilder` da part'taki `_Line`/`_addLine`'ı
kendi dosyasındaymış gibi görür. Library dosyasında `library;` yok: URI'li `part of` sayesinde isimsiz library'nin de
part'ı olabilir (CHANGELOG 2.0). Üretilmiş kodda da aynı yapı kurulur:
`user.dart` içinde `part 'user.g.dart';`, üretilen dosyada `part of 'user.dart';`.
Üretilmiş dosyayı elle düzenleme; generator'ı yeniden çalıştır.

### Prefix, `show`, `hide`, wildcard prefix

İki library aynı üç ismi (`User`, `parseUser`, `apiVersion`) bildiriyor. İkisini
prefix'siz import etmek, isimler **kullanıldığı anda** `ambiguous_import` derleme hatası verir
(import satırının kendisi hata değildir;
[specifying-a-library-prefix](https://dart.dev/language/libraries#specifying-a-library-prefix)).

<!-- snippet: 04_libraries_metadata/imports/user_migration -->
```dart
import 'dart:math' as math;

import 'api_v1.dart' as v1;
import 'api_v2.dart' hide apiVersion;
import 'string_case.dart' as _; // Binds no name; its extensions still apply.

User migrateUser(v1.User legacy, {required int id}) =>
    User(id: id, displayName: legacy.name.capitalized);

Object parseAny(Map<String, Object?> json) => switch (json['version']) {
  v1.apiVersion => v1.parseUser(json),
  _ => parseUser(json),
};

int longestName(Iterable<User> users) =>
    users.fold(0, (longest, user) => math.max(longest, user.displayName.length));
```

- `v1` yalnızca `v1.` prefix'iyle erişilir; v2 prefix'siz ama `hide apiVersion` ile tek bir
  isim kapsam dışında bırakılır. SDK import'unda prefix (`math.max`) okunurluk içindir.
- `v1.apiVersion` prefix'li bir sabit olduğu için switch'te **constant pattern** olarak
  kullanılabilir.
- `as _` (3.7+): "Import prefixes with the wildcard name `_` are non-binding, but will
  provide access to the non-private extensions in that library"
  ([specifying-a-library-prefix](https://dart.dev/language/libraries#specifying-a-library-prefix),
  [wildcard-variables](https://dart.dev/language/variables#wildcard-variables)).
  Yani yalnızca extension'ları için import edilen bir library kapsama hiçbir isim sokmaz.
- Prefix'ler `lowercase_with_underscores` ve `_` ile başlamaz (`library_prefixes`,
  `no_leading_underscores_for_library_prefixes`; ikisi de recommended).

### Feature barrel: `export ... show` ile public API

Kural: tüketici **yalnızca barrel'ı** import eder; `src/` altı uygulama detayıdır.
shelf'in `lib/shelf.dart` dosyası da her export'u `show` ile sınırlar, "amaçlanandan
fazla API açmamak için" ([organizing-a-package](https://dart.dev/tools/pub/create-packages#organizing-a-package)).

```
feature_profile/
  profile.dart                              ← barrel (tek public giriş)
  src/domain/profile.dart                   ← Profile
  src/domain/profile_repository.dart        ← ProfileRepository
  src/domain/get_profile.dart               ← GetProfile
  src/data/in_memory_profile_repository.dart← export EDİLMEZ
  src/profile_module.dart                   ← createGetProfile (composition)
```

<!-- snippet: 04_libraries_metadata/feature_profile/profile -->
```dart
/// Public API of the profile feature: consumers import ONLY this file.
@FeatureApi('profile')
library;

import '../metadata/feature_api.dart';

export 'src/domain/get_profile.dart' show GetProfile;
export 'src/domain/profile.dart' show Profile;
export 'src/domain/profile_repository.dart' show ProfileRepository;
export 'src/profile_module.dart' show createGetProfile;
```

Barrel'ın tek bildiği data tipi composition fonksiyonunun içinde:

<!-- snippet: 04_libraries_metadata/feature_profile/src/profile_module -->
```dart
import 'data/in_memory_profile_repository.dart';
import 'domain/get_profile.dart';
import 'domain/profile.dart';

/// The only exported function that knows the data implementation.
GetProfile createGetProfile({Map<int, Profile> seed = const {}}) =>
    GetProfile(InMemoryProfileRepository(Map.of(seed)));
```

<!-- snippet: 04_libraries_metadata/feature_profile/src/data/in_memory_profile_repository -->
```dart
import '../../../../00_architecture/result.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';

/// Not exported by the barrel: no other feature can name this type.
final class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this._profiles);
  final Map<int, Profile> _profiles;

  @override
  Future<Result<Profile>> fetch(int id) async {
    final profile = _profiles[id];
    return profile == null ? const Err(ServerFailure(404)) : Ok(profile);
  }
}
```

Test (başka bir library) yalnızca barrel'ı + core `Result`'ı import eder; `GetProfile`'ı
kendi fake `ProfileRepository`'si ile kurabilir, `createGetProfile` ile gerçek wiring'i
kullanabilir, ama `InMemoryProfileRepository` adını **göremez**. Directive sırası
Effective Dart'a uyar: önce import'lar, sonra ayrı blokta export'lar
([ordering](https://dart.dev/effective-dart/style#ordering)).

Not: bu örnek repo'da `src/` feature klasörünün içinde. Gerçek bir pakette konvansiyon
paket kökündeki `lib/src/`'dir; `implementation_imports` ve `@internal` bu konuma
göre çalışır. Barrel'dan export edilen her şey paketin public API'sidir: bir `show`
listesine isim eklemek kolay, çıkarmak kırıcıdır.

**Koşullu export** (platforma göre implementasyon) aynı barrel mantığıyla çalışır:
`export 'src/hw_none.dart' if (dart.library.io) 'src/hw_io.dart' if (dart.library.js_interop) 'src/hw_web.dart';`
Tüm seçeneklerin aynı API'yi sağlaması gerekir
([conditionally-importing-and-exporting-library-files](https://dart.dev/tools/pub/create-packages#conditionally-importing-and-exporting-library-files)).

### Import yolları

[Effective Dart](https://dart.dev/effective-dart/usage#dont-allow-an-import-path-to-reach-into-or-out-of-lib):
`lib/` dışından (ör. `test/`) `lib/` içine **`package:`** ile gir; `../lib/...` yazma
(Dart bunları iki ayrı library sayar). `lib/` içinde birbirini import eden dosyalar için
[relative import tercih edilir](https://dart.dev/effective-dart/usage#prefer-relative-import-paths).

### Deferred loading (web)

Docs'un söylediği ([lazily-loading-a-library](https://dart.dev/language/libraries#lazily-loading-a-library)):

- Amaç: web uygulamasının açılış süresini azaltmak, A/B testi, nadir kullanılan
  ekran/dialog'ları gerektiğinde indirmek.
- **"The `dart` tool doesn't support deferred loading for targets other than web."**
  Flutter uygulamalarında Flutter'ın [deferred components](https://docs.flutter.dev/perf/deferred-components)
  rehberine bakılır.
- `loadLibrary()` birden çok kez çağrılabilir; library bir kez yüklenir. `Future` döner.
- Deferred library'nin sabitleri import eden dosyada sabit değildir; **tipleri import eden
  dosyada kullanılamaz**: arayüz tipini iki tarafın da eager import ettiği bir library'ye taşı.

Aşağıdaki kod analyzer'dan temiz geçer (derlenir), ancak test edilmez: VM'deki
davranışı docs'ta tanımlı değil.

<!-- snippet: 04_libraries_metadata/deferred/report_contract -->
```dart
/// Imported eagerly by both sides: a deferred library's types can't be used as types.
abstract interface class ReportView {
  String render();
}
```

<!-- snippet: 04_libraries_metadata/deferred/reports_screen -->
```dart
import 'report_contract.dart';

final class ReportsScreen implements ReportView {
  const ReportsScreen();

  @override
  String render() => 'Reports';
}

ReportView createReportsScreen() => const ReportsScreen();
```

<!-- snippet: 04_libraries_metadata/deferred/app_shell -->
```dart
import 'report_contract.dart';
import 'reports_screen.dart' deferred as reports;

Future<ReportView> openReports() async {
  await reports.loadLibrary(); // Safe to call repeatedly; loads once.
  return reports.createReportsScreen();
}
```

### Library başına dil sürümü

Paketteki her library varsayılan olarak pubspec SDK kısıtının **alt sınırı** olan dil
sürümünü kullanır. Bir library `//` yorumuyla daha eski bir sürüme sabitlenebilir;
`///` veya `/*` olmaz, Dart kodundan önce gelmeli, öncesinde başka yorum olabilir
([library-override](https://dart.dev/language/versioning#library-override)).
Bu bir **migrasyon aracıdır** (docs'taki örnek: null safety'ye dosya dosya geçiş).
Aşağıdaki dosya 3.9'a sabitli, paketin geri kalanı pubspec alt sınırını (3.13) kullanır;
3.9'dan yeni özellikler (ör. dot shorthands, 3.10) bu dosyada derleme hatasıdır.

<!-- snippet: 04_libraries_metadata/versioning/legacy_formatter -->
```dart
// Formats amounts for the legacy export.
// @dart = 3.9

/// Pinned to 3.9: dot shorthands (3.10) are compile errors in this file.
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  return '$sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
}
```

### Metadata: yerleşik annotation'lar

[Built-in annotations](https://dart.dev/language/metadata#built-in-annotations): tüm
Dart kodunda import gerektirmeden kullanılır.

| Annotation | Anlamı (docs / API) |
| --- | --- |
| `@Deprecated('mesaj')` | Kaldırılacak; mesaj alternatifi ve kaldırılma zamanını söylemeli. `provide_deprecation_message` (core) mesajsız kullanımı yakalar |
| `@Deprecated.extend()` / `.implement()` / `.subclass()` / `.mixin()` / `.instantiate()` | Yalnızca o **kullanım biçimi** deprecated (3.10, CHANGELOG). 06'daki class modifier'ı eklemeden önce kullanıcılara bir sürüm uyarı vermek için |
| `@Deprecated.optional()` | Parametreyi **vermemek** deprecated (ileride required olacak). metadata sayfasında ve SDK 3.13'ün `annotations.dart`'ında var; SDK CHANGELOG'unun 3.10 listesinde **geçmiyor** |
| `@deprecated` | Süresi belirsiz deprecation; docs `@Deprecated` + mesajı tercih ettirir |
| `@override` | Üst tip üyesini override/implement eder; `annotate_overrides` (recommended) |
| `@pragma('ad', [opsiyon])` | Derleyici/araçlara ipucu. Genel kullanıma açık VM pragma'ları (`vm:prefer-inline`, `vm:never-inline`, `vm:entry-point`...) [SDK runtime/docs/pragmas.md](https://github.com/dart-lang/sdk/blob/main/runtime/docs/pragmas.md)'de listeli; ölçmeden performans pragma'sı ekleme |

<!-- snippet: 04_libraries_metadata/metadata/deprecated -->
```dart
class Television {
  /// Use [turnOn] to turn the power on instead.
  @Deprecated('Use turnOn instead')
  void activate() {
    turnOn();
  }

  /// Turns the TV's power on.
  void turnOn() {
    isOn = true;
  }

  bool isOn = false;
}
```

(dart.dev örneği; `// ···` yerine test edilebilsin diye `isOn` eklendi.)

### Metadata: `package:meta` (analyzer destekli)

Anlamlar [meta API docs](https://pub.dev/documentation/meta/latest/meta/meta-library.html)'tan
(meta 1.19.0); tanı kodları bu repo'da analyzer ile doğrulandı
([analyzer-supported-annotations](https://dart.dev/language/metadata#analyzer-supported-annotations)).

| Annotation | Anlamı | İhlalde tanı |
| --- | --- | --- |
| `@immutable` | Sınıf ve **tüm alt tipleri** immutable: miras alınanlar dahil tüm instance alanları `final` | `must_be_immutable` |
| `@useResult` | Metot/getter/fonksiyonun değeri kullanılmalı (atama, argüman, return, koleksiyon, koşul, invocation hedefi...) | `unused_result` |
| `@protected` | Instance üye yalnızca bildirildiği library'den ve alt tiplerin instance üyelerinden, `this` üzerinden kullanılmalı | `invalid_use_of_protected_member` |
| `@mustCallSuper` | Override eden üye, override edilen implementasyonu çağırmadan dönemez; override'lar da örtük olarak işaretlenir | `must_call_super` |
| `@visibleForTesting` | Yalnızca testler için public; tanımlandığı library ve paketin `test/` klasörü dışında kullanım uyarılır | `invalid_use_of_visible_for_testing_member` (analyzer tanısı, lint değil) |
| `@visibleForOverriding` | Override edilebilsin diye public; tanımlandığı library dışından **referans** uyarılır | `invalid_use_of_visible_for_overriding_member` |
| `@nonVirtual` | Instance üye alt sınıflarda override edilemez | `invalid_override_of_non_virtual_member` |
| `@internal` | Yalnızca kendi paketi içinde kullanılmalı; paketin public API'sinde bildirilmesi/export edilmesi de uyarılır, yani `lib/src/` altında ve export edilmeden kullanılır | (bu repo'da doğrulanmadı: örnekler `lib/src/` altında değil) |
| `@awaitNotRequired` | Dönen `Future` beklenmeden bırakılabilir: hata ile tamamlanmaz, değeri işlem gerektirmez; `unawaited_futures`/`discarded_futures` lint'leri bunu dikkate alır (analyzer desteği SDK 3.9 CHANGELOG) | — |

<!-- snippet: 04_libraries_metadata/metadata/money -->
```dart
import 'package:meta/meta.dart';

@immutable
final class Money {
  const Money(this.cents, this.currency);
  final int cents;
  final String currency;

  /// Returns a new value: `total.add(fee);` alone is reported.
  @useResult
  Money add(Money other) {
    if (other.currency != currency) {
      throw ArgumentError.value(other.currency, 'other', 'Currency mismatch');
    }
    return Money(cents + other.cents, currency);
  }
}
```

<!-- snippet: 04_libraries_metadata/metadata/store -->
```dart
import 'package:meta/meta.dart';

abstract base class Store<S> {
  Store(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void listen(void Function(S state) listener) => _listeners.add(listener);

  @protected
  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }

  @mustCallSuper
  void dispose() => _listeners.clear();

  @visibleForTesting
  int get listenerCount => _listeners.length;
}
```

<!-- snippet: 04_libraries_metadata/metadata/counter_store -->
```dart
import 'store.dart';

final class CounterStore extends Store<int> {
  CounterStore() : super(0);

  int disposeCalls = 0;

  void increment() => emit(state + 1); // Allowed: a subclass, on `this`.

  @override
  void dispose() {
    disposeCalls++;
    super.dispose(); // Required by @mustCallSuper.
  }
}
```

`CounterStore` `Store`'dan ayrı bir library'dedir; `emit`'i `this` üzerinden çağırabilir.
`store.emit(1)` başka bir library'den (ör. bir widget) çağrılırsa
`invalid_use_of_protected_member`; `CounterStore.dispose` içindeki `super.dispose()`
silinirse `must_call_super`. Test `listenerCount`'u okuyabilir çünkü `test/` altında.

<!-- snippet: 04_libraries_metadata/metadata/analytics -->
```dart
import 'package:meta/meta.dart';

final class Analytics {
  final List<String> sent = [];

  /// Never fails and its value needs no handling, so callers may drop it.
  @awaitNotRequired
  Future<void> track(String event) async {
    sent.add(event);
  }
}
```

Flutter kullanıcıları `@immutable`, `@protected` vb. için `package:meta` import etmez:
`package:flutter/foundation.dart` bunları `export 'package:meta/meta.dart' show ...`
ile yeniden export eder (aşağıdaki tablo). Saf Dart pakette `meta`'yı dependency olarak ekle.

### Metadata: özel annotation ve `@Target`

Annotation = `const` constructor'lı sıradan bir sınıf
([custom-annotations](https://dart.dev/language/metadata#custom-annotations)).
`package:meta/meta_meta.dart`'taki `@Target` nerede kullanılabileceğini sınırlar;
başka yere konursa analyzer `invalid_annotation_target` verir
([specifying-supported-targets](https://dart.dev/language/metadata#specifying-supported-targets)).

<!-- snippet: 04_libraries_metadata/metadata/todo_annotation -->
```dart
import 'package:meta/meta_meta.dart';

@Target({TargetKind.function, TargetKind.method})
class Todo {
  final String who;
  final String what;

  const Todo(this.who, this.what);
}

@Todo('Dash', 'Implement this function')
void doSomething() {
  print('Do something');
}
```

Library direktifine konan bir mimari etiketi (yukarıdaki barrel'da kullanılıyor):

<!-- snippet: 04_libraries_metadata/metadata/feature_api -->
```dart
import 'package:meta/meta_meta.dart';

/// Marks a library as a feature's public entry point (barrel).
@Target({TargetKind.library})
final class FeatureApi {
  const FeatureApi(this.name);
  final String name;
}
```

Özel annotation'ı bir **araç** okur: `build_runner` generator'ları (`@freezed`,
`@JsonSerializable`), analyzer eklentileri, mimari testleri. Onu okuyan bir araç yoksa
`@Target` kontrolü dışında hiçbir etkisi yoktur.

Doc comment annotation'ın **önüne** gelir
([do-put-doc-comments-before-metadata-annotations](https://dart.dev/effective-dart/documentation#do-put-doc-comments-before-metadata-annotations)).

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` (üst seviye barrel'lar dahil)
(`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`). Sayılar
eşleşen **satır** sayısıdır; yorum satırları dahil olabilir.

| Regex | Sayı |
| --- | --- |
| `^export ` / `^export 'src/` | 871 / 627 |
| `^library;` / `^library [a-z_]+;` (isimli, legacy) | 504 / 14 |
| `^part '` / `^part of ` | 16 / 16 (hepsi `material_animated_icons` library'sinde) |
| `^import .* deferred as ` / `deferred as` | 0 / 1 (yalnızca bir doc comment içinde) |
| `^// @dart` | 0 |
| `@protected` / `@mustCallSuper` / `@immutable` | 663 / 145 / 263 |
| `@visibleForTesting` / `@visibleForOverriding` / `@nonVirtual` | 111 / 13 / 9 |
| `@internal` / `^@internal` | 260 / 40 |
| `@useResult` | 0 |
| `@Deprecated\(` | 486 |
| `@pragma\('vm:` / `@pragma\('vm:prefer-inline'\)` | 52 / 15 |
| `@Target\(` | 1 |

| Kullanım | Ne gösteriyor | Kaynak |
| --- | --- | --- |
| `library widgets;` + `export 'src/widgets/...'` | Barrel: library doc comment'i + `src/` altındaki her dosyanın export'u; `package:flutter/widgets.dart` tek giriş. Flutter isimli library direktifini hâlâ kullanıyor (Effective Dart'ın legacy dediği biçim) | [widgets.dart#L13](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/widgets.dart#L13), [#L64](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/widgets.dart#L64) |
| `export 'package:meta/meta.dart' show awaitNotRequired, factory, immutable, internal, ...` | Başka paketin API'sini `show` ile seçerek yeniden export: Flutter kullanıcıları `@immutable`/`@protected` için meta import etmez | [foundation.dart#L12](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/foundation.dart#L12) |
| `library material_animated_icons;` + 16 `part` | Framework'teki **tek** `part` kullanımı. Dosyadaki yorum: "split into multiple parts to enable a private API that is testable"; part'ların çoğu `vitool` ile **üretilmiş** `*.g.dart` veri dosyaları | [animated_icons.dart#L10](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/animated_icons.dart#L10), [#L29](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/animated_icons.dart#L29) |
| `part of material_animated_icons; // ignore: use_string_in_part_of_directives` | İsimli `part of` legacy olduğu için core lint'i satır bazında susturulmuş; yeni kodda `part of '<uri>'` yaz | [add_event.g.dart#L7](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/animated_icons/data/add_event.g.dart#L7) |
| `library;` (isimsiz) | `src/` dosyalarında library seviyesi doc comment'i taşır (bu örnekte yalnızca `@docImport` satırları) | [animation/animation.dart#L7](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/animation/animation.dart#L7) |
| `@immutable abstract class Widget` | Framework'ün temel sözleşmesi: tüm widget alt tipleri `final` alanlı olmak zorunda | [widgets/framework.dart#L311](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L311) |
| `@protected @mustCallSuper void initState()` | `State` yaşam döngüsü: yalnızca alt sınıflar çağırır, override `super.initState()` çağırmak zorunda | [widgets/framework.dart#L1008](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/framework.dart#L1008) |
| `@visibleForTesting static double getColumnWidth(...)` | Doc'u "intended for testing only" diyen public static yardımcı | [cupertino/date_picker.dart#L610](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/cupertino/date_picker.dart#L610) |
| `@internal bool isWindowingEnabled` | `lib/src/` altında, "Do not use this API" dokümanlı paket içi bayrak | [foundation/_features.dart#L22](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/_features.dart#L22) |
| `@pragma('dart2js:tryInline')` + `@pragma('vm:prefer-inline')` + `@pragma('wasm:prefer-inline')` | Aynı küçük sıcak fonksiyon (`_bitCount`) için her derleyiciye ayrı ipucu | [foundation/persistent_hash_map.dart#L367](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/persistent_hash_map.dart#L367) |
| `@Target(<TargetKind>{TargetKind.method}) class _WidgetFactory` | Framework'ün kendi özel annotation'ı; public yüzü `const widgetFactory` ([L4667](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/widget_inspector.dart#L4667)), widget üreten metotları işaretler | [widgets/widget_inspector.dart#L4604](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/widget_inspector.dart#L4604) |
| `/// import 'split_component.dart' deferred as split_component;` | `DeferredComponent` doc'unda: Dart kodu içeren deferred component'lerde `loadLibrary()` çağrılmalı | [services/deferred_component.dart#L48](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/services/deferred_component.dart#L48) |

Framework'te `@useResult` hiç yok; `// @dart` override'ı hiç yok; `part` yalnızca tek,
büyük ölçüde üretilmiş bir library'de.

Not: Flutter'ın library doc comment'lerinde görülen `/// @docImport '...'` satırları
bu reference'ın kaynak aldığı dart.dev sayfalarında belgelenmiyor; burada ele alınmadı.

## Lint'ler

| Lint | Set | Ne yapar |
| --- | --- | --- |
| [use_string_in_part_of_directives](https://dart.dev/tools/linter-rules/use_string_in_part_of_directives) | core (→ recommended) | `part of isim;` yerine `part of 'uri.dart';` |
| [avoid_relative_lib_imports](https://dart.dev/tools/linter-rules/avoid_relative_lib_imports) | core | `lib/` içindeki dosyaya `../lib/...` gibi relative yol ile girmeyi yasaklar |
| [provide_deprecation_message](https://dart.dev/tools/linter-rules/provide_deprecation_message) | core | `@deprecated` yerine `@Deprecated("mesaj")` |
| [implementation_imports](https://dart.dev/tools/linter-rules/implementation_imports) | recommended | Başka paketin `lib/src/` dosyasını import etmeyi yakalar |
| [library_prefixes](https://dart.dev/tools/linter-rules/library_prefixes) | recommended | Prefix `lowercase_with_underscores` |
| [no_leading_underscores_for_library_prefixes](https://dart.dev/tools/linter-rules/no_leading_underscores_for_library_prefixes) | recommended | `as _foo` gibi alt çizgiyle başlayan prefix'i yasaklar |
| [unnecessary_library_name](https://dart.dev/tools/linter-rules/unnecessary_library_name) | recommended | `library isim;` yerine `library;` |
| [library_private_types_in_public_api](https://dart.dev/tools/linter-rules/library_private_types_in_public_api) | recommended | Public API imzasında private tip kullanımını yakalar |
| [annotate_overrides](https://dart.dev/tools/linter-rules/annotate_overrides) | recommended | Override eden üyede `@override` ister |
| [unnecessary_library_directive](https://dart.dev/tools/linter-rules/unnecessary_library_directive) | hiçbiri | Doc comment/annotation taşımayan `library;`'yi işaretler |
| [directives_ordering](https://dart.dev/tools/linter-rules/directives_ordering) | hiçbiri | `dart:` → `package:` → relative; export'lar import'lardan sonra ayrı blokta; bölümler alfabetik ([ordering](https://dart.dev/effective-dart/style#ordering)) |

`invalid_use_of_visible_for_testing_member`, `invalid_use_of_protected_member`,
`must_call_super`, `unused_result`, `must_be_immutable`, `invalid_annotation_target`
**lint değil, analyzer tanısıdır** (ör. [unused_result](https://dart.dev/tools/diagnostics/unused_result));
`package:meta` annotation'ı kullanıldığı anda ek yapılandırma olmadan çalışır.

## Kontrol listesi

- [ ] "Private" gereken şey gerçekten library dışından mı gizlenmeli? `_` sınıfı değil dosyayı korur; aynı dosyadaki her sınıf erişir.
- [ ] Feature/paket tek bir barrel'dan mı tüketiliyor? Barrel `export ... show` ile yalnızca domain tipleri + use case + composition fonksiyonunu açıyor mu?
- [ ] Data implementasyonu (RepositoryImpl, DataSource) barrel'dan export ediliyor mu? → Etmemeli.
- [ ] Başka paketin `src/`'si import ediliyor mu? → `implementation_imports`; public API'den al veya paket sahibine export ettir.
- [ ] `part` el yazımı kod için mi kullanılıyor? → Küçük library'lere böl; `part` üretilmiş kod (`*.g.dart`, `*.freezed.dart`) için.
- [ ] `part of` URI string'i mi kullanıyor? (`use_string_in_part_of_directives`, core)
- [ ] `library isim;` var mı? → `library;` (yalnızca doc comment/annotation taşıyorsa).
- [ ] İsim çakışmasında prefix `lowercase_with_underscores` mı, `_` ile başlamıyor mu?
- [ ] `deferred as` web dışı bir hedef için mi düşünülüyor? → Dart aracı desteklemez; Flutter'da deferred components.
- [ ] `// @dart = x.y` yalnızca geçici migrasyon için mi?
- [ ] Değer sınıfı `@immutable`, "yeni nesne döner" metodu `@useResult`, taban sınıf hook'ları `@protected`/`@mustCallSuper` mı?
- [ ] `@Deprecated` her zaman mesajla mı? Modifier eklemeden önce `@Deprecated.extend()`/`.implement()` ile bir sürüm uyarıldı mı (SDK ≥ 3.10)?
- [ ] Özel annotation'ı okuyan bir araç var mı? Yoksa `@Target` dışında etkisi olmadığını bil.

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: Library privacy: aynı dosyada iş birliği yapan iki sınıf
- **Demo promptu:** "Kütüphane üyeliği için `Membership` ve `LateFeeCollector` yaz: gecikme borcu dışarıdan yalnızca okunabilsin, sadece tahsilatçı sıfırlayabilsin."
- **Model:** [`examples/lib/04_libraries_metadata/privacy/wallet.dart`](../../../examples/lib/04_libraries_metadata/privacy/wallet.dart), [`practice/ex1_ticket.dart`](../../../examples/lib/04_libraries_metadata/practice/ex1_ticket.dart)
- **Katman:** Domain / Entity (library sınırı)
- **Adımlar:** 1. İki sınıfı aynı dosyaya koy. 2. Korunacak alanı `_` ile başlat, dışarıya yalnızca getter aç; public setter yazma. 3. Yetkili sınıf alana doğrudan yazsın. 4. Dosya bir kuralı anlatıyorsa `library;` üstüne doc comment ekle.
- **Kabul kriteri:** Test (ayrı library) davranışı yalnızca public API üzerinden doğrular: yetkili sınıfın alanı değiştirdiği, getter'ın bunu gösterdiği; testte `_alan` yazılmaz çünkü derlenmez.
- **Min. sürüm:** her sürüm; isimsiz `library;` 2.19

### Tarif: Feature barrel + composition fonksiyonu
- **Demo promptu:** "Bildirim tercihleri feature'ı kur: tek public giriş dosyası domain tiplerini, use case'i ve kurulum fonksiyonunu açsın, bellek içi repository gizli kalsın."
- **Model:** [`examples/lib/04_libraries_metadata/feature_profile/profile.dart`](../../../examples/lib/04_libraries_metadata/feature_profile/profile.dart), [`feature_profile/src/profile_module.dart`](../../../examples/lib/04_libraries_metadata/feature_profile/src/profile_module.dart), [`feature_profile/src/data/in_memory_profile_repository.dart`](../../../examples/lib/04_libraries_metadata/feature_profile/src/data/in_memory_profile_repository.dart), [`practice/ex2_feature_cart/cart.dart`](../../../examples/lib/04_libraries_metadata/practice/ex2_feature_cart/cart.dart)
- **Katman:** paket / modül sınırı
- **Adımlar:** 1. Domain (entity, repository arayüzü, use case) ve data implementasyonunu `src/` altına koy. 2. `src/<feature>_module.dart` içinde data implementasyonunu bilen tek fonksiyonu yaz; use case döndürsün. 3. Barrel'da önce import'lar, sonra ayrı blokta `export ... show` ile yalnızca domain tipleri + use case + composition fonksiyonunu aç. 4. Data implementasyonunu export etme; core `Result`'ı yeniden export etme.
- **Kabul kriteri:** Test yalnızca barrel'ı (+ core) import eder; composition fonksiyonuyla gerçek wiring'i ve kendi fake repository'siyle use case'i çalıştırır, data sınıfının adını kullanmaz.
- **Min. sürüm:** her sürüm; `library;` üstünde annotation varsa 2.19

### Tarif: İsim çakışması: prefix, `show`/`hide`, wildcard prefix
- **Demo promptu:** "Eski ve yeni ödeme API modellerinde aynı adlı `Payment` sınıfı var; eskisini yenisine çeviren bir migrasyon fonksiyonu yaz."
- **Model:** [`examples/lib/04_libraries_metadata/imports/user_migration.dart`](../../../examples/lib/04_libraries_metadata/imports/user_migration.dart), [`imports/api_v1.dart`](../../../examples/lib/04_libraries_metadata/imports/api_v1.dart), [`imports/api_v2.dart`](../../../examples/lib/04_libraries_metadata/imports/api_v2.dart), [`imports/string_case.dart`](../../../examples/lib/04_libraries_metadata/imports/string_case.dart)
- **Katman:** Data / Model
- **Adımlar:** 1. Eski library'yi `as v1` ile prefix'le. 2. Yeni library'yi prefix'siz al, istenmeyen tek ismi `hide` ile dışarıda bırak. 3. Yalnızca extension'ı için gereken library'yi `as _` ile import et. 4. Sürüm alanına göre prefix'li sabiti switch'te constant pattern olarak kullan.
- **Kabul kriteri:** Test, iki library'deki aynı adlı tiplerin birlikte kullanıldığını, extension'ın `as _` ile çalıştığını ve prefix'li sabitle doğru parser'ın seçildiğini kanıtlar.
- **Min. sürüm:** wildcard prefix `as _` 3.7

### Tarif: `part` / `part of '<uri>'` (üretilmiş kod için)
- **Demo promptu:** "Bir `Invoice` sınıfını, satır tipini ve yardımcı fonksiyonu ayrı bir part dosyasında tutarak kur; part'ın library'nin import'larını ve private üyelerini paylaştığını göster."
- **Model:** [`examples/lib/04_libraries_metadata/part_demo/order_builder.dart`](../../../examples/lib/04_libraries_metadata/part_demo/order_builder.dart), [`part_demo/order_builder_lines.dart`](../../../examples/lib/04_libraries_metadata/part_demo/order_builder_lines.dart)
- **Katman:** Data / Model (gerçek hayatta `*.g.dart`, `*.freezed.dart`)
- **Adımlar:** 1. Library dosyasına import'ları ve `part '<dosya>.dart';` yaz. 2. Part dosyası `part of '<library>.dart';` (isim değil URI) ile başlasın, kendi import'u olmasın. 3. Private tip/fonksiyonu part'ta tanımla, library'deki private alana part'tan eriş. 4. El yazımı kodda bunun yerine küçük library'ler öner; `part`'ı üretilmiş kod için bırak.
- **Kabul kriteri:** Test, part'taki private yardımcının library'nin private alanını değiştirdiğini public API üzerinden kanıtlar.
- **Min. sürüm:** `part of '<uri>'` 2.0

### Tarif: `package:meta` annotation'lı değer sınıfı ve taban state sınıfı
- **Demo promptu:** "`@immutable` bir `Distance` değer sınıfı (`@useResult` toplama) ve `@protected emit`, `@mustCallSuper dispose` içeren bir `Store` tabanından türeyen `TimerStore` yaz."
- **Model:** [`examples/lib/04_libraries_metadata/metadata/money.dart`](../../../examples/lib/04_libraries_metadata/metadata/money.dart), [`metadata/store.dart`](../../../examples/lib/04_libraries_metadata/metadata/store.dart), [`metadata/counter_store.dart`](../../../examples/lib/04_libraries_metadata/metadata/counter_store.dart), [`metadata/analytics.dart`](../../../examples/lib/04_libraries_metadata/metadata/analytics.dart)
- **Katman:** Domain / Entity + Application / state sınıfı
- **Adımlar:** 1. Projeye `meta` bağımlılığını ekle (Flutter'da `foundation.dart` yeniden export eder). 2. Değer sınıfını `@immutable`, yeni nesne dönen metodu `@useResult` yap. 3. Taban sınıfı `abstract base class` yap: `emit` `@protected`, `dispose` `@mustCallSuper`, test sayaçları `@visibleForTesting`. 4. Alt sınıfı ayrı dosyada yaz; `emit`'i yalnızca `this` üzerinden çağır, `dispose` override'ı `super.dispose()` çağırsın. 5. Beklenmeden bırakılabilen future'ı `@awaitNotRequired` ile işaretle.
- **Kabul kriteri:** Test, `@useResult` metodunun yeni değer döndürüp orijinali değiştirmediğini, alt sınıfın emit ettiği state'lerin dinleyiciye ulaştığını ve `dispose` sonrası dinleyici sayısının 0 olduğunu kanıtlar; `dart analyze` sıfır sorun.
- **Min. sürüm:** `base` 3.0; `package:meta` bağımlılığı (bu repo: `^1.16.0`)

### Tarif: Özel annotation ve `@Target`
- **Demo promptu:** "Yalnızca sınıflara konabilen, sahibini ve ekibini tutan bir `@Owner('ekip')` annotation'ı yaz ve bir servis sınıfına uygula."
- **Model:** [`examples/lib/04_libraries_metadata/metadata/feature_api.dart`](../../../examples/lib/04_libraries_metadata/metadata/feature_api.dart), [`metadata/todo_annotation.dart`](../../../examples/lib/04_libraries_metadata/metadata/todo_annotation.dart)
- **Katman:** paket sınırı (mimari etiket)
- **Adımlar:** 1. `const` constructor'lı `final class` yaz. 2. `package:meta/meta_meta.dart`'tan `@Target({TargetKind...})` ile konabileceği yeri sınırla. 3. Doc comment'i annotation'ın önüne koy. 4. Onu okuyacak aracı (generator, lint, mimari test) belirt; yoksa etkisinin yalnızca `@Target` kontrolü olduğunu söyle.
- **Kabul kriteri:** Test, annotation'ın sıradan bir `const` nesne olarak alanlarını taşıdığını kanıtlar; yanlış hedefe konulduğunda analyzer `invalid_annotation_target` verir.
- **Min. sürüm:** `package:meta` bağımlılığı (bu repo: `^1.16.0`)

### Tarif: Deferred loading (yalnızca web)
- **Demo promptu:** "Web uygulamasında nadiren açılan yönetim panelini `deferred as` ile gerektiğinde yükleyen bir açıcı fonksiyon yaz."
- **Model:** [`examples/lib/04_libraries_metadata/deferred/app_shell.dart`](../../../examples/lib/04_libraries_metadata/deferred/app_shell.dart), [`deferred/report_contract.dart`](../../../examples/lib/04_libraries_metadata/deferred/report_contract.dart), [`deferred/reports_screen.dart`](../../../examples/lib/04_libraries_metadata/deferred/reports_screen.dart)
- **Katman:** Presentation / uygulama kabuğu
- **Adımlar:** 1. İki tarafın da eager import ettiği bir arayüz library'si yaz. 2. Ağır ekranı ayrı library'de arayüzü implement ederek ve bir fabrika fonksiyonuyla yaz. 3. Kabukta `deferred as` ile import et, önce `await x.loadLibrary()`, sonra fabrikayı çağır. 4. Deferred library'nin tiplerini kabukta tip olarak kullanma.
- **Kabul kriteri:** `dart analyze` sıfır sorun; kabuk dosyasındaki imzalarda yalnızca eager arayüz tipi geçer. VM'de davranış tanımsız olduğu için test web hedefinde yapılır veya yazılmaz.
- **Min. sürüm:** her sürüm (yalnızca web hedefi)

### Tarif: Migrasyon araçları: `@Deprecated` ve `// @dart = x.y`
- **Demo promptu:** "`sendMail` metodunu `send` ile değiştir; eskisini mesajlı `@Deprecated` ile bir sürüm yaşat, eski bir yardımcı dosyayı da geçici olarak 3.9'a sabitle."
- **Model:** [`examples/lib/04_libraries_metadata/metadata/deprecated.dart`](../../../examples/lib/04_libraries_metadata/metadata/deprecated.dart), [`versioning/legacy_formatter.dart`](../../../examples/lib/04_libraries_metadata/versioning/legacy_formatter.dart)
- **Katman:** paket sınırı (paylaşılan API)
- **Adımlar:** 1. Eski üyeyi `@Deprecated('Use X instead')` ile işaretle ve yeni üyeye yönlendir. 2. Doc comment'te alternatifi söyle. 3. Sürüm sabitlemesi gerekiyorsa dosyanın başına, koddan önce `// @dart = 3.x` yaz (`///` değil). 4. İkisinin de geçici olduğunu, kaldırılma planını not et.
- **Kabul kriteri:** Test, yeni üyenin çalıştığını ve sabitlenmiş library'nin yeni library'lerle birlikte çalıştığını kanıtlar.
- **Min. sürüm:** her sürüm; `@Deprecated.extend()` vb. 3.10

## Pekiştirme

### Alıştırma 1 · Aynı library'deki iki sınıf (kolay)

`practice/ex1_ticket.dart` içinde `Ticket` (alan: `code`, private `_redeemed`) ve `TicketGate`
yaz. `Ticket` dışarıya yalnızca `isRedeemed` getter'ını açsın; **public setter olmasın**.
`TicketGate.admit(ticket)` bileti ilk seferde kabul edip `true`, ikinci seferde `false`
dönsün. Ardından şunu cevapla: testte `ticket._redeemed = true` yazmak neden derlenmez,
ama `TicketGate` bunu nasıl yapabiliyor?

**İpucu:** "Privacy library'ye aittir, sınıfa değil" bölümü ve
[libraries](https://dart.dev/language/libraries): `_` dosyayı korur, sınıfı değil.

<details><summary>Çözüm</summary>

<!-- snippet: 04_libraries_metadata/practice/ex1_ticket -->
```dart
final class Ticket {
  Ticket(this.code);
  final String code;
  bool _redeemed = false;

  bool get isRedeemed => _redeemed;
}

final class TicketGate {
  const TicketGate();

  /// Same library as [Ticket], so it may write `_redeemed`.
  bool admit(Ticket ticket) {
    if (ticket._redeemed) return false;
    ticket._redeemed = true;
    return true;
  }
}
```

Test ayrı bir library olduğu için `_redeemed`'i göremez (okumak bile derleme hatası,
bkz. yukarıdaki `undefined_getter` notu); davranışı yalnızca `admit` ve `isRedeemed`
üzerinden doğrular.

</details>

### Alıştırma 2 · Sepet feature'ı için barrel (orta)

`practice/ex2_feature_cart/` altında bir sepet feature'ı kur: `src/domain.dart` (`CartItem`,
`CartRepository`, `AddToCart` use case'i, `Future<Result<int>>` döner),
`src/data/in_memory_cart_repository.dart` (katalogda olmayan SKU → `Err(ServerFailure(404))`)
ve `src/cart_module.dart` (`createAddToCart`). Tek public giriş `cart.dart` olsun:
`@FeatureApi('cart')` etiketli, `export ... show` ile yalnızca domain tipleri + use case +
composition fonksiyonu. Test **yalnızca barrel'ı** import ederek hem gerçek wiring'i hem
kendi fake `CartRepository`'sini kullanabilmeli, ama `InMemoryCartRepository` adını
görememeli.

**İpucu:** "Feature barrel: `export ... show` ile public API" bölümü ve
[organizing-a-package](https://dart.dev/tools/pub/create-packages#organizing-a-package).

<details><summary>Çözüm</summary>

<!-- snippet: 04_libraries_metadata/practice/ex2_feature_cart/cart -->
```dart
/// Public API of the cart feature: consumers import ONLY this file.
@FeatureApi('cart')
library;

import '../../metadata/feature_api.dart';

export 'src/cart_module.dart' show createAddToCart;
export 'src/domain.dart' show AddToCart, CartItem, CartRepository;
```

<!-- snippet: 04_libraries_metadata/practice/ex2_feature_cart/src/cart_module -->
```dart
import 'data/in_memory_cart_repository.dart';
import 'domain.dart';

AddToCart createAddToCart({Set<String> catalog = const {}}) =>
    AddToCart(InMemoryCartRepository({...catalog}));
```

Data implementasyonu barrel'da `show` listesinde olmadığı için başka library'ler onu
isimle anamaz; değiştirmek kimseyi kırmaz.

</details>

### Alıştırma 3 · `base` Store + `sealed` state, üç library (zor)

03 (class modifiers) ile birleştir. `practice/ex3_checkout_state.dart` içinde `@immutable`
`sealed class CheckoutState` ve dört `final` alt tipi (`Idle`, `Submitting`,
`Paid(receiptId)`, `Failed(message)`) yaz. `practice/ex3_checkout_store.dart` içinde
metadata örneğindeki `Store<S>`'yi (`abstract base class`, **başka library**) extend eden
`CheckoutStore` yaz: `pay(amountCents)` önce `Submitting`, sonra `Result`'a göre `Paid`
veya `Failed` emit etsin; `dispose` sonrası gelen sonuç yok sayılsın. Aynı dosyada
`checkoutLabel(state)` exhaustive switch'i olsun. Sorular: `CheckoutStore`'un önüne neden
`final` (veya `base`) yazmak zorundasın? UI `store.emit(...)` çağırırsa ne olur?
`CheckoutState`'e başka bir dosyadan alt tip eklenebilir mi?

**İpucu:** Bu reference'taki `@protected`/`@mustCallSuper` tablosu ve 03'teki
[base-transitivity](https://dart.dev/language/class-modifiers-for-apis#base-transitivity) kuralı.

<details><summary>Çözüm</summary>

<!-- snippet: 04_libraries_metadata/practice/ex3_checkout_state -->
```dart
import 'package:meta/meta.dart';

@immutable
sealed class CheckoutState {
  const CheckoutState();
}

final class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

final class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting();
}

final class CheckoutPaid extends CheckoutState {
  const CheckoutPaid(this.receiptId);
  final String receiptId;
}

final class CheckoutFailed extends CheckoutState {
  const CheckoutFailed(this.message);
  final String message;
}
```

<!-- snippet: 04_libraries_metadata/practice/ex3_checkout_store -->
```dart
import '../../00_architecture/result.dart';
import '../metadata/store.dart';
import 'ex3_checkout_state.dart';

/// `Store` is `base` in another library, so this class must be `base`, `final` or `sealed`.
final class CheckoutStore extends Store<CheckoutState> {
  CheckoutStore(this._charge) : super(const CheckoutIdle());
  final Future<Result<String>> Function(int amountCents) _charge;

  bool _closed = false;

  Future<void> pay(int amountCents) async {
    if (_closed) return;
    emit(const CheckoutSubmitting());
    final result = await _charge(amountCents);
    if (_closed) return;
    emit(switch (result) {
      Ok(:final value) => CheckoutPaid(value),
      Err(:final failure) => CheckoutFailed(failure.message),
    });
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}

String checkoutLabel(CheckoutState state) => switch (state) {
  CheckoutIdle() => 'Pay',
  CheckoutSubmitting() => 'Paying...',
  CheckoutPaid(:final receiptId) => 'Paid: $receiptId',
  CheckoutFailed(:final message) => 'Retry ($message)',
};
```

- `base` geçişlidir: `Store`'un alt tipi `base`, `final` veya `sealed` olmak zorunda.
- `emit` `@protected`: başka library'den `store.emit(x)` → `invalid_use_of_protected_member`
  (analyzer tanısı; runtime'da bir şey değişmez).
- `sealed`'in doğrudan alt tipleri yalnızca bildirildiği library'de yazılabilir; switch başka
  library'de de exhaustive'dir. `@immutable` tüm alt tiplere uygulanır.
- `dispose` override'ı `super.dispose()` çağırmazsa `must_call_super`.

</details>

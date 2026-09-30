# 03 · Class modifiers

> Kaynak: https://dart.dev/language/class-modifiers ·
> https://dart.dev/language/class-modifiers-for-apis ·
> https://dart.dev/language/modifier-reference ·
> https://dart.dev/language/mixins#class-mixin-or-mixin-class ·
> https://dart.dev/language/branches#exhaustiveness-checking
> Effective Dart: https://dart.dev/effective-dart/design#do-use-class-modifiers-to-control-if-your-class-can-be-extended,
> https://dart.dev/effective-dart/design#do-use-class-modifiers-to-control-if-your-class-can-be-an-interface,
> https://dart.dev/effective-dart/design#prefer-defining-a-pure-mixin-or-pure-class-to-a-mixin-class
> Min. dil sürümü: `abstract` her sürümde; **`base`, `final`, `interface`, `sealed` ve `mixin class` 3.0**.

Class modifier'lar bir sınıfın **başka library'lerden** nasıl kullanılabileceğini
(construct / extend / implement / mix in) kontrol eder. Kısıtlar **tanımlandığı
library'nin içinde geçerli değildir** (`abstract` hariç: o her yerde construct'ı
engeller). Library = tek `.dart` dosyası (+ `part`'ları); aynı paketteki başka
bir dosya da "dışarı"dır
([the-interface-modifier](https://dart.dev/language/class-modifiers-for-apis#the-interface-modifier)).

## Yetenek matrisi (resmi tablo)

[Class modifiers reference › Valid combinations](https://dart.dev/language/modifier-reference#valid-combinations)
tablosunun birebir aktarımı. "Evet/Hayır" **başka bir library'den** yapılabilirliği
gösterir.

| Bildirim | Construct | Extend | Implement | Mix in | Exhaustive |
|---|---|---|---|---|---|
| `class` | **Evet** | **Evet** | **Evet** | Hayır | Hayır |
| `base class` | **Evet** | **Evet** | Hayır | Hayır | Hayır |
| `interface class` | **Evet** | Hayır | **Evet** | Hayır | Hayır |
| `final class` | **Evet** | Hayır | Hayır | Hayır | Hayır |
| `sealed class` | Hayır | Hayır | Hayır | Hayır | **Evet** |
| `abstract class` | Hayır | **Evet** | **Evet** | Hayır | Hayır |
| `abstract base class` | Hayır | **Evet** | Hayır | Hayır | Hayır |
| `abstract interface class` | Hayır | Hayır | **Evet** | Hayır | Hayır |
| `abstract final class` | Hayır | Hayır | Hayır | Hayır | Hayır |
| `mixin class` | **Evet** | **Evet** | **Evet** | **Evet** | Hayır |
| `base mixin class` | **Evet** | **Evet** | Hayır | **Evet** | Hayır |
| `abstract mixin class` | Hayır | **Evet** | **Evet** | **Evet** | Hayır |
| `abstract base mixin class` | Hayır | **Evet** | Hayır | **Evet** | Hayır |
| `mixin` | Hayır | Hayır | **Evet** | **Evet** | Hayır |
| `base mixin` | Hayır | Hayır | Hayır | **Evet** | Hayır |

**Sıra** ([combining-modifiers](https://dart.dev/language/class-modifiers#combining-modifiers)):
(opsiyonel) `abstract` → (opsiyonel) `base` | `interface` | `final` | `sealed` → (opsiyonel) `mixin` → `class`.

**Geçersiz kombinasyonlar** ([invalid-combinations](https://dart.dev/language/modifier-reference#invalid-combinations)):
`base`/`interface`/`final` birbirini dışlar; `sealed` + `abstract` gereksiz (sealed zaten
abstract); `sealed` + `base`/`interface`/`final` gereksiz; `mixin` + `abstract` bir
**mixin** bildiriminde gereksiz; `mixin` + `interface`/`final`/`sealed` çelişkili;
`enum` ve `extension type` hiçbir modifier almaz. Mixin bildiriminin önüne yalnızca
`base` gelebilir.

## Ne zaman kullan / ne zaman gerekmez

| Kullan | Gerekmez / başka araç |
|---|---|
| Varyantlar arası **exhaustive `switch`** gereken kapalı aile (Failure, UI state, `Result`) → `sealed` + `final class` alt tipler | Alt tipi olmayan tek sınıf → `sealed` anlamsız, exhaustiveness kazancı yok ([sealed-versus-final](https://dart.dev/language/class-modifiers-for-apis#sealed-versus-final)) → `final class` |
| Saf sözleşme (Repository, DataSource) → `abstract interface class`: dışarıda sadece `implements` | Sınıf yalnızca **kendi library'sinde** kullanılıyorsa (private `_Helper`, dosya içi yardımcı) modifier hiçbir şey kısıtlamaz; düz `class` yeterli |
| Dışarıdan alt tiplenmemesi gereken somut sınıf (UseCase, entity, notifier) → `final class` | Uygulama içi, kimsenin extend/implement etmediği sınıfta modifier zorunlu değil; ama projede kural olarak `final` kullanılıyorsa ona uy (SKILL.md: UseCase = `final class`) |
| Private üyeler/constructor garantisi olan **paylaşılan implementasyon** → `abstract base class` | Tek soyut metotlu "arayüz" → çoğu zaman bir fonksiyon tipi yeter ([one-member abstract](https://dart.dev/effective-dart/design#avoid-defining-a-one-member-abstract-class-when-a-simple-function-will-do)) |
| Dışarıda yeni alt tip eklemeyi **kırıcı olmayan** değişiklik tutmak → supertype `final` (switch'lere `_` zorunlu olur) | Hem mixin hem sınıf olarak kullanım → yeni kodda pure `mixin` veya pure `class` tercih et; `mixin class` esas olarak 3.0 öncesi migrasyon içindir ([Effective Dart](https://dart.dev/effective-dart/design#prefer-defining-a-pure-mixin-or-pure-class-to-a-mixin-class)) |
| Varsayılan implementasyonu olan ama dışarıda **sadece yeniden implement** edilmesi istenen sınıf → `interface class` | Veri sınıfı `copyWith`/equality/JSON gerektiriyorsa → freezed (SKILL.md kuralı); sealed yalnızca union/state ailesi için |

## Mimarideki yeri

| Katman | Kullanım |
|---|---|
| Domain / Entity | `final class Profile` — dışarıda construct edilir, alt tiplenmez |
| Domain / Failure, `Result<T>` | `sealed class` + `final class` alt tipler (bkz. `00_architecture/result`) |
| Domain / Repository arayüzü | `abstract interface class ProfileRepository` — Data katmanı ve testler `implements` eder |
| Domain / UseCase | `final class GetProfile` + `call()` (ileride: Callable objects) |
| Data / RepositoryImpl | `final class ...Impl implements ProfileRepository` |
| Application / state sınıfı (düz Dart) | UI state: `sealed class ProfileState` + `final` alt tipler; ortak altyapı `abstract base class StateNotifier<S>`, somut notifier `final class` |
| Presentation | `switch (state)` exhaustive, `_` yok → yeni state eklenince derleme hatası tüm ekranları gösterir |
| Paket sınırı (paylaşılan modül/kütüphane) | Modifier eklemek/değiştirmek **kırıcı değişiklik** → major sürüm ([summary](https://dart.dev/language/class-modifiers-for-apis#summary)) |

## API sahibi için kurallar (docs)

- **`base` geçişlidir** ([base-transitivity](https://dart.dev/language/class-modifiers-for-apis#base-transitivity)):
  bir `base` tipin doğrudan veya dolaylı her alt tipi `base`, `final` veya `sealed`
  olmak zorundadır. `final` de `base`'in etkisini kapsar
  ([final](https://dart.dev/language/class-modifiers#final)).
- **`sealed` geçişli değildir** ([the-sealed-modifier](https://dart.dev/language/class-modifiers-for-apis#the-sealed-modifier)):
  `sealed` tipin kendisi dışarıda extend/implement edilemez, ama alt tipleri
  kısıtsız `class` ise dışarıda extend/implement edilebilir. Alt tipleri de kapatmak
  istiyorsan onları `final`/`base`/`interface`/`sealed` işaretle.
- **`sealed` mi `final` mi?** ([sealed-versus-final](https://dart.dev/language/class-modifiers-for-apis#sealed-versus-final)):
  doğrudan construct edilecekse `sealed` olamaz (implicit abstract); alt tip yoksa
  `sealed` gereksiz; alt tipler varsa genelde `sealed`. Ama `sealed`'e yeni alt tip
  eklemek **kırıcıdır** (enum'a değer eklemek gibi). Alt tip eklemeyi kırıcı olmaktan
  çıkarmak için supertype'ı `final` yap: tüketici switch'leri `_` taşımak zorunda kalır.
- **Modifier eklemek kırıcıdır** ([other-opt-in-modifiers](https://dart.dev/language/class-modifiers-for-apis#other-opt-in-modifiers)):
  `interface`/`base`/`final`/`sealed` eklemek kullanıcıların yapabildiği bir şeyi
  yasaklar → major sürüm.
- **`mixin` sınıflarda opt-in'dir** ([the-mixin-modifier-on-classes](https://dart.dev/language/class-modifiers-for-apis#the-mixin-modifier-on-classes)):
  3.0'dan itibaren bir `class` `with` içinde kullanılamaz; bunun için `mixin class`
  gerekir.
- `interface` kısıtı fragile base class problemini azaltır: sınıfın kendi metotları
  `this` üzerinden çağırdığında hep bilinen implementasyonu çalıştırır
  ([interface](https://dart.dev/language/class-modifiers#interface)).
- `base`, dışarıda `implements` edilmeyi engelleyerek her örneğin sınıfın **private
  üyelerini** gerçekten taşımasını garanti eder; aksi halde library içi
  `a._privateMethod()` çağrısı runtime hatası verebilir
  ([the-base-modifier](https://dart.dev/language/class-modifiers-for-apis#the-base-modifier)).

## Doğrulanmış örnekler

Tüm kod `examples/lib/03_class_modifiers/` altında, testleri
`examples/test/03_class_modifiers/` altında
(`dart run dartadvance_tool:dartadvance verify 03_class_modifiers`).
Kısıtlar yalnızca **library'ler arasında** işlediği için hiyerarşi ve onu tüketen
kod ayrı dosyalardadır. Derleme hatası üreten kullanımlar (dışarıda `extends` bir
`interface class` vb.) kod olarak değil, yukarıdaki tablo ve kurallarla anlatılır.

### Resmi örnekler (dart.dev)

`sealed` ile exhaustive switch ([the-sealed-modifier](https://dart.dev/language/class-modifiers-for-apis#the-sealed-modifier)):

<!-- snippet: 03_class_modifiers/sealed_amigo -->
```dart
sealed class Amigo {}

class Lucky extends Amigo {}

class Dusty extends Amigo {}

class Ned extends Amigo {}

String lastName(Amigo amigo) => switch (amigo) {
  Lucky _ => 'Day',
  Dusty _ => 'Bottoms',
  Ned _ => 'Nederlander',
};
```

Başka bir library'de `Amigo` extend edilemez, ama kısıtsız alt tipleri edilebilir
(`sealed` geçişli değil). Switch yine exhaustive kalır: `OtherLucky` bir `Lucky`'dir.

<!-- snippet: 03_class_modifiers/amigo_other_library -->
```dart
import 'sealed_amigo.dart';

class OtherLucky extends Lucky {}

class OtherDusty implements Dusty {}
```

Algebraic data type tarzı ([exhaustiveness-checking](https://dart.dev/language/branches#exhaustiveness-checking)):

<!-- snippet: 03_class_modifiers/sealed_shape -->
```dart
import 'dart:math' as math;

sealed class Shape {}

class Square implements Shape {
  final double length;
  Square(this.length);
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);
}

double calculateArea(Shape shape) => switch (shape) {
  Square(length: var l) => l * l,
  Circle(radius: var r) => math.pi * r * r,
};
```

`mixin class`: aynı isim hem `with` hem `extends` ile ([class-mixin-or-mixin-class](https://dart.dev/language/mixins#class-mixin-or-mixin-class)):

<!-- snippet: 03_class_modifiers/mixin_class -->
```dart
mixin class Both {}

class UseAsMixin with Both {}

class UseAsSuperclass extends Both {}
```

### Domain: entity, repository arayüzü, UseCase

Entity `final class`: her yerde construct edilir, dışarıda alt tiplenmez. Repository
`abstract interface class`: başka library'ler (Data, testler) yalnızca `implements`
eder; ne `extends` ne construct. UseCase `final class`: testler use case'i değil
repository'yi değiştirir. Her biri ayrı dosyada, yani ayrı library'de.

<!-- snippet: 03_class_modifiers/profile -->
```dart
final class Profile {
  const Profile({required this.id, required this.displayName});
  final int id;
  final String displayName;
}
```

<!-- snippet: 03_class_modifiers/profile_repository -->
```dart
import '../00_architecture/result.dart';
import 'profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> fetch(int id);
}
```

<!-- snippet: 03_class_modifiers/get_profile -->
```dart
import '../00_architecture/result.dart';
import 'profile.dart';
import 'profile_repository.dart';

final class GetProfile {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  Future<Result<Profile>> call(int id) => _repository.fetch(id);
}
```

Mimari iskeletteki eşdeğeri: `00_architecture/user_repository`,
`00_architecture/get_user` (SKILL.md).

### Data: arayüzü başka library'de implement etmek

<!-- snippet: 03_class_modifiers/in_memory_profile_repository -->
```dart
import '../00_architecture/result.dart';
import 'profile.dart';
import 'profile_repository.dart';

final class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this._profiles, {this.online = true});
  final Map<int, Profile> _profiles;
  bool online;

  @override
  Future<Result<Profile>> fetch(int id) async {
    if (!online) return const Err(NetworkFailure());
    final profile = _profiles[id];
    return profile == null ? const Err(ServerFailure(404)) : Ok(profile);
  }
}
```

### `interface class`: varsayılan implementasyon, dışarıda yalnızca `implements`

Soyut değil: çalışan bir varsayılanı var. Dışarıda extend edilemediği için kendi
metotları arkasından override edilemez; testte sabit saat gibi yeniden implement edilebilir.

<!-- snippet: 03_class_modifiers/clock -->
```dart
interface class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}
```

Test dosyası ayrı bir library olduğundan `_FixedClock implements Clock` geçerlidir;
`extends Clock` olmazdı.

### Application: `base` altyapı + `final` notifier

`abstract base class StateNotifier<S>` dışarıda `implements` edilemez; böylece her
örnek `_state` ve `_listeners`'ı gerçekten taşır. Başka library'den onu extend eden
`ProfileNotifier` `base`, `final` veya `sealed` olmak zorundadır (base transitivity);
`final` tamamen kapatır.

<!-- snippet: 03_class_modifiers/state_notifier -->
```dart
abstract base class StateNotifier<S> {
  StateNotifier(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void addListener(void Function(S state) listener) => _listeners.add(listener);

  void removeListener(void Function(S state) listener) => _listeners.remove(listener);

  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }
}
```

<!-- snippet: 03_class_modifiers/profile_notifier -->
```dart
import '../00_architecture/result.dart';
import 'get_profile.dart';
import 'profile_state.dart';
import 'state_notifier.dart';

final class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._getProfile) : super(const ProfileInitial());
  final GetProfile _getProfile;

  Future<void> load(int id) async {
    emit(const ProfileLoading());
    final result = await _getProfile(id);
    emit(switch (result) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileError(failure),
    });
  }
}
```

### UI state: `sealed` + `final` alt tipler, başka library'de exhaustive switch

Dört alt tip `ProfileState`'in **bütün** alt tipleridir; alt tipler `final` olduğu için
dışarıda extend edilemezler. `render` ayrı bir library'de (`profile_view.dart`) ve `_`
taşımaz: `ProfileState`'e ya da `ProfileError` içindeki `Failure`'a alt tip eklemek
derleme hatası verir.

<!-- snippet: 03_class_modifiers/profile_state -->
```dart
import '../00_architecture/result.dart';
import 'profile.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final Profile profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);
  final Failure failure;
}
```

<!-- snippet: 03_class_modifiers/profile_view -->
```dart
import '../00_architecture/result.dart';
import 'profile.dart';
import 'profile_state.dart';

String render(ProfileState state) => switch (state) {
  ProfileInitial() => 'Tap to load',
  ProfileLoading() => 'Loading...',
  ProfileLoaded(profile: Profile(:final displayName)) => 'Hi, $displayName',
  ProfileError(failure: NetworkFailure()) => 'You are offline',
  ProfileError(failure: ServerFailure(:final statusCode)) => 'Server error ($statusCode)',
  ProfileError(failure: UnexpectedFailure()) => 'Something went wrong',
};
```

`Result`/`Failure` hiyerarşisi için bkz. `00_architecture/result#result`,
`00_architecture/result#failure` (SKILL.md'de gömülü).

### `final` supertype: alt tip eklemek kırıcı değil

`sealed` yerine `final` kök: dışarıda yine alt tip yok, ama başka library'deki switch
`_` taşımak zorunda. Sonradan eklenen `PurchaseCompleted` mevcut tüketicileri kırmaz.

<!-- snippet: 03_class_modifiers/analytics_event -->
```dart
abstract final class AnalyticsEvent {
  const AnalyticsEvent();
}

final class ScreenViewed extends AnalyticsEvent {
  const ScreenViewed(this.screen);
  final String screen;
}

final class ButtonTapped extends AnalyticsEvent {
  const ButtonTapped(this.buttonId);
  final String buttonId;
}

/// Added in a later release; existing consumers keep compiling.
final class PurchaseCompleted extends AnalyticsEvent {
  const PurchaseCompleted(this.amountCents);
  final int amountCents;
}
```

<!-- snippet: 03_class_modifiers/analytics_logger -->
```dart
import 'analytics_event.dart';

String logLine(AnalyticsEvent event) => switch (event) {
  ScreenViewed(:final screen) => 'screen_view:$screen',
  ButtonTapped(:final buttonId) => 'tap:$buttonId',
  _ => 'event:${event.runtimeType}', // Required: the root is `final`, not `sealed`.
};
```

## Flutter framework'teki gerçek kullanımlar

`flutter/flutter` **3.47.5**, `packages/flutter/lib` içinde satır başındaki
bildirim sayıları (`dart run dartadvance_tool:dartadvance flutter-src grep --count '<regex>'`):

| Regex | Sayı |
|---|---|
| `^sealed class ` | 9 |
| `^final class ` | 77 |
| `^base class ` | 3 |
| `^abstract base class ` | 2 |
| `^interface class ` | 0 |
| `^abstract interface class ` | 17 |
| `^abstract final class ` | 33 |
| `^mixin class ` | 6 |
| `^abstract mixin class ` | 3 |
| `^(abstract )?base mixin class ` / `^base mixin ` | 0 / 0 |
| `^(abstract )?(base \|final \|interface \|sealed )+class ` (toplam) | 141 |
| karşılaştırma: `^abstract class ` / `^class ` | 291 / 2887 |

Framework kodunun büyük kısmı Dart 3 öncesinden kalma düz `class`'tır; modifier'lar
yeni veya yeniden tasarlanan API'lerde görülüyor.

| Bildirim | Ne gösteriyor | Kaynak |
|---|---|---|
| `sealed class ScrollCacheExtent` | Private `._()` constructor + `const factory .pixels()` / `.viewport()` ile private alt tiplere yönlendirme: `sealed` ama dışarıya factory ile "construct edilebilir" görünen API | [rendering/viewport.dart#L42](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/viewport.dart#L42) |
| `sealed class IOSSystemContextMenuItem` | Mimarideki kalıbın aynısı: `sealed` kök + her buton için `final class` alt tip | [widgets/system_context_menu.dart#L240](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/system_context_menu.dart#L240) |
| `final class IOSSystemContextMenuItemCopy extends IOSSystemContextMenuItem` | Sealed ailenin kapalı yaprağı | [widgets/system_context_menu.dart#L280](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/system_context_menu.dart#L280) |
| `sealed class DragGestureRecognizer` | `sealed` geçişli değil: alt tipleri `VerticalDragGestureRecognizer` vb. düz `class` ([L931](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/monodrag.dart#L931)), yani kullanıcılar onları extend edebilir ama `DragGestureRecognizer`'ı doğrudan edemez | [gestures/monodrag.dart#L81](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/monodrag.dart#L81) |
| `base class PipelineOwner` | Dışarıda implement edilemeyen, extend edilebilen altyapı sınıfı | [rendering/object.dart#L1019](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/object.dart#L1019) |
| `final class _DefaultRootPipelineOwner extends PipelineOwner` | **Base transitivity**: başka library'den (`binding.dart`) `base` sınıfı extend eden alt tip `final` işaretli | [rendering/binding.dart#L906](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/rendering/binding.dart#L906) |
| `abstract base class MultiPreview` | Kullanıcının extend ederek (`previews` getter'ı) kendi annotation'ını yazdığı, implement edemediği taban | [widget_previews/widget_previews.dart#L244](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widget_previews/widget_previews.dart#L244) |
| `abstract interface class HitTestTarget` | Tek metotlu saf sözleşme (`handleEvent`); yalnızca `implements` | [gestures/hit_test.dart#L44](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/gestures/hit_test.dart#L44) |
| `final class IconData` | Dışarıda alt tiplenemeyen `@immutable` değer sınıfı | [widgets/icon_data.dart#L23](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/icon_data.dart#L23) |
| `abstract final class Colors` | Yalnızca `static const` taşıyan namespace: ne construct ne alt tip (33 örnekten biri: `Icons`, `Curves`, `SystemChrome`...) | [material/colors.dart#L281](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/material/colors.dart#L281) |
| `mixin class ChangeNotifier` | Hem `extends ChangeNotifier` hem `with ChangeNotifier` ile kullanılabilmesi için (geriye uyumluluk) | [foundation/change_notifier.dart#L139](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/foundation/change_notifier.dart#L139) |
| `abstract mixin class WidgetsBindingObserver` | Doc'u açıkça "extend, mix in veya implement edilebilir" der; construct edilemez | [widgets/binding.dart#L86](https://github.com/flutter/flutter/blob/3.47.5/packages/flutter/lib/src/widgets/binding.dart#L86) |

## Lint'ler

Aşağıdakilerin hiçbiri `core` veya `recommended` setinde değil; hepsi opsiyonel.

| Lint | Set | Ne yapar |
|---|---|---|
| [implicit_reopen](https://dart.dev/tools/linter-rules/implicit_reopen) | hiçbiri (experimental, 3.0) | `interface`/`base`/`final`/`sealed` bir sınıfın alt tipinin kısıtı istemeden gevşetmesini (ör. `interface class I` → `class C extends I`) yakalar; bilinçliyse `package:meta`'nın `@reopen`'ı |
| [avoid_implementing_value_types](https://dart.dev/tools/linter-rules/avoid_implementing_value_types) | hiçbiri | `==` override eden sınıfı `implements` etmeyi yasaklar (equality sözleşmesi miras alınmaz) |
| [prefer_mixin](https://dart.dev/tools/linter-rules/prefer_mixin) | hiçbiri | `with` içinde `mixin` olmayan tip kullanımını işaretler |
| [avoid_classes_with_only_static_members](https://dart.dev/tools/linter-rules/avoid_classes_with_only_static_members) | hiçbiri | Yalnızca static üyeli sınıf yerine top-level üye önerir (Flutter'ın `abstract final class Colors` gibi sabit grupları Effective Dart'ın izin verdiği istisnadır) |

Not: [one_member_abstracts](https://dart.dev/tools/linter-rules/one_member_abstracts)
Dart 3.13 itibarıyla **deprecated** (ileride kaldırılacak); analysis_options'a ekleme.
Aynı rehber [Effective Dart](https://dart.dev/effective-dart/design#avoid-defining-a-one-member-abstract-class-when-a-simple-function-will-do)'te
geçerliliğini koruyor.

## Kontrol listesi

- [ ] Varyantlar üzerinde exhaustive `switch` gerekiyor mu? → `sealed` kök + `final` alt tipler; `_` case yazma.
- [ ] Hiyerarşi başka paketlere açık ve ileride alt tip eklenecek mi? → `sealed` yerine `final` kök (tüketiciler `_` taşır).
- [ ] Repository/DataSource sözleşmesi `abstract interface class` mı?
- [ ] UseCase ve somut implementasyonlar `final class` mı?
- [ ] `base` bir sınıfı extend eden her alt tip `base`/`final`/`sealed` mı? (transitivity)
- [ ] `sealed` kökün alt tiplerinin dışarıda extend edilmesi istenmiyor mu? → alt tipleri de `final` işaretle (sealed geçişli değil).
- [ ] Modifier sadece library-private bir sınıfa mı ekleniyor? → gereksiz.
- [ ] Yayınlanan paketteki bir sınıfa modifier eklemek/değiştirmek → major sürüm.
- [ ] `mixin class` yerine pure `mixin` veya pure `class` yetiyor mu?
- [ ] `pubspec.yaml` SDK alt sınırı ≥ 3.0 mı?

## Skill ile üret

Videoda örneği gösterdikten sonra paralel oturumda skill'e verilecek istekler. Tarif, SKILL.md §4 "Görev modu" ile uygulanır.

### Tarif: Sealed UI state ailesi + exhaustive render
- **Demo promptu:** "Sipariş detay ekranı için başlangıç, yükleniyor, yüklendi ve hata durumlarını taşıyan bir state ailesi ve her durumu metne çeviren, `_` kullanmayan bir render fonksiyonu yaz."
- **Model:** [`examples/lib/03_class_modifiers/profile_state.dart`](../../../examples/lib/03_class_modifiers/profile_state.dart), [`examples/lib/03_class_modifiers/profile_view.dart`](../../../examples/lib/03_class_modifiers/profile_view.dart)
- **Katman:** Application / state sınıfı + Presentation
- **Adımlar:** 1. Kökü `sealed class` yap, `const` constructor ver. 2. Her durumu `final class` alt tip yap (sealed geçişli değil; yapraklar açık kalmasın). 3. Hata durumu `Failure` taşısın. 4. Render'ı ayrı dosyada switch expression ile yaz; iç içe `Failure` alt tiplerini de ayrı case'lerle eşleştir, `_` yazma.
- **Kabul kriteri:** Switch'te `_` yok; test her durum ve her `Failure` alt tipi için ayrı metni doğrular; yeni alt tip eklenince render derleme hatası verir.
- **Min. sürüm:** 3.0

### Tarif: Repository sözleşmesi, implementasyonu ve UseCase
- **Demo promptu:** "Fatura modülü için `abstract interface class` bir repository, onu başka dosyada implement eden bellek içi bir Data sınıfı ve `call()` ile çağrılan bir `final` UseCase yaz."
- **Model:** [`examples/lib/03_class_modifiers/profile_repository.dart`](../../../examples/lib/03_class_modifiers/profile_repository.dart), [`examples/lib/03_class_modifiers/in_memory_profile_repository.dart`](../../../examples/lib/03_class_modifiers/in_memory_profile_repository.dart), [`examples/lib/03_class_modifiers/get_profile.dart`](../../../examples/lib/03_class_modifiers/get_profile.dart)
- **Katman:** Domain + Data
- **Adımlar:** 1. Entity'yi `final class` yap. 2. Repository'yi `abstract interface class` yap; metotlar `Future<Result<T>>` dönsün. 3. Implementasyonu ayrı dosyada `final class ... implements ...` olarak yaz; hata yollarını erken `return` ile `Err` yap. 4. UseCase'i `final class` + `call()` ile yaz, repository'yi constructor'dan alsın.
- **Kabul kriteri:** Test dosyası (başka library) repository'yi `implements` ile sahteleyebilir; başarı `Ok`, çevrimdışı ve bulunamayan kayıt ayrı `Failure` alt tipleri döner.
- **Min. sürüm:** 3.0

### Tarif: `base` altyapı sınıfı + `final` somut notifier
- **Demo promptu:** "Kargo takip ekranı için dinleyici listesini yöneten ortak bir `abstract base class` notifier altyapısı ve onu başka dosyada extend eden, repository sonucunu state'e çeviren bir notifier yaz."
- **Model:** [`examples/lib/03_class_modifiers/state_notifier.dart`](../../../examples/lib/03_class_modifiers/state_notifier.dart), [`examples/lib/03_class_modifiers/profile_notifier.dart`](../../../examples/lib/03_class_modifiers/profile_notifier.dart)
- **Katman:** Application / state sınıfı (düz Dart)
- **Adımlar:** 1. Altyapıyı `abstract base class` yap; private state ve dinleyici listesi tut. 2. `emit` dinleyici listesinin kopyası üzerinde dönsün. 3. Somut notifier'ı ayrı dosyada `final class ... extends` olarak yaz (base transitivity: düz `class` derlenmez). 4. Yükleme metodu önce "yükleniyor" state'ini yaysın, sonra `Result` üzerinde switch expression ile sonucu.
- **Kabul kriteri:** Dinleyici "yükleniyor → yüklendi" sırasını görür; kaldırılan dinleyici state almaz; hata sonucu hata state'ine döner.
- **Min. sürüm:** 3.0

### Tarif: Kırılmadan genişleyen `final` kök hiyerarşi
- **Demo promptu:** "Paylaşılan bir modül için bildirim olayları hiyerarşisi yaz; sonradan yeni olay tipi eklemek tüketici switch'lerini kırmasın."
- **Model:** [`examples/lib/03_class_modifiers/analytics_event.dart`](../../../examples/lib/03_class_modifiers/analytics_event.dart), [`examples/lib/03_class_modifiers/analytics_logger.dart`](../../../examples/lib/03_class_modifiers/analytics_logger.dart)
- **Katman:** Domain (paket / modül sınırı)
- **Adımlar:** 1. Kökü `sealed` değil `abstract final class` yap. 2. Olayları `final class` alt tip yap. 3. Tüketiciyi ayrı dosyada yaz; bilinen tipler için case, kalanı için zorunlu `_`. 4. Testte "sonradan eklenen" bir alt tipin `_`'e düştüğünü göster.
- **Kabul kriteri:** Tüketici switch'i `_` taşır ve yeni alt tip eklenince derlenmeye devam eder; yeni alt tip varsayılan satırı üretir.
- **Min. sürüm:** 3.0

### Tarif: Varsayılanlı `interface class` (ve `mixin class` ne zaman)
- **Demo promptu:** "Kampanya modülü için gerçek zamanı dönen, testte sabit bir tarihle yeniden implement edilebilen ama extend edilemeyen bir saat sınıfı yaz."
- **Model:** [`examples/lib/03_class_modifiers/clock.dart`](../../../examples/lib/03_class_modifiers/clock.dart), [`examples/lib/03_class_modifiers/mixin_class.dart`](../../../examples/lib/03_class_modifiers/mixin_class.dart)
- **Katman:** Domain / Data yardımcı servis
- **Adımlar:** 1. Sınıfı `interface class` yap (abstract değil), `const` constructor ve çalışan varsayılan metot ver. 2. Testte `final class _Fixed... implements ...` ile sabit implementasyon yaz. 3. Hem `with` hem `extends` gerekmedikçe `mixin class` kullanma; yeni kodda pure `mixin` veya pure `class`.
- **Kabul kriteri:** Varsayılan sınıf construct edilir ve gerçek değer döner; test dosyasındaki yeniden implementasyon sabit değeri döner.
- **Min. sürüm:** 3.0

### Tarif: JSON'dan sealed domain ailesine, `Result` ile
- **Demo promptu:** "Teslimat yöntemleri (kurye, kargo, mağazadan teslim) için sealed bir aile, `_` olmadan ücret hesaplayan fonksiyon ve JSON'u `Result` olarak bu aileye çeviren bir decoder yaz."
- **Model:** [`examples/lib/03_class_modifiers/practice/ex1_payment_methods.dart`](../../../examples/lib/03_class_modifiers/practice/ex1_payment_methods.dart), [`examples/lib/03_class_modifiers/practice/ex3_charge.dart`](../../../examples/lib/03_class_modifiers/practice/ex3_charge.dart)
- **Katman:** Domain + Data
- **Adımlar:** 1. `sealed` kök + `final class` yapraklar; hesap fonksiyonu `_` olmadan switch; özel değerli pattern genel case'ten önce. 2. JSON tipini `Json` alias'ıyla al (02). 3. Alt tip seçimini `switch (json)` map pattern'li private yardımcıya koy (eşleşmezse `null`). 4. Tutarı `int value when value >= 0` guard'ıyla oku. 5. Eksik/yanlışta `Err(UnexpectedFailure(...))`, aksi halde `Ok`.
- **Kabul kriteri:** Hesap switch'inde `_` yok; ondalık tutar, bilinmeyen tip ve geçersiz alan `Err` döner; geçerli JSON doğru alt tipi ve ücreti verir.
- **Min. sürüm:** 3.0

## Pekiştirme

### Alıştırma 1 · Kapalı ödeme yöntemleri (kolay)
`sealed class PaymentMethod` ve üç `final class` alt tip yaz: `CardPayment(last4)`,
`CashPayment`, `WalletPayment(provider)`. `int feeMinor(PaymentMethod, int amountMinor)`
`_` case **olmadan** exhaustive bir `switch` ile ücreti hesaplasın (kart %2, nakit 0,
`'promo'` cüzdan 0, diğer cüzdanlar 50). Alt tipler neden `final`? (`sealed` geçişli
değil.)

**İpucu:** "API sahibi için kurallar" → `sealed` geçişli değildir; [the-sealed-modifier](https://dart.dev/language/class-modifiers-for-apis#the-sealed-modifier).

<details><summary>Çözüm</summary>

<!-- snippet: 03_class_modifiers/practice/ex1_payment_methods -->
```dart
sealed class PaymentMethod {
  const PaymentMethod();
}

final class CardPayment extends PaymentMethod {
  const CardPayment(this.last4);
  final String last4;
}

final class CashPayment extends PaymentMethod {
  const CashPayment();
}

final class WalletPayment extends PaymentMethod {
  const WalletPayment(this.provider);
  final String provider;
}

int feeMinor(PaymentMethod method, int amountMinor) => switch (method) {
  CardPayment() => amountMinor * 2 ~/ 100,
  CashPayment() => 0,
  WalletPayment(provider: 'promo') => 0,
  WalletPayment() => 50,
};
```

</details>

### Alıştırma 2 · Sepet: interface sözleşme + `base` altyapı (orta)
Domain'de `abstract interface class CartRepository` (`Future<Result<int>> addItem(String sku)`),
Application'da `sealed class CartState` (`CartIdle(itemCount)`, `CartAdding`,
`CartFailed(failure)`) ve bu konudaki `StateNotifier<S>`'i (başka library'deki
`abstract base class`) extend eden `CartNotifier` yaz. Presentation'da `cartBadge`
her state ve her `Failure` için `_` olmadan metin üretsin. Repository'yi test
dosyasında `implements` ile sahte olarak yaz. `CartNotifier` neden düz `class`
olamaz?

**İpucu:** Base transitivity: başka library'den `base` bir sınıfı extend eden tip `base`/`final`/`sealed` olmalı ([base-transitivity](https://dart.dev/language/class-modifiers-for-apis#base-transitivity)).

<details><summary>Çözüm</summary>

<!-- snippet: 03_class_modifiers/practice/ex2_cart_state -->
```dart
import '../../00_architecture/result.dart';

abstract interface class CartRepository {
  Future<Result<int>> addItem(String sku);
}

sealed class CartState {
  const CartState();
}

final class CartIdle extends CartState {
  const CartIdle(this.itemCount);
  final int itemCount;
}

final class CartAdding extends CartState {
  const CartAdding();
}

final class CartFailed extends CartState {
  const CartFailed(this.failure);
  final Failure failure;
}
```

<!-- snippet: 03_class_modifiers/practice/ex2_cart_notifier -->
```dart
import '../../00_architecture/result.dart';
import '../state_notifier.dart';
import 'ex2_cart_state.dart';

final class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._repository) : super(const CartIdle(0));
  final CartRepository _repository;

  Future<void> add(String sku) async {
    emit(const CartAdding());
    final result = await _repository.addItem(sku);
    emit(switch (result) {
      Ok(:final value) => CartIdle(value),
      Err(:final failure) => CartFailed(failure),
    });
  }
}

String cartBadge(CartState state) => switch (state) {
  CartIdle(itemCount: 0) => 'Empty',
  CartIdle(:final itemCount) => '$itemCount item(s)',
  CartAdding() => 'Adding...',
  CartFailed(failure: NetworkFailure()) => 'Offline',
  CartFailed(failure: ServerFailure(:final statusCode)) => 'Error $statusCode',
  CartFailed(failure: UnexpectedFailure()) => 'Try again',
};
```

</details>

### Alıştırma 3 · JSON'dan sealed aileye, `Result` ile (zor)
Alıştırma 1'deki `PaymentMethod` ailesini kullanarak Data katmanında
`Result<Charge> decodeCharge(Json json)` yaz (`Json` = Typedefs konusundaki alias;
`Charge` = `final class`, `method` + `amountMinor` + `totalMinor`). `amount_minor`
yalnızca negatif olmayan `int` olsun (`19.99` → `Err`); bilinmeyen `type` veya
4 haneli olmayan `last4` → `Err(UnexpectedFailure(...))`. `chargeLabel(json)`
`Result` üzerinde exhaustive switch ile `'5,05'` gibi tutar ya da hata mesajı
döndürsün (Built-in types + Typedefs konuları ile birlikte).

**İpucu:** Tutar `int` minor unit, biçimleme `~/` ve `%` ile ([01 · Built-in types](01-builtin-types.md) "Katmanlarda"); `Json` alias'ı `Object?` taşır ([02 · Typedefs](02-typedefs.md)).

<details><summary>Çözüm</summary>

<!-- snippet: 03_class_modifiers/practice/ex3_charge -->
```dart
import '../../00_architecture/result.dart';
import '../../02_typedefs/json_alias.dart';
import 'ex1_payment_methods.dart';

final class Charge {
  const Charge(this.method, this.amountMinor);
  final PaymentMethod method;
  final int amountMinor;

  int get totalMinor => amountMinor + feeMinor(method, amountMinor);
}

PaymentMethod? _method(Json json) => switch (json) {
  {'type': 'card', 'last4': String last4} when last4.length == 4 => CardPayment(last4),
  {'type': 'cash'} => const CashPayment(),
  {'type': 'wallet', 'provider': String provider} => WalletPayment(provider),
  _ => null,
};

Result<Charge> decodeCharge(Json json) {
  final method = _method(json);
  final amountMinor = switch (json['amount_minor']) {
    int value when value >= 0 => value,
    _ => null,
  };
  if (method == null || amountMinor == null) {
    return Err(UnexpectedFailure(FormatException('Bad charge: $json'), StackTrace.current));
  }
  return Ok(Charge(method, amountMinor));
}

String _formatMinor(int minor) => '${minor ~/ 100},${(minor % 100).toString().padLeft(2, '0')}';

String chargeLabel(Json json) => switch (decodeCharge(json)) {
  Ok(value: Charge(:final totalMinor)) => _formatMinor(totalMinor),
  Err(:final failure) => failure.message,
};
```

</details>

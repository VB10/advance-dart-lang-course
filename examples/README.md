# atlas_examples

Single source of truth for every snippet on the site. Nothing is hand-copied
into `site/`; `dart run atlas snippets` extracts regions from here into
`site/lib/generated/snippets.dart`.

## Layout

```
lib/<slug>/<topic>.dart        # runnable, analyzer-clean code
test/<slug>/<topic>_test.dart  # proves every snippet does what the page says
```

`<slug>` = last path segment of the dart.dev URL
(`https://dart.dev/language/typedefs` → `typedefs`).

## Regions

```dart
// #docregion basic
typedef IntList = List<int>;
// #enddocregion basic
```

Snippet id = `<slug>/<file-without-.dart>#<region>`
(e.g. `typedefs/typedefs#basic`). A file without markers is exported whole
under `<slug>/<file>`. Marker lines never appear in the output.

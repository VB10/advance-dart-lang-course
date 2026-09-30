import 'package:dartadvance_tool/dartadvance_tool.dart';
import 'package:test/test.dart';

void main() {
  group('extractRegions', () {
    test('returns the whole file under "" when there are no markers', () {
      expect(extractRegions('\nvoid main() {}\n'), {'': 'void main() {}'});
    });

    test('extracts, dedents and strips marker lines', () {
      const source = '''
class A {
  // #docregion field
  final int x = 1;
  // #enddocregion field
}
''';
      expect(extractRegions(source), {'field': 'final int x = 1;'});
    });

    test('supports nested regions', () {
      const source = '''
// #docregion outer
a();
// #docregion inner
b();
// #enddocregion inner
// #enddocregion outer
''';
      expect(extractRegions(source), {'outer': 'a();\nb();', 'inner': 'b();'});
    });

    test('rejects unclosed and unopened regions', () {
      expect(() => extractRegions('// #docregion x\n'), throwsFormatException);
      expect(() => extractRegions('// #enddocregion x\n'), throwsFormatException);
    });
  });

  group('syncMarkdown', () {
    const snippets = {'01_typedefs/json#alias': 'typedef Json = Map<String, Object?>;'};

    test('replaces the fenced block after a marker', () {
      const md = '# T\n<!-- snippet: 01_typedefs/json#alias -->\n```dart\nold\n```\ntail';
      expect(
        syncMarkdown(md, snippets),
        '# T\n<!-- snippet: 01_typedefs/json#alias -->\n```dart\n'
        'typedef Json = Map<String, Object?>;\n```\ntail',
      );
    });

    test('is idempotent', () {
      const md = '<!-- snippet: 01_typedefs/json#alias -->\n```dart\nx\n```';
      final once = syncMarkdown(md, snippets);
      expect(syncMarkdown(once, snippets), once);
    });

    test('rejects unknown ids and missing blocks', () {
      expect(
        () => syncMarkdown('<!-- snippet: nope -->\n```dart\n```', snippets),
        throwsFormatException,
      );
      expect(
        () => syncMarkdown('<!-- snippet: 01_typedefs/json#alias -->\ntext', snippets),
        throwsFormatException,
      );
    });
  });

  test('dartDevAnchorLinks finds only anchored dart.dev links', () {
    const md =
        'See [a](https://dart.dev/language/typedefs#x) and '
        '[b](https://dart.dev/language/typedefs) and https://dart.dev/language/functions#generators.';
    expect(dartDevAnchorLinks(md), {
      'https://dart.dev/language/typedefs#x',
      'https://dart.dev/language/functions#generators',
    });
  });

  test('flutterPermalink points at the pinned tag', () {
    expect(
      flutterPermalink('packages/flutter/lib/src/foundation/basic_types.dart', 12),
      'https://github.com/flutter/flutter/blob/$flutterTag/'
      'packages/flutter/lib/src/foundation/basic_types.dart#L12',
    );
  });
}

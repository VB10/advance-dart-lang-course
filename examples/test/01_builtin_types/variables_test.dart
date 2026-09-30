import 'package:dartadvance_examples/01_builtin_types/final_vs_const.dart';
import 'package:dartadvance_examples/01_builtin_types/late_initializer.dart';
import 'package:dartadvance_examples/01_builtin_types/late_vs_nullable.dart';
import 'package:dartadvance_examples/01_builtin_types/lazy_top_level.dart';
import 'package:dartadvance_examples/01_builtin_types/wildcards.dart';
import 'package:test/test.dart';

void main() {
  test('const is canonicalized and deeply immutable while final content can change', () {
    expect(identical(const [1], const [1]), isTrue);
    expect(identical([1], [1]), isFalse);
    expect(identical(zeroTry, const Money(0, 'TRY')), isTrue);
    expect(() => supportedLocales.add('de'), throwsUnsupportedError);
    recentSearches.add('flutter');
    expect(recentSearches, ['dart', 'flutter']);
  });

  test('a static initializer runs once, on first read, without late', () {
    expect(configReads, 0);
    expect(AppConfig.timeoutSeconds, 30);
    expect(AppConfig.timeoutSeconds, 30);
    expect(configReads, 1);
  });

  test('a late initializer runs once, on first read', () {
    final index = SearchIndex(['Dart', 'Flutter']);
    expect(index.builds, 0);
    expect(index.contains('dart'), isTrue);
    expect(index.contains('FLUTTER'), isTrue);
    expect(index.builds, 1);
  });

  test('a nullable field starts as null and can answer "is it loaded?"', () {
    final cache = ProfileCache();
    expect(cache.isLoaded, isFalse);
    expect(cache.name, 'Guest');
    cache.load('Ada');
    expect(cache.isLoaded, isTrue);
    int? lineCount;
    expect(lineCount, isNull);
  });

  test('wildcards do not bind but their initializer still runs', () {
    expect(countCallbacks([(_, _) {}, ignoreBoth]), 2);
    expect(sizes, [0, 0]);
    var sideEffects = 0;
    var _ = sideEffects++;
    expect(sideEffects, 1);
  });
}

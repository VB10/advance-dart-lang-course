import 'package:dartadvance_examples/01_builtin_types/grapheme_length.dart';
import 'package:dartadvance_examples/01_builtin_types/integer_division.dart';
import 'package:dartadvance_examples/01_builtin_types/variable_kinds.dart';
import 'package:dartadvance_examples/01_builtin_types/wildcards_and_null_aware.dart';
import 'package:test/test.dart';

void main() {
  group('grapheme_length', () {
    test('String.length counts UTF-16 code units, characters counts what the user sees', () {
      expect(codeUnitLength(wave), 4);
      expect(visibleLength(wave), 1);
      expect(visibleLength('Hi 🇩🇰'), 4);
    });

    test('substring by code units splits a flag into a lone surrogate', () {
      const text = 'Hi 🇩🇰';
      final lastUnit = text.substring(text.length - 1).codeUnits.single;
      expect(lastUnit, inInclusiveRange(0xDC00, 0xDFFF));
    });

    test('truncateBio never splits a grapheme cluster', () {
      expect(truncateBio('Hi 🇩🇰!', 4), 'Hi 🇩🇰…');
      expect(truncateBio('Hi 🇩🇰', 4), 'Hi 🇩🇰');
      expect(truncateBio('👨‍👩‍👦👨‍👩‍👦', 1), '👨‍👩‍👦…');
    });
  });

  group('integer_division', () {
    test('~/ gives the same page count as the double detour, without doubles', () {
      expect(pages(25, 10), 3);
      expect(pages(20, 10), 2);
      expect(pages(0, 10), 0);
      expect(pagesNaive(25, 10), pages(25, 10));
    });

    test('~/ truncates toward zero, not toward negative infinity', () {
      expect(truncatedHalf(-7), -3);
      expect(truncatedHalf(7), 3);
    });

    test('% is never negative while remainder keeps the dividend sign', () {
      expect(wrapIndex(-1, 5), 4);
      expect(signedRemainder(-1, 5), -1);
    });
  });

  group('variable_kinds', () {
    test('a final list can still be mutated, a const list cannot', () {
      recentSearches.add('flutter');
      expect(recentSearches, ['dart', 'flutter']);
      expect(() => supportedLocales.add('de'), throwsUnsupportedError);
    });

    test('identical const values are the same canonical instance', () {
      expect(identical(const ['en', 'tr'], supportedLocales), isTrue);
    });

    test('a late final initializer runs once, on first read', () {
      final catalog = ProductCatalog(['Shoe', 'Hat']);
      expect(catalog.indexBuilds, 0);
      expect(catalog.contains('SHOE'), isTrue);
      expect(catalog.contains('hat'), isTrue);
      expect(catalog.indexBuilds, 1);
      catalog.contains('hat');
      expect(catalog.indexBuilds, 1);
    });

    test('a getter rebuilds on every read, late final does not', () {
      final catalog = ProductCatalog(['Shoe']);
      catalog.indexEveryRead;
      catalog.indexEveryRead;
      expect(catalog.indexBuilds, 2);
    });
  });

  group('wildcards_and_null_aware', () {
    test('?.. skips the cascade on null and returns the receiver otherwise', () {
      expect(withNote(null, 'gift'), isNull);
      expect(withNote(Cart(), 'gift')?.note, 'gift');
    });

    test('...? spreads nothing for a null list', () {
      expect(allTags(['a'], null), ['a']);
      expect(allTags(['a'], ['b']), ['a', 'b']);
    });

    test('the verbose null check behaves like ?..', () {
      expect(withNoteVerbose(null, 'gift'), isNull);
      expect(withNoteVerbose(Cart(), 'gift')?.note, 'gift');
    });

    test('two _ parameters coexist', () {
      expect(() => ignoreBoth(1, 'x'), returnsNormally);
    });
  });
}

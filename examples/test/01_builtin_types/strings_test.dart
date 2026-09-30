import 'package:dartadvance_examples/01_builtin_types/code_units.dart';
import 'package:dartadvance_examples/01_builtin_types/const_strings.dart';
import 'package:dartadvance_examples/01_builtin_types/grapheme_length.dart';
import 'package:dartadvance_examples/01_builtin_types/raw_strings.dart';
import 'package:dartadvance_examples/01_builtin_types/string_interpolation.dart';
import 'package:test/test.dart';

void main() {
  test('interpolation and adjacent literals build one string; constant parts make a const', () {
    expect(greeting('Ada', 2), 'Hi Ada, you have 3 new messages.');
    expect(userAgent, 'Shop/42 beta=true');
  });

  test('raw strings keep backslashes literally', () {
    expect(rawNewline.length, 2);
    expect(datePattern.hasMatch('2026-09-29'), isTrue);
    expect(datePattern.hasMatch('29.09.2026'), isFalse);
  });

  test('== compares code units, so two renderings of é are different strings', () {
    expect(precomposed == decomposed, isFalse);
    expect(precomposed.length, 4);
    expect(decomposed.length, 5);
  });

  test('length counts UTF-16 code units and runes counts code points', () {
    expect(measure('Dart'), (codeUnits: 4, runes: 4));
    expect(measure('\u{1D11E}'), (codeUnits: 2, runes: 1));
    expect(measure('👋🏽'), (codeUnits: 4, runes: 2));
    expect(measure('👨‍👩‍👦'), (codeUnits: 8, runes: 5));
    expect(measure('Hi 🇩🇰'), (codeUnits: 7, runes: 5));
  });

  test('substring by code units can split a flag into a lone low surrogate', () {
    const hi = 'Hi 🇩🇰';
    final end = hi.substring(hi.length - 1);
    expect(end.length, 1);
    expect(end.codeUnits.single, inInclusiveRange(0xDC00, 0xDFFF));
  });

  test('characters counts what the user sees', () {
    expect(visibleLength('Dart'), 4);
    expect(visibleLength('👋🏽'), 1);
    expect(visibleLength('👨‍👩‍👦'), 1);
    expect(visibleLength('Hi 🇩🇰'), 4);
  });

  test('truncate never splits a grapheme cluster', () {
    expect(truncate('Hi 🇩🇰!', 4), 'Hi 🇩🇰…');
    expect(truncate('Hi 🇩🇰', 4), 'Hi 🇩🇰');
    expect(truncate('👨‍👩‍👦👨‍👩‍👦', 1), '👨‍👩‍👦…');
  });
}

import 'package:dartadvance_examples/01_builtin_types/cascades.dart';
import 'package:dartadvance_examples/01_builtin_types/if_null.dart';
import 'package:dartadvance_examples/01_builtin_types/null_aware_spread.dart';
import 'package:dartadvance_examples/01_builtin_types/null_shorting.dart';
import 'package:dartadvance_examples/01_builtin_types/shifts.dart';
import 'package:dartadvance_examples/01_builtin_types/type_tests.dart';
import 'package:test/test.dart';

void main() {
  test('?? and ??= evaluate the right side only when needed', () {
    expect(playerName(null), 'Guest');
    expect(playerName('Ada'), 'Ada');
    final cache = ThemeCache();
    expect(cache.mode, 'dark');
    expect(cache.mode, 'dark');
    expect(cache.loads, 1);
  });

  test('?. skips the rest of the chain on null and ! throws on null', () {
    expect(cityLength(null), isNull);
    expect(cityLength(const Customer(Address('Izmir'))), 5);
    String? missing;
    expect(() => missing!, throwsA(isA<TypeError>()));
  });

  test('a cascade returns the receiver and ?.. on null does nothing', () {
    expect(buildQuery({'q': 'dart', 'page': '2'}), '?q=dart&page=2&');
    expect(StringBuffer()..write('a'), isA<StringBuffer>());
    expect(appendDone(null), isNull);
    expect(appendDone(['start']), ['start', 'done', 'closed']);
  });

  test('as throws on the wrong type while is, is! and patterns do not', () {
    expect(castLength('abc'), 3);
    expect(() => castLength(3), throwsA(isA<TypeError>()));
    expect(safeLength(3), isNull);
    expect(isNotText(3), isTrue);
    expect(patternLength('abcd'), 4);
    expect(patternLength(3), isNull);
  });

  test('...? spreads nothing for a null collection', () {
    expect(tags(['a'], null), ['a']);
    expect(tags(['a'], ['b']), ['a', 'b']);
  });

  test('>>> shifts in zeros so a negative operand becomes positive (native)', () {
    expect(signedShift(flags), 0x02);
    expect(unsignedShift(flags), 0x02);
    expect(signedShift(-flags), -0x03);
    expect(unsignedShift(-flags), greaterThan(0));
  });
}

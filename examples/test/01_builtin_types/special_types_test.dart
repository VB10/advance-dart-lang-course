import 'package:dartadvance_examples/01_builtin_types/explicit_booleans.dart';
import 'package:dartadvance_examples/01_builtin_types/never_helper.dart';
import 'package:dartadvance_examples/01_builtin_types/object_vs_dynamic.dart';
import 'package:dartadvance_examples/01_builtin_types/symbols.dart';
import 'package:test/test.dart';

void main() {
  test('a Never helper throws and promotes the checked value afterwards', () {
    expect(readCount(3), 3);
    expect(() => readCount('3'), throwsFormatException);
  });

  test('Object? keeps static checks while dynamic fails only at runtime', () {
    expect(describeValue(null), 'nothing');
    expect(describeValue('ab'), 'text of 2 code units');
    expect(describeValue(true), 'true');
    expect(unsafeLength('abc'), 3);
    expect(() => unsafeLength(3), throwsNoSuchMethodError);
  });

  test('conditions check empty, zero, null and NaN explicitly', () {
    expect(shouldShowBadge('New', 1, null, 0.5), isTrue);
    expect(shouldShowBadge('', 1, null, 0.5), isFalse);
    expect(shouldShowBadge('New', 1, null, 0 / 0), isFalse);
  });

  test('a symbol names a named argument and is a canonical constant', () {
    expect(parseWithApply('11', 16), 17);
    expect(identical(#radix, const Symbol('radix')), isTrue);
  });
}

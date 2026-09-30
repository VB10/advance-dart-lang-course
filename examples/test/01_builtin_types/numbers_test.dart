import 'dart:math' as math;

import 'package:dartadvance_examples/01_builtin_types/const_arithmetic.dart';
import 'package:dartadvance_examples/01_builtin_types/digit_separators.dart';
import 'package:dartadvance_examples/01_builtin_types/integer_division.dart';
import 'package:dartadvance_examples/01_builtin_types/num_type.dart';
import 'package:dartadvance_examples/01_builtin_types/number_parsing.dart';
import 'package:test/test.dart';

void main() {
  test('num holds an int and later a double; an int literal assigned to double is a double', () {
    expect(total, isA<int>());
    addHalf();
    expect(total, 3.5);
    expect(total, isA<double>());
    expect(ratio, 1.0);
    expect(ratio, isA<double>());
  });

  test('/ gives a double, ~/ truncates toward zero, % is Euclidean, remainder keeps sign', () {
    final result = divide(7, 2);
    expect(result.slash, 3.5);
    expect(result.tilde, 3);
    expect(result.negativeTilde, -3);
    expect(result.modulo, 1);
    expect(result.remainder, -1);
    expect(5 ~/ 2, 2);
  });

  test('digit separators and arithmetic on constants stay compile-time constants', () {
    expect(oneMillion, 1000000);
    expect(tiny, 1e-11);
    expect(macAddress, 0x001422012345);
    expect(millisecondsUntilRetry, 5000);
  });

  test('tryParse returns null where parse throws; num.parse picks int when it can', () {
    expect(parseQuantity(' 12 '), 12);
    expect(parseQuantity('x'), isNull);
    expect(int.tryParse('1f'), isNull);
    expect(() => int.parse('x'), throwsFormatException);
    expect(int.parse('0x42'), 66);
    expect(parseHexColor('ff'), 255);
    expect(num.parse('42'), isA<int>());
    expect(num.parse('0.50'), isA<double>());
    expect(3.14159.toStringAsFixed(2), '3.14');
  });

  test('double is IEEE 754 binary floating point and NaN is not equal to itself', () {
    expect(0.1 + 0.2 == 0.3, isFalse);
    final nan = 0.0 / 0.0;
    expect(nan == nan, isFalse);
    expect((0 / 0).isNaN, isTrue);
  });

  test('the VM matches the native column of the number-representation tables', () {
    expect(1.0 == 1, isTrue);
    expect(identical(1.0, 1), isFalse); // true on the web
    expect(1.0 is int, isFalse); // true on the web
    expect(1.0.toString(), '1.0'); // "1" on the web
    expect(math.pow(2, 53) + 1, 9007199254740993); // 9007199254740992 on the web
    expect(-1 >> 0, -1); // 4294967295 on the web
  });
}

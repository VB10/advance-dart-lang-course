import 'package:dartadvance_examples/02_typedefs/practice/ex1_unit_aliases.dart';
import 'package:test/test.dart';

void main() {
  test('Celsius and Fahrenheit are both just double', () {
    expect(Celsius, double);
    expect(Fahrenheit, Celsius);
    expect(toFahrenheit(100), 212);
  });

  test('the wrong unit is accepted silently', () {
    const Fahrenheit bodyTemp = 98.6;
    // Treated as Celsius: no compile error, just a wrong number.
    expect(convertTwice(bodyTemp), closeTo(209.48, 1e-9));
    expect(convertTwice(bodyTemp), isA<double>());
  });
}

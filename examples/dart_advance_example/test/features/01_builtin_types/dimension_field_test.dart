import 'package:dart_advance_example/features/01_builtin_types/model/dimension_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final field = DimensionField();

  test('double.parse throws on a Turkish decimal comma and on typos', () {
    expect(() => field.parseWrong('12,5'), throwsFormatException);
    expect(() => field.parseWrong('12a'), throwsFormatException);
  });

  test('tryParse reads the comma and returns null instead of throwing', () {
    expect(field.parse('12,5'), 12.5);
    expect(field.parse(' 40 '), 40);
    expect(field.parse('12a'), isNull);
    expect(field.errorText('12a'), isNotNull);
    expect(field.errorText('12,5'), isNull);
  });
}

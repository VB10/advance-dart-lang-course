import 'package:dartadvance_examples/04_libraries_metadata/versioning/legacy_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('a library pinned with // @dart runs alongside newer libraries', () {
    expect(formatCents(12345), '123.45');
    expect(formatCents(-5), '-0.05');
  });
}

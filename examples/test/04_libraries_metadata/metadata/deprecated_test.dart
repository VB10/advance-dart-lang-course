import 'package:dartadvance_examples/04_libraries_metadata/metadata/deprecated.dart';
import 'package:test/test.dart';

void main() {
  test('the replacement for a @Deprecated member works', () {
    final television = Television()..turnOn();
    expect(television.isOn, isTrue);
  });
}

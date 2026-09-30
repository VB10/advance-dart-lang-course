import 'package:dartadvance_examples/03_class_modifiers/amigo_other_library.dart';
import 'package:dartadvance_examples/03_class_modifiers/mixin_class.dart';
import 'package:dartadvance_examples/03_class_modifiers/sealed_amigo.dart';
import 'package:dartadvance_examples/03_class_modifiers/sealed_shape.dart';
import 'package:test/test.dart';

void main() {
  test('a switch over a sealed type covers every direct subtype without _', () {
    expect(lastName(Lucky()), 'Day');
    expect(lastName(Dusty()), 'Bottoms');
    expect(lastName(Ned()), 'Nederlander');
  });

  test('sealed is not transitive: subtypes of subtypes from another library still match', () {
    expect(lastName(OtherLucky()), 'Day');
    expect(lastName(OtherDusty()), 'Bottoms');
  });

  test('a switch over a sealed Shape computes every area', () {
    expect(calculateArea(Square(3)), 9);
    expect(calculateArea(Circle(1)), closeTo(3.14159, 1e-5));
  });

  test('a mixin class works both as a mixin and as a superclass', () {
    expect(UseAsMixin(), isA<Both>());
    expect(UseAsSuperclass(), isA<Both>());
    expect(Both(), isA<Both>());
  });
}

import 'package:dart_advance_example/features/01_builtin_types/model/brand_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brands = [
    Brand('Nova', 3),
    Brand('Arda', 1),
    Brand('Gizli', 0, visible: false),
    Brand('Mavi', 2),
  ];

  test('getter sorts on every read, late final sorts once', () {
    final wrong = BrandPage(brands);
    for (var i = 0; i < wrong.visibleWrong.length; i++) {
      wrong.visibleWrong[i];
    }
    expect(wrong.sorts, 7);

    final page = BrandPage(brands);
    for (var i = 0; i < page.visible.length; i++) {
      page.visible[i];
    }
    expect(page.sorts, 1);
  });

  test('both hide invisible brands and sort by order', () {
    final names = BrandPage(brands).visible.map((brand) => brand.name);
    expect(names, ['Arda', 'Mavi', 'Nova']);
    expect(BrandPage(brands).visibleWrong.map((b) => b.name), names);
  });
}

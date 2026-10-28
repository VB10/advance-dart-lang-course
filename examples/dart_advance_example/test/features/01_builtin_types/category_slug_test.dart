import 'package:dart_advance_example/features/01_builtin_types/model/category_slug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final slug = CategorySlug();

  test('[^a-z0-9] removes Turkish letters', () {
    expect(slug.slugWrong('Öne Çıkan Ürünler'), 'ne-kan-r-nler');
  });

  test('Turkish letters are mapped before cleaning', () {
    expect(slug.slug('Öne Çıkan Ürünler'), 'one-cikan-urunler');
    expect(slug.slug('İndirimli Ayakkabı & Çanta'), 'indirimli-ayakkabi-canta');
  });
}

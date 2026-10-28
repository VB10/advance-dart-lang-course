import 'package:dart_advance_example/features/01_builtin_types/model/photo_gallery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const gallery = PhotoGallery(5);

  test('remainder keeps the sign: back from the first photo is -1', () {
    expect(gallery.previousWrong(0), -1);
  });

  test('% wraps back from the first photo to the last', () {
    expect(gallery.previous(0), 4);
    expect(gallery.previous(3), 2);
  });
}

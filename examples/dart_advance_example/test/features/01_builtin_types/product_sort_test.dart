import 'package:dart_advance_example/features/01_builtin_types/model/product_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sort = ProductSort();

  test('..sort reorders the source list too', () {
    final products = ['Zeytinyağı', 'Bal', 'Peynir'];
    final az = sort.alphabeticalWrong(products);
    expect(identical(az, products), isTrue);
    expect(products, ['Bal', 'Peynir', 'Zeytinyağı']);
  });

  test('copy then cascade keeps the server order', () {
    final products = ['Zeytinyağı', 'Bal', 'Peynir'];
    expect(sort.alphabetical(products), ['Bal', 'Peynir', 'Zeytinyağı']);
    expect(products, ['Zeytinyağı', 'Bal', 'Peynir']);
  });
}

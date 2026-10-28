import 'package:collection/collection.dart';

/// Ürün listesi: her satırda 3 ürün.
final class ProductGrid {
  static const perRow = 3;

  // Olumsuz: sublist(i, i + 3) son satırda listenin dışına taşar → 7 üründe RangeError.
  List<List<String>> rowsWrong(List<String> products) => [
    for (var i = 0; i < products.length; i += perRow)
      products.sublist(i, i + perRow),
  ];

  // Olumlu: slices son satırı kalan kadar bırakır → 3, 3, 1.
  List<List<String>> rows(List<String> products) =>
      products.slices(perRow).toList();
}

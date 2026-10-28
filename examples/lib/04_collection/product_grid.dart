// Düzelt: /dartadvance Projemde listeyi satırlara, sayfalara ya da n'lik paketlere bölen ve
//    sublist / elle indeks hesabı kullanan yerleri bul. slices ile düzelt, n'e tam bölünmeyen
//    uzunlukla test yaz.
// Üret: /dartadvance Bana ürünleri her satırda 3 tane olacak şekilde satırlara bölen bir sınıf
//    yaz.
import 'package:collection/collection.dart';

/// Product list: three products per row.
final class ProductGrid {
  static const perRow = 3;

  // ✗ sublist(i, i + 3) runs past the end on the last row: 7 products throw RangeError.
  List<List<String>> rowsWrong(List<String> products) => [
    for (var i = 0; i < products.length; i += perRow) products.sublist(i, i + perRow),
  ];

  List<List<String>> rows(List<String> products) => products.slices(perRow).toList(); // 3, 3, 1
}

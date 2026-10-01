// /dartadvance Projemde elle yazılmış sınıfı `part` ile böldüğüm yerleri bul, `part of`
// string URI ve import kurallarıyla düzelt, her biri için test yaz.
import 'dart:collection';

part 'order_builder_lines.dart';

final class OrderBuilder {
  final Queue<_Line> _lines = Queue<_Line>();

  void add(String sku, {int quantity = 1}) => _addLine(this, sku, quantity);

  int get totalQuantity => _lines.fold(0, (sum, line) => sum + line.quantity); // 3 + 1: 4

  List<String> get skus => [for (final line in _lines) line.sku];
}

// Imports come from the main file (here: dart:collection).
part of 'order_builder.dart';

final class _Line {
  const _Line(this.sku, this.quantity);
  final String sku;
  final int quantity;
}

void _addLine(OrderBuilder builder, String sku, int quantity) {
  final Queue<_Line> lines = builder._lines;
  lines.addLast(_Line(sku, quantity));
}

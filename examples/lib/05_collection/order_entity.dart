import 'package:collection/collection.dart';

final class Order {
  Order({required this.id, required List<String> skus}) : skus = List.unmodifiable(skus);
  final String id;
  final List<String> skus;

  static const _skusEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) =>
      other is Order && other.id == id && _skusEquality.equals(other.skus, skus);

  @override
  int get hashCode => Object.hash(id, _skusEquality.hash(skus));
}

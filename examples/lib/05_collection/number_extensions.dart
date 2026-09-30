import 'package:collection/collection.dart';

({int total, double mean, int? highest}) stats(List<int> amounts) => (
  total: amounts.sum,
  mean: amounts.isEmpty ? 0 : amounts.average,
  highest: amounts.maxOrNull,
);

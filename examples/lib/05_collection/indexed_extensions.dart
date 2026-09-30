import 'package:collection/collection.dart';

({List<String> labels, List<String> evens, List<List<int>> pages, bool noneNegative}) indexedOps(
  List<String> names,
  List<int> ids,
) => (
  labels: names.mapIndexed((index, name) => '${index + 1}. $name').toList(),
  evens: names.whereIndexed((index, _) => index.isEven).toList(),
  pages: ids.slices(2).toList(),
  noneNegative: ids.none((id) => id < 0),
);

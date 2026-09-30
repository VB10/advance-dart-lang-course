import 'package:collection/collection.dart';

int _compare(int a, int b) => a.compareTo(b);

/// [sorted] must be sorted with the same comparator.
({int found, int missing, int insertAt}) searchSorted(List<int> sorted) => (
  found: sorted.binarySearch(30, _compare),
  missing: sorted.binarySearch(35, _compare),
  insertAt: sorted.lowerBound(35, _compare),
);

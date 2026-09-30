/// Dart 3.0 `Iterable` extensions: no import and no package needed.
({int? first, int? last, int? single, int? third, List<(int, String)> indexed, List<String> named})
coreHelpers(List<int> numbers, List<String?> maybeNames) => (
  first: numbers.firstOrNull,
  last: numbers.lastOrNull,
  single: numbers.singleOrNull, // null for zero OR for two-plus elements
  third: numbers.elementAtOrNull(2),
  indexed: [
    for (final (index, name) in ['a', 'b'].indexed) (index, name),
  ],
  named: maybeNames.nonNulls.toList(),
);

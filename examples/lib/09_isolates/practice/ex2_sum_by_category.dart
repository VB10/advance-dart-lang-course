/// Pure, synchronous CPU work over `category,amount` lines.
Map<String, double> sumByCategory(String csv) {
  final totals = <String, double>{};
  for (final line in csv.split('\n')) {
    if (line.trim().isEmpty) continue;
    final (category, amount) = _parseLine(line);
    totals[category] = (totals[category] ?? 0) + amount;
  }
  return totals;
}

(String, double) _parseLine(String line) => switch (line.split(',')) {
  [final category, final amount] => (category.trim(), double.parse(amount)),
  _ => throw FormatException('Bad sales line: $line'),
};

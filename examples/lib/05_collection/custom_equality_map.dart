import 'dart:collection';

Map<String, int> caseInsensitiveCounts(Iterable<String> words) {
  final counts = LinkedHashMap<String, int>(
    equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
    hashCode: (key) => key.toLowerCase().hashCode,
  );
  for (final word in words) {
    counts.update(word, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

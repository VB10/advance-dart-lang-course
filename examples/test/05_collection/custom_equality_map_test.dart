import 'package:dartadvance_examples/05_collection/custom_equality_map.dart';
import 'package:test/test.dart';

void main() {
  test('LinkedHashMap with custom equals/hashCode treats equal keys as one', () {
    final counts = caseInsensitiveCounts(['Dart', 'dart', 'DART', 'Flutter']);
    expect(counts.length, 2);
    expect(counts['dart'], 3);
    expect(counts.keys.first, 'Dart'); // first-inserted spelling is kept
  });
}

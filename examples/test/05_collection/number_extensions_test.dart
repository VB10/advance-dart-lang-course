import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/number_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('sum is 0 on empty; average and max throw on empty; maxOrNull is null', () {
    final result = stats([10, 20, 30]);
    expect((result.total, result.mean, result.highest), (60, 20.0, 30));
    expect(<int>[].sum, 0);
    expect(<int>[].maxOrNull, isNull);
    expect(() => <int>[].average, throwsStateError);
    expect(() => <int>[].max, throwsStateError);
  });
}

import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/first_where_or_null.dart';
import 'package:test/test.dart';

void main() {
  test('WhereOrNull lookups return null where core throws StateError', () {
    final found = lookups(['go', 'dart', 'flutter', 'js', 'kotlin']);
    expect(found.firstLong, 'flutter');
    expect(found.lastShort, 'js');
    expect(found.onlyEmpty, isNull);
    expect(['a', 'bb', 'cc'].singleWhereOrNull((word) => word.length == 2), isNull);
    expect(() => ['a', 'bb', 'cc'].singleWhere((word) => word.length == 2), throwsStateError);
    expect(() => ['a'].firstWhere((word) => word.isEmpty), throwsStateError);
  });
}

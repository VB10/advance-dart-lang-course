import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/content_equality.dart';
import 'package:test/test.dart';

void main() {
  test('collection == is identity; Equality classes compare contents', () {
    expect([1, 2] == [1, 2], isFalse);
    expect({1} == {1}, isFalse);
    expect({'a': 1} == {'a': 1}, isFalse);
    expect(contentEquality(), (list: true, set: true, map: true, deep: true, unorderedList: true));
    expect(const ListEquality<int>().equals([1, 2], [2, 1]), isFalse);
    expect(const ListEquality<int>().hash([1, 2]), const ListEquality<int>().hash([1, 2]));
    final shallow = const ListEquality<List<int>>();
    expect(
      shallow.equals(
        [
          <int>[1],
        ],
        [
          <int>[1],
        ],
      ),
      isFalse,
    ); // nested lists by identity
  });
}

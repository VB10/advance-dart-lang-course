import 'package:dartadvance_examples/05_collection/unmodifiable_view_vs_copy.dart';
import 'package:test/test.dart';

void main() {
  test('UnmodifiableListView is a live view; List.unmodifiable is a copy', () {
    final (:view, :copy) = viewVsCopy();
    expect(view, [1, 2, 3]);
    expect(copy, [1, 2]);
    expect(() => view.add(4), throwsUnsupportedError);
    expect(() => copy.add(4), throwsUnsupportedError);
    expect(() => List<int>.unmodifiableOf([1])[0] = 2, throwsUnsupportedError);
  });
}

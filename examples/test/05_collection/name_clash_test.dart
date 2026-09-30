// Both imports unprefixed on purpose: dart:collection and package:collection
// both declare `UnmodifiableSetView`.
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  test('unprefixed UnmodifiableSetView resolves to package:collection (no ambiguity)', () {
    final view = UnmodifiableSetView<int>({1});
    expect(view, isA<DelegatingSet<int>>()); // package:collection's implementation
    expect(() => view.add(2), throwsUnsupportedError);
    expect(SplayTreeSet<int>.of([2, 1]).toList(), [1, 2]); // dart:collection still usable
  });
}

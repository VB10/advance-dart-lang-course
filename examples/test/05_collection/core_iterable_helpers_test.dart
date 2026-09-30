import 'dart:collection' as sdk;

import 'package:collection/collection.dart';
import 'package:dartadvance_examples/05_collection/core_iterable_helpers.dart';
import 'package:test/test.dart';

void main() {
  test('core OrNull helpers, indexed and nonNulls need no import', () {
    final helpers = coreHelpers([10, 20, 30], ['a', null, 'b']);
    expect(helpers.first, 10);
    expect(helpers.last, 30);
    expect(helpers.single, isNull); // three elements: null, no throw
    expect(helpers.third, 30);
    expect(helpers.indexed, [(0, 'a'), (1, 'b')]);
    expect(helpers.named, ['a', 'b']);
    expect(<int>[].firstOrNull, isNull);
    expect([7].singleOrNull, 7);
    expect([1, 2].elementAtOrNull(5), isNull);
  });

  test('with package:collection imported, its extension member is the one used', () {
    // Core names the RangeError "index"; the package delegates to `skip` ("start").
    final iterable = Iterable<int>.generate(3);
    expect(
      () => sdk.IterableExtensions(iterable).elementAtOrNull(-1),
      throwsA(isA<RangeError>().having((error) => error.name, 'name', 'index')),
    );
    expect(
      () => iterable.elementAtOrNull(-1),
      throwsA(isA<RangeError>().having((error) => error.name, 'name', 'start')),
    );
  });
}

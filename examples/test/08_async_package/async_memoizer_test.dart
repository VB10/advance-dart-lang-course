import 'dart:async';

import 'package:dartadvance_examples/08_async_package/async_memoizer.dart';
import 'package:test/test.dart';

void main() {
  test('AsyncMemoizer runs the computation once for concurrent and later callers', () async {
    var loads = 0;
    final gate = Completer<Map<String, String>>();
    final loader = ConfigLoader(() {
      loads++;
      return gate.future;
    });

    final first = loader.config;
    final second = loader.config;
    expect(loader.hasLoaded, isTrue, reason: 'hasRun is true as soon as runOnce was called');
    gate.complete({'env': 'prod'});
    expect(await first, {'env': 'prod'});
    expect(await second, {'env': 'prod'});
    expect(await loader.config, {'env': 'prod'});
    expect(loads, 1);
  });

  test('AsyncMemoizer memoizes an error too', () async {
    var loads = 0;
    final loader = ConfigLoader(() async {
      loads++;
      throw StateError('disk');
    });
    await expectLater(loader.config, throwsStateError);
    await expectLater(loader.config, throwsStateError);
    expect(loads, 1, reason: 'no retry: the failed future is cached');
  });
}

import 'dart:async';

import 'package:dartadvance_examples/08_async_package/async_cache_ephemeral.dart';
import 'package:test/test.dart';

void main() {
  test('AsyncCache.ephemeral shares in-flight calls and refetches after completion', () async {
    var calls = 0;
    final gate = Completer<String>();
    final refresher = TokenRefresher(() {
      calls++;
      return calls == 1 ? gate.future : Future.value('token-$calls');
    });

    final first = refresher.refresh();
    final second = refresher.refresh();
    gate.complete('token-1');
    expect(await first, 'token-1');
    expect(await second, 'token-1');
    expect(calls, 1);

    expect(await refresher.refresh(), 'token-2');
  });
}

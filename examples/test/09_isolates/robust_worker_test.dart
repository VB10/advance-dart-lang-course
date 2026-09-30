import 'dart:isolate';

import 'package:dartadvance_examples/09_isolates/robust_worker.dart';
import 'package:test/test.dart';

void main() {
  test('the worker answers sequential and concurrent requests, then shuts down', () async {
    final worker = await JsonWorker.spawn();
    expect(await worker.parseJson('{"key":"value"}'), {'key': 'value'});
    expect(await worker.parseJson('"banana"'), 'banana');
    expect(await Future.wait([worker.parseJson('"yes"'), worker.parseJson('"no"')]), [
      'yes',
      'no',
    ]);

    await expectLater(worker.parseJson('{not json'), throwsA(isA<RemoteError>()));

    worker.close();
    await worker.exited.timeout(const Duration(seconds: 2));
    expect(() => worker.parseJson('1'), throwsStateError);
  });
}

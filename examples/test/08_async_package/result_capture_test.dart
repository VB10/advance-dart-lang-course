import 'package:dartadvance_examples/08_async_package/result_capture.dart';
import 'package:test/test.dart';

void main() {
  test('Result.capture never fails and release restores the value or the error', () async {
    final ok = await captureCount(Future.value(3));
    expect(ok.isValue, isTrue);
    expect(ok.asValue!.value, 3);

    final failed = await captureCount(Future.error(StateError('boom')));
    expect(failed.isError, isTrue);
    expect(failed.asError!.error, isStateError);

    expect(await releaseCount(Future.value(ok)), 3);
    await expectLater(releaseCount(Future.value(failed)), throwsStateError);
  });
}

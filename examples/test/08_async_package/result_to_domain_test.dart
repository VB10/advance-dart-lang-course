import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/08_async_package/result_capture.dart';
import 'package:dartadvance_examples/08_async_package/result_to_domain.dart';
import 'package:test/test.dart';

void main() {
  test('toDomain maps ValueResult to Ok and ErrorResult to Err(UnexpectedFailure)', () async {
    final ok = toDomain(await captureCount(Future.value(7)));
    expect(ok, isA<Ok<int>>().having((result) => result.value, 'value', 7));

    final err = toDomain(await captureCount(Future.error(const FormatException('bad'))));
    expect(
      err,
      isA<Err<int>>().having(
        (result) => result.failure,
        'failure',
        isA<UnexpectedFailure>().having((failure) => failure.error, 'error', isFormatException),
      ),
    );
  });
}

import 'package:dartadvance_examples/09_isolates/isolate_run.dart';
import 'package:dartadvance_examples/09_isolates/isolate_run_error.dart';
import 'package:test/test.dart';

void main() {
  test('Isolate.run returns the computation result', () async {
    expect(await fib(20), slowFib(20));
  });

  test('an error thrown in the isolate surfaces in the caller with its type', () async {
    await expectLater(failInIsolate(), throwsA(isA<StateError>()));
  });
}

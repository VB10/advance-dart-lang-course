import 'package:dartadvance_examples/09_isolates/unsendable_capture.dart';
import 'package:test/test.dart';

void main() {
  test('capturing an unsendable ReceivePort makes Isolate.run fail', () async {
    await expectLater(captureUnsendable(), throwsA(isA<ArgumentError>()));
  });
}

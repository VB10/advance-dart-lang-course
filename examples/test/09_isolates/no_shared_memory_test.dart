import 'package:dartadvance_examples/09_isolates/no_shared_memory.dart';
import 'package:test/test.dart';

void main() {
  test('isolates do not share memory: top-level state is copied', () async {
    requestCount = 0;
    expect(await incrementInIsolate(), 1);
    expect(await incrementInIsolate(), 1);
    expect(requestCount, 0);
  });
}

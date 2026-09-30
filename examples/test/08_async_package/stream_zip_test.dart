import 'package:dartadvance_examples/08_async_package/stream_zip.dart';
import 'package:test/test.dart';

void main() {
  test('StreamZip pairs events and stops at the shortest stream', () async {
    final zipped = labelled(
      Stream.fromIterable(['ann', 'bob', 'cem']),
      Stream.fromIterable([3, 5]),
    );
    expect(await zipped.toList(), ['ann=3', 'bob=5']);
  });
}

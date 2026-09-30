import 'dart:async';

import 'package:dartadvance_examples/07_streams/practice/ex3_download_events.dart';
import 'package:test/test.dart';

void main() {
  test('chunks become progress events followed by done', () async {
    final events = trackDownload(
      Stream.fromIterable([
        [1, 2, 3],
        [4, 5],
      ]),
      total: 5,
    );
    expect(await events.map(describeDownload).toList(), ['3/5', '5/5', 'done 5']);
  });

  test(
    'a source error becomes a final DownloadFailed event and later chunks are ignored',
    () async {
      final controller = StreamController<List<int>>();
      final collected = trackDownload(controller.stream, total: 10).toList();

      controller
        ..add([1, 2])
        ..addError(const FormatException('bad chunk'))
        ..add([3]);
      unawaited(controller.close());

      final result = await collected;
      expect(result.map(describeDownload), ['2/10', 'failed']);
      expect(
        result.last,
        isA<DownloadFailed>().having((failed) => failed.error, 'error', isA<FormatException>()),
      );
    },
  );
}

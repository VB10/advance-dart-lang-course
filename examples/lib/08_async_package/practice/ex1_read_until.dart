import 'package:async/async.dart' hide Result;

/// Stops before [terminator]; a stream without one returns everything read.
Future<List<String>> readUntil(Stream<String> lines, String terminator) async {
  final queue = StreamQueue(lines);
  try {
    final body = <String>[];
    while (await queue.hasNext) {
      final line = await queue.next;
      if (line == terminator) break;
      body.add(line);
    }
    return body;
  } finally {
    await queue.cancel();
  }
}

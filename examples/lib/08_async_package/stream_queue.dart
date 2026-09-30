import 'package:async/async.dart' hide Result;

/// Reads a header line such as `ORDER 2`, then exactly that many item lines.
Future<({String title, List<String> items})> readMessage(Stream<String> lines) async {
  final queue = StreamQueue(lines);
  try {
    final header = await queue.next;
    final [title, count] = header.split(' ');
    final items = await queue.take(int.parse(count));
    return (title: title, items: items);
  } finally {
    await queue.cancel();
  }
}

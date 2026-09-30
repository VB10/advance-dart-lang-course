import 'package:async/async.dart' hide Result;

/// Completes after `close()` and every added future; keeps insertion order.
Future<List<int>> uploadAll(Stream<Future<int>> uploads) async {
  final group = FutureGroup<int>();
  await for (final upload in uploads) {
    group.add(upload);
  }
  group.close();
  return group.future;
}

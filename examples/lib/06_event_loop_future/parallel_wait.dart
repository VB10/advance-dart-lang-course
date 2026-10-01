// /dartadvance Projemde birbirine bağlı olmayan `await`'leri art arda yazan repository
// yerlerini bul, record `.wait` ile paralel yap, her biri için test yaz.
import 'dart:async';

Future<String> loadSequential(Future<int> Function() unread, Future<String> Function() name) async {
  final count = await unread(); // name() starts only after this finishes
  return '${await name()} has $count unread';
}

Future<String> loadParallel(Future<int> Function() unread, Future<String> Function() name) async {
  try {
    final (count, userName) = await (unread(), name()).wait; // both start together
    return '$userName has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    final (count, userName) = error.values; // successes survive, failures are null
    return 'partial: name=$userName count=$count';
  }
}

/// Same-typed requests: results keep input order, only the first error is reported.
Future<List<int>> loadPrices(List<Future<int>> requests) => Future.wait(requests);

import 'dart:async';

/// Both requests start together; each field keeps its own type.
Future<String> loadDashboard(Future<int> unreadCount, Future<String> userName) async {
  try {
    final (count, name) = await (unreadCount, userName).wait;
    return '$name has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    // Successful results are still available; failed ones are null.
    final (count, name) = error.values;
    final (countError, _) = error.errors;
    return 'partial: name=$name count=$count countError=${countError?.error}';
  }
}

/// Same-typed requests: results keep input order, only the first error is reported.
Future<List<int>> loadPrices(List<Future<int>> requests) => Future.wait(requests);

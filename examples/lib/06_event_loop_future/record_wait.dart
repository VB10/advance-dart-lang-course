import 'dart:async';

Future<String> loadDashboard(Future<int> unread, Future<String> userName) async {
  try {
    final (count, name) = await (unread, userName).wait;
    return '$name has $count unread';
  } on ParallelWaitError<(int?, String?), (AsyncError?, AsyncError?)> catch (error) {
    final (count, name) = error.values;
    final (countError, _) = error.errors;
    return 'partial: name=$name count=$count countError=${countError?.error}';
  }
}

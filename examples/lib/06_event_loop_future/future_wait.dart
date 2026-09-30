/// Results keep the input order; the first error fails the whole wait.
Future<List<int>> fetchAllCounts(List<Future<int>> requests) => Future.wait(requests);

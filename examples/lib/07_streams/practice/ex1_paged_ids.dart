/// An early stop (`take`, `cancel()`) fetches no further page.
Stream<int> pagedIds(
  Future<List<int>> Function(int page) fetchPage, {
  required void Function() onReleased,
}) async* {
  try {
    for (var page = 0; ; page++) {
      final ids = await fetchPage(page);
      if (ids.isEmpty) return;
      yield* Stream.fromIterable(ids);
    }
  } finally {
    onReleased();
  }
}

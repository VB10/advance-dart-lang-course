/// Pages are fetched lazily; an early stop (`take`, `cancel`) asks for no more.
Stream<int> orderIds(
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

/// After cancel, the next `yield` acts as a `return`: `finally` runs.
Stream<int> endlessIds({
  required void Function(int id) onProduce,
  required void Function() onFinally,
}) async* {
  var id = 0;
  try {
    while (true) {
      await Future<void>.delayed(Duration.zero);
      onProduce(++id);
      yield id;
    }
  } finally {
    onFinally();
  }
}

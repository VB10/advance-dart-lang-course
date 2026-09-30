/// Splits a stream of consecutive string chunks into lines.
Stream<String> lines(Stream<String> source) async* {
  var partial = '';
  await for (final chunk in source) {
    var lines = chunk.split('\n');
    lines[0] = partial + lines[0];
    partial = lines.removeLast();
    for (final line in lines) {
      yield line;
    }
  }
  if (partial.isNotEmpty) yield partial;
}

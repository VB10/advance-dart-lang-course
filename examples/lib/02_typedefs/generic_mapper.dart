typedef Mapper<S, T> = T Function(S source);

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source),
];

final class SearchIndex {
  SearchIndex(this.items);
  final List<String> items;
  int builds = 0;

  late final Set<String> _lowercased = _build();

  Set<String> _build() {
    builds++;
    return {for (final item in items) item.toLowerCase()};
  }

  bool contains(String query) => _lowercased.contains(query.toLowerCase());
}

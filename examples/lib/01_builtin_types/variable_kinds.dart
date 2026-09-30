final recentSearches = <String>['dart'];

const supportedLocales = ['en', 'tr'];

final class ProductCatalog {
  ProductCatalog(this.names);
  final List<String> names;
  int indexBuilds = 0;

  // Runs once, on first read, because it is `late`.
  late final Set<String> lowercaseIndex = _buildIndex();

  Set<String> _buildIndex() {
    indexBuilds++;
    return {for (final name in names) name.toLowerCase()};
  }

  bool contains(String query) => lowercaseIndex.contains(query.toLowerCase());
}

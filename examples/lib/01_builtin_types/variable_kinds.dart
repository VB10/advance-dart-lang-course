// /dartadvance Projemde değişmemesi gereken listeleri ve her okumada yeniden
// hesaplanan getter'ları bul, `const` ve `late final` ile düzelt, her biri için test yaz.

final recentSearches = <String>['dart']; // add works: final is not deep

const supportedLocales = ['en', 'tr']; // add throws UnsupportedError

final class ProductCatalog {
  ProductCatalog(this.names);
  final List<String> names;
  int indexBuilds = 0;

  // Naive: rebuilds the index on every read.
  Set<String> get indexEveryRead => _buildIndex();

  late final Set<String> lowercaseIndex = _buildIndex(); // builds once

  Set<String> _buildIndex() {
    indexBuilds++;
    return {for (final name in names) name.toLowerCase()};
  }

  bool contains(String query) => lowercaseIndex.contains(query.toLowerCase());
}

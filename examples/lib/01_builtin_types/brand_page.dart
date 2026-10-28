// Düzelt: /dartadvance Projemde where, sort, map, fold gibi iş yapan getter'ları bul. build veya
//    itemBuilder içinde tekrar tekrar okunanları, kaynak değişmiyorsa late final'a ya da kaynak
//    değiştiğinde yenilenen bir alana çevir; çağrı sayısını testle ölç.
// Üret: /dartadvance Bana görünür markaları sıraya göre listeleyen bir sayfa state'i yaz; liste
//    build başına bir kez hesaplansın.

final class Brand {
  const Brand(this.name, this.order, {this.visible = true});

  final String name;
  final int order;
  final bool visible;
}

/// Brands grid: itemCount and itemBuilder read the list for every cell.
final class BrandPage {
  BrandPage(this.brands);

  final List<Brand> brands;
  int sorts = 0;

  // ✗ Looks like a field, runs where + sort on every read: 3 cells, 7 sorts.
  List<Brand> get visibleWrong => _sortVisible();

  late final List<Brand> visible = _sortVisible(); // 1 sort

  List<Brand> _sortVisible() {
    sorts++;
    return brands.where((b) => b.visible).toList()..sort((a, b) => a.order.compareTo(b.order));
  }
}

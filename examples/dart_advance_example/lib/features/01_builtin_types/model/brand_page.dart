/// Markalar sayfasında gösterilecek tek marka.
final class Brand {
  const Brand(this.name, this.order, {this.visible = true});

  final String name;
  final int order;
  final bool visible;
}

/// Markalar sayfası: görünür markaları sıra numarasına göre grid'de gösterir.
final class BrandPage {
  BrandPage(this.brands);

  final List<Brand> brands;
  int sorts = 0;

  // Olumsuz: getter her okumada süzüp sıralar; itemBuilder her hücrede okur → 3 marka, 7 sıralama.
  List<Brand> get visibleWrong => _sortVisible();

  // Olumlu: brands sonradan değişmiyor; late final ilk okumada bir kez sıralar → 1 sıralama.
  late final List<Brand> visible = _sortVisible();

  List<Brand> _sortVisible() {
    sorts++;
    return brands.where((brand) => brand.visible).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}

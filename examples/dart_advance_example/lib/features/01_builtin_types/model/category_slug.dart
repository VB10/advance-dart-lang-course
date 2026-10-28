/// Kategori başlığından paylaşım linkinin son parçası: 'Öne Çıkan Ürünler' → 'one-cikan-urunler'.
final class CategorySlug {
  static const _latin = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
  };

  // Olumsuz: [^a-z0-9] Türkçe harfleri de özel karakter sayar → 'ne-kan-r-nler'.
  String slugWrong(String title) => _clean(title.toLowerCase());

  // Olumlu: önce Türkçe harf Latin karşılığına çevrilir, sonra temizlenir.
  String slug(String title) => _clean(
    _lower(title)
        .replaceAllMapped(RegExp('[çğıöşü]'), (match) => _latin[match[0]]!),
  );

  String _clean(String text) => text
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _lower(String text) =>
      text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
}

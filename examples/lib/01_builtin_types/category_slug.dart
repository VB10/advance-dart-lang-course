// Düzelt: /dartadvance Projemde slug, dosya adı, analytics olay adı ya da snake_case anahtar
//    üreten ve [^a-z0-9], [^\w] gibi desenle özel karakter silen yerleri bul. Türkçe harfleri
//    önce Latin karşılığına çevir, 'Öne Çıkan Ürünler' girdisiyle test yaz.
// Üret: /dartadvance Bana kategori başlığından paylaşım linki parçası üreten bir sınıf yaz:
//    Türkçe harfleri çevirsin, boşluk ve özel karakterleri tire yapsın.

/// Share link of a category: 'Öne Çıkan Ürünler' → 'one-cikan-urunler'.
final class CategorySlug {
  static const _latin = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
  };

  // ✗ [^a-z0-9] treats Turkish letters as special characters: 'ne-kan-r-nler'.
  String slugWrong(String title) => _clean(title.toLowerCase());

  String slug(String title) => _clean(
    _lower(title).replaceAllMapped(
      RegExp('[çğıöşü]'),
      (match) => _latin[match[0]]!,
    ),
  ); // 'one-cikan-urunler'

  String _clean(String text) =>
      text.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  String _lower(String text) => text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
}

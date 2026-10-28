// Düzelt: /dartadvance Projemde sayfa, sekme ya da gün indeksini remainder ile veya
//    if (i < 0) i = len - 1 gibi elle saran yerleri bul. % ile düzelt, index 0 için test yaz.
// Üret: /dartadvance Bana ürün galerisi için ileri/geri gezinen bir sınıf yaz: ilk fotoğraftan
//    geri son fotoğrafa, sondan ileri ilk fotoğrafa dönsün.

/// Product gallery; "back" on the first photo goes to the last one.
final class PhotoGallery {
  const PhotoGallery(this.count);

  final int count;

  // ✗ remainder keeps the sign of the dividend: 0 → -1, photos[-1] throws RangeError.
  int previousWrong(int index) => (index - 1).remainder(count);

  int previous(int index) => (index - 1) % count; // 0 → count - 1

  int next(int index) => (index + 1) % count;
}

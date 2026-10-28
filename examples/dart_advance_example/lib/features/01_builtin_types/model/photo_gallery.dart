/// Ürün detayındaki fotoğraf galerisi; "geri" ilk fotoğraftan sonuncuya döner.
final class PhotoGallery {
  const PhotoGallery(this.count);

  final int count;

  // Olumsuz: remainder bölünenin işaretini alır; 0'dan geri → -1, photos[-1] RangeError.
  int previousWrong(int index) => (index - 1).remainder(count);

  // Olumlu: Dart'ın `%` sonucu hep 0 ile count - 1 arası; 0'dan geri → son fotoğraf.
  int previous(int index) => (index - 1) % count;
}

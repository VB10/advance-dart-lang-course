import 'package:collection/collection.dart';

/// Belge yükleme: kimlik fotoğrafı onay için önce gitmeli, ürün fotoğrafları sonra.
final class Upload {
  const Upload(this.name, {this.priority = 1});

  final String name;

  /// Küçük sayı önce gider.
  final int priority;
}

final class UploadQueue {
  // Olumsuz: List eklenme sırasıyla gider; kimlik 4. sırada bekler.
  List<String> orderWrong(List<Upload> uploads) => [
    for (final upload in uploads) upload.name,
  ];

  // Olumlu: PriorityQueue öncelik sırasıyla verir; eşit öncelikte ekleniş sırası korunmaz, gerekirse ikinci anahtar ekle.
  List<String> order(List<Upload> uploads) {
    final queue = PriorityQueue<Upload>(
      (a, b) => a.priority.compareTo(b.priority),
    )..addAll(uploads);
    return [for (final upload in queue.toList()) upload.name];
  }
}

// Düzelt: /dartadvance Projemde öncelikli iş kuyruğu (yükleme, bildirim, senkronizasyon) tutup
//    her eklemede sort çağıran ya da öncelik yerine eklenme sırasını kullanan yerleri bul.
//    PriorityQueue ile düzelt, sona eklenen yüksek öncelikli işle test yaz.
// Üret: /dartadvance Bana belge yükleme kuyruğu yaz: kimlik gibi öncelikli belgeler, sonradan
//    eklense de önce yüklensin.
import 'package:collection/collection.dart';

/// A file waiting to be uploaded.
final class Upload {
  const Upload(this.name, {this.priority = 1});

  final String name;

  /// Lower goes first.
  final int priority;
}

/// Seller application: the ID photo must upload before the product photos.
final class UploadQueue {
  // ✗ A List keeps insertion order: the ID added last waits behind every photo.
  List<String> orderWrong(List<Upload> uploads) => [
    for (final upload in uploads) upload.name,
  ];

  List<String> order(List<Upload> uploads) {
    final queue = PriorityQueue<Upload>((a, b) => a.priority.compareTo(b.priority))
      ..addAll(uploads);
    return [for (final upload in queue.toList()) upload.name]; // ID first
  }
}

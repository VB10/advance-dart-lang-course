// Düzelt: /dartadvance Projemde her tuş vuruşunda istek atan arama yerlerini bul,
//    CancelableOperation (package:async) ile son sorgu kazansın, her biri için test yaz.
// Üret: /dartadvance Bana kullanıcı yazdıkça şehir önerisi getiren, eski sorgunun geç gelen
//    cevabını yok sayan bir sınıf yaz.
import 'package:async/async.dart' hide Result;

final class ProductSearch {
  ProductSearch(this._fetch);
  final Future<List<String>> Function(String query) _fetch;
  CancelableOperation<List<String>>? _running;

  /// ✗ every reply is delivered, so a slow old reply can land last.
  Future<List<String>> searchWrong(String query) => _fetch(query); // stale: delivered

  Future<List<String>?> search(String query) {
    _running?.cancel();
    final operation = CancelableOperation.fromFuture(_fetch(query));
    _running = operation;
    return operation.valueOrCancellation(); // replaced query: null
  }
}

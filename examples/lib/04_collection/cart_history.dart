// Düzelt: /dartadvance Projemde state sınıflarında List/Set/Map alanlarını yerinde değiştiren
//    (add, remove, ..add, []=) yerleri bul. IList/ISet/IMap'e geç ya da yeni koleksiyon üret;
//    önceki state'in değişmediğini test et.
// Üret: /dartadvance Bana 'Geri al' destekli sepet state'i yaz: her ekleme yeni state üretsin,
//    öncekiler değişmesin. fast_immutable_collections kullan.
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// Cart with "Geri al": every add is a new state, undo returns the previous one.
final class CartHistory {
  // ✗ add changes the same list: the previous state sees the new item, undo does nothing.
  (List<String> before, List<String> after) addWrong(List<String> items, String item) =>
      (items, items..add(item));

  (IList<String> before, IList<String> after) add(IList<String> items, String item) =>
      (items, items.add(item)); // before stays ['Kahve', 'Kupa']
}

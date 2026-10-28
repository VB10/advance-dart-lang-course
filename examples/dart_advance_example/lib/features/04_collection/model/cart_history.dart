import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// Sepet ve "Geri al": her ekleme yeni bir state, geri al bir öncekine döner.
final class CartHistory {
  // Olumsuz: add aynı listeyi değiştirir; önceki state de yeni ürünü görür → geri al işe yaramaz.
  (List<String> before, List<String> after) addWrong(
    List<String> items,
    String item,
  ) => (items, items..add(item));

  // Olumlu: IList.add yeni liste döndürür; önceki state olduğu gibi kalır.
  (IList<String> before, IList<String> after) add(
    IList<String> items,
    String item,
  ) => (items, items.add(item));
}

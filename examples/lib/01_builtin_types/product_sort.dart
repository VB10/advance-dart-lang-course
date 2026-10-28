// Düzelt: /dartadvance Projemde ..sort, ..shuffle, ..removeWhere, ..add gibi listeyi yerinde
//    değiştiren cascade'leri ve sonucunu yeni bir değişkene atayan yerleri bul. Kaynak başka yerde
//    de kullanılıyorsa kopya üzerinde çalıştır, kaynağın değişmediğini test et.
// Üret: /dartadvance Bana ürünler ekranı için sunucu sırasını bozmadan A–Z, fiyata göre artan ve
//    azalan sıralı listeler üreten bir sınıf yaz.

/// Products screen: "Önerilen" in server order, an "A–Z" tab from the same list.
final class ProductSort {
  // ✗ `..sort` sorts in place and returns the same list: "Önerilen" becomes A–Z too.
  List<String> alphabeticalWrong(List<String> products) => products..sort();

  List<String> alphabetical(List<String> products) => [...products]..sort();
}

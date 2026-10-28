/// Ürünler ekranı: "Önerilen" sunucu sırasıyla, "A–Z" sekmesi aynı listeden sıralı.
final class ProductSort {
  // Olumsuz: `..sort` listeyi yerinde sıralar, aynı listeyi döndürür → "Önerilen" da A–Z olur.
  List<String> alphabeticalWrong(List<String> products) => products..sort();

  // Olumlu: önce kopya, sonra cascade; sunucu sırası korunur.
  List<String> alphabetical(List<String> products) => [...products]..sort();
}

/// Ürün ölçüsü alanı (cm); kullanıcı Türkçe klavyede ondalığı virgülle yazar.
final class DimensionField {
  // Olumsuz: double.parse yalnız noktayı tanır; '12,5' FormatException → Kaydet çöker.
  double parseWrong(String text) => double.parse(text);

  // Olumlu: virgül noktaya çevrilir, tryParse hata yerine null verir → alan hata yazar.
  double? parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String? errorText(String text) =>
      parse(text) == null ? 'Geçerli bir ölçü girin' : null;
}

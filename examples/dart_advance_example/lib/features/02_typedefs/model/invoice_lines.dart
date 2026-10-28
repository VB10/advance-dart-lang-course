typedef Json = Map<String, Object?>;
typedef JsonList = List<Json>;

/// Fatura ekranında API'den gelen satırları okuyup toplam tutarı bulan veri sınıfı.
final class InvoiceLines {
  // Olumsuz: `as double` JSON'daki 4 (int) değerinde TypeError atar → toplam hesaplanamaz.
  double totalWrong(List<Map<String, Object?>> rows) =>
      rows.fold<double>(0, (sum, row) => sum + (row['price']! as double));

  // Olumlu: `Json` alias'ı + `as num` int'i de double'ı da kabul eder → 4 + 12.5 = 16.5.
  double total(JsonList rows) =>
      rows.fold<double>(0, (sum, row) => sum + (row['price']! as num));
}

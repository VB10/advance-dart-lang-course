typedef Validator<T> = String? Function(T? value);

/// Sipariş formunda ürün adı, adet ve fiyat alanlarını doğrulayan form.
final class OrderForm {
  const OrderForm({this.name, this.quantity, this.price});

  final String? name;
  final int? quantity;
  final double? price;

  // Olumsuz: aynı sonuç, daha çok kod; `String? Function(T?)` her parametrede yeniden yazılıyor.
  List<String> errorsWrong(
    String? Function(String?) nameRule,
    String? Function(int?) quantityRule,
    String? Function(double?) priceRule,
  ) => [?nameRule(name), ?quantityRule(quantity), ?priceRule(price)];

  // Olumlu: aynı sonuç, daha az kod; `Validator<T>` imzayı bir kez adlandırır.
  List<String> errors(
    Validator<String> nameRule,
    Validator<int> quantityRule,
    Validator<double> priceRule,
  ) => [?nameRule(name), ?quantityRule(quantity), ?priceRule(price)];
}

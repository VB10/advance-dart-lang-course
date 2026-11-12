sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}

typedef AsyncResult<T> = Future<Result<T>>;

/// Ürün sayfasında stok ve fiyat sorgulayan servis.
final class StockService {
  // Olumsuz: `Future<Result<...>>` imzası her metotta yeniden yazılıyor; aynı sonuç, daha çok kod.
  Future<Result<int>> stockWrong(String sku) async => const Ok(12);
  Future<Result<double>> priceWrong(String sku) async => const Ok(24.5);

  // Olumlu: `AsyncResult<T>` imzayı bir kez adlandırır; sonuç aynı.
  AsyncResult<int> stock(String sku) async => const Ok(12);
  AsyncResult<double> price(String sku) async => const Ok(24.5);

  String describe(Result<int> result) => switch (result) {
    Ok(:final value) => 'Stok: $value',
    Err(:final message) => 'Hata: $message',
  };
}

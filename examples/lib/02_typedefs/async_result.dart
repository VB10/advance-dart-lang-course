// Düzelt: /dartadvance Projemde `Future<Result<T>>` imzasını her repository metodunda tekrar
//    eden yerleri bul, `typedef AsyncResult<T>` ile adlandır, test yaz.
// Üret: /dartadvance Bana stok ve fiyat sorgulayan, hata fırlatmayıp sonuç dönen bir
//    repository yaz; dönüş tipi tek bir typedef olsun.
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

typedef AsyncResult<T> = Future<Result<T>>; // Named once, reused in every signature.

Future<Result<int>> stockWrong(String sku) async => // Signature spelled out each time.
    sku == 'x' ? const Err('Stok yok') : const Ok(12);

AsyncResult<int> stock(String sku) async => sku == 'x' ? const Err('Stok yok') : const Ok(12);
AsyncResult<double> price(String sku) async => const Ok(24.5);

String describe(Result<int> result) => switch (result) {
  Ok(:final value) => 'Stok: $value',
  Err(:final message) => 'Hata: $message',
};

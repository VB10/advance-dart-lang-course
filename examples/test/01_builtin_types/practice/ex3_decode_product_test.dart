import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/01_builtin_types/practice/ex3_decode_product.dart';
import 'package:dartadvance_examples/01_builtin_types/product.dart';
import 'package:test/test.dart';

void main() {
  test('an integral rating becomes a double', () {
    final result = decodeProduct('{"id":1,"name":"Pen","price_minor":1999,"rating":4}');
    expect(result, isA<Ok<Product>>());
    final product = (result as Ok<Product>).value;
    expect(product.rating, isA<double>());
    expect(product.rating, 4.0);
    expect(product.priceMinor, 1999);
  });

  test('a null rating stays null', () {
    final result = decodeProduct('{"id":2,"name":"Ink","price_minor":500,"rating":null}');
    expect(result, isA<Ok<Product>>());
    expect((result as Ok<Product>).value.rating, isNull);
  });

  test('a double where an int is required is an Err, not a crash', () {
    final result = decodeProduct('{"id":1,"name":"Pen","price_minor":19.99,"rating":4}');
    expect(result, isA<Err<Product>>());
    final failure = (result as Err<Product>).failure;
    expect(failure, isA<UnexpectedFailure>());
    expect((failure as UnexpectedFailure).error, isA<FormatException>());
  });

  test('invalid JSON text is an Err too', () {
    final result = decodeProduct('{not json');
    expect(result, isA<Err<Product>>());
    expect((result as Err<Product>).failure, isA<UnexpectedFailure>());
  });
}

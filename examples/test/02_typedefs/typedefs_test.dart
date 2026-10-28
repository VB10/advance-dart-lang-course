import 'package:test/test.dart';

import 'package:dartadvance_examples/02_typedefs/alias_not_new_type.dart';
import 'package:dartadvance_examples/02_typedefs/function_typedefs.dart';
import 'package:dartadvance_examples/02_typedefs/json_alias.dart';

void main() {
  group('function_typedefs', () {
    test('a plain function fits the Mapper typedef', () {
      expect(wordCount, isA<Mapper<String, int>>());
    });

    test('mapAll and the inline version give the same result', () {
      expect(mapAll(['a b', 'c'], wordCount), [2, 1]);
      expect(mapInline(['a b', 'c'], wordCount), [2, 1]);
    });

    test('a validator function fits the Validator typedef', () {
      expect(couponRule, isA<Validator<String>>());
    });

    test('CouponField stores the error from its validator', () {
      final field = CouponField(validator: couponRule)..submit('ab');
      expect(field.error, 'Coupon is too short');
      field.submit('SUMMER');
      expect(field.error, isNull);
    });
  });

  group('json_alias', () {
    test('Json is the same type as Map<String, Object?>', () {
      expect(Json, Map<String, Object?>);
      expect(JsonList, List<Map<String, Object?>>);
    });

    test('fromJsonWrong (dynamic) crashes at runtime on an int price', () {
      expect(() => fromJsonWrong({'name': 'Tea', 'price': 4}), throwsA(isA<TypeError>()));
      expect(productFromJson({'name': 'Tea', 'price': 4}).price, 4.0);
    });

    test('productsFromJson accepts int and double prices', () {
      final products = productsFromJson([
        {'name': 'Tea', 'price': 4},
        {'name': 'Cake', 'price': 6.5},
      ]);
      expect(products.map((product) => product.price), [4.0, 6.5]);
    });

    test('productToJson returns a plain map', () {
      expect(productToJson(const Product('Tea', 4)), {'name': 'Tea', 'price': 4.0});
    });

    test('a generic alias is the same type as its expansion', () {
      expect(Cache<int>, Map<String, List<int>>);
      final cache = groupByFirstLetter([const Product('Tea', 4), const Product('Toast', 5)]);
      expect(cache['T'], hasLength(2));
    });
  });

  group('alias_not_new_type', () {
    test('the alias is the same type as int', () {
      expect(UserIdAlias, int);
    });

    test('the alias accepts any int, even a product count', () {
      expect(loadWithAlias(), 'user #42');
    });

    test('the extension type wraps the int behind its own name', () {
      expect(loadWithTyped(), 'user #7');
      expect(const UserId(7).value, 7);
    });
  });
}

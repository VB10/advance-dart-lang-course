import 'package:dartadvance_examples/05_collection/practice/ex1_resolve_coupon.dart';
import 'package:test/test.dart';

const _coupons = <Coupon>[
  (code: 'SUMMER15', percent: 15),
  (code: 'WELCOME10', percent: 10),
  (code: 'WINTER20', percent: 20),
];

void main() {
  test('exactly one match resolves; zero or two-plus matches are null', () {
    expect(resolveCoupon(_coupons, ' sum')?.percent, 15);
    expect(resolveCoupon(_coupons, 'W'), isNull);
    expect(resolveCoupon(_coupons, 'X'), isNull);
    expect(resolveCoupon(_coupons, ''), isNull);
  });

  test('core singleWhere throws where the package version returns null', () {
    expect(() => _coupons.singleWhere((c) => c.code.startsWith('W')), throwsStateError);
    expect(resolveCoupon(_coupons, 'WI')?.code, 'WINTER20');
  });
}

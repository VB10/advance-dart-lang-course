import 'package:collection/collection.dart';

typedef Coupon = ({String code, int percent});

/// `null` for zero matches and for an ambiguous prefix (two-plus matches).
Coupon? resolveCoupon(Iterable<Coupon> coupons, String input) {
  final prefix = input.trim().toUpperCase();
  if (prefix.isEmpty) return null;
  return coupons.singleWhereOrNull((coupon) => coupon.code.startsWith(prefix));
}

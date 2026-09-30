typedef Mapper<S, T> = T Function(S source);
typedef Validator<T> = String? Function(T? value);

class OrderDto {
  const OrderDto(this.id, this.total);
  final int id;
  final double total;
}

class Order {
  const Order(this.id, this.total);
  final int id;
  final double total;
}

Order orderFromDto(OrderDto dto) => Order(dto.id, dto.total);

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source),
];

String? couponRule(String? code) =>
    (code == null || code.length < 4) ? 'Coupon is too short' : null;

class CouponField {
  CouponField({required this.validator});
  final Validator<String> validator; // Any function with this shape fits.

  String? error;
  void submit(String? code) => error = validator(code);
}

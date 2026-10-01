// /dartadvance Projemde aynı fonksiyon imzasını birçok yerde tekrar eden callback ve
// validator tiplerini bul, `typedef` ile adlandır, her biri için test yaz.
typedef Mapper<S, T> = T Function(S source);
typedef Validator<T> = String? Function(T? value);

List<int> mapInline(List<String> items, int Function(String) map) => [
  for (final item in items) map(item), // Signature repeated at every use.
];

List<T> mapAll<S, T>(Iterable<S> sources, Mapper<S, T> map) => [
  for (final source in sources) map(source), // Named once, reused everywhere.
];

int wordCount(String text) => text.split(' ').length;

String? couponRule(String? code) =>
    (code == null || code.length < 4) ? 'Coupon is too short' : null; // 'ab': error

class CouponField {
  CouponField({required this.validator});
  final Validator<String> validator; // Any function with this shape fits.

  String? error;
  void submit(String? code) => error = validator(code);
}

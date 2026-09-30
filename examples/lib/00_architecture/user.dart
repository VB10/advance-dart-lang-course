/// Zero-cost typed ID: an `int` at runtime, not mixable with other ints.
extension type const UserId(int value) {}

final class User {
  const User({required this.id, required this.name});
  final UserId id;
  final String name;
}

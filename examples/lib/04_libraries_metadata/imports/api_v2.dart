/// Current API models: same top-level names as v1 on purpose.
library;

const apiVersion = 2;

final class User {
  const User({required this.id, required this.displayName});
  final int id;
  final String displayName;
}

User parseUser(Map<String, Object?> json) =>
    User(id: json['id']! as int, displayName: json['display_name']! as String);

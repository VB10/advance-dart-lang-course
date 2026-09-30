/// Legacy API models. Kept alive while callers migrate to v2.
library;

const apiVersion = 1;

final class User {
  const User(this.name);
  final String name;
}

User parseUser(Map<String, Object?> json) => User(json['name']! as String);

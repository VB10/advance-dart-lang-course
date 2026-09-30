import 'dart:math' as math;

import 'api_v1.dart' as v1;
import 'api_v2.dart' hide apiVersion;
import 'string_case.dart' as _; // Binds no name; its extensions still apply.

User migrateUser(v1.User legacy, {required int id}) =>
    User(id: id, displayName: legacy.name.capitalized);

Object parseAny(Map<String, Object?> json) => switch (json['version']) {
  v1.apiVersion => v1.parseUser(json),
  _ => parseUser(json),
};

int longestName(Iterable<User> users) =>
    users.fold(0, (longest, user) => math.max(longest, user.displayName.length));

import '../00_architecture/user_feature.dart' show User, UserId;
import 'generic_mapper.dart';
import 'json_alias.dart';

typedef _Partition = ({JsonList valid, int skipped});

_Partition _partition(JsonList rows) {
  final valid = [
    for (final row in rows)
      if (row case {'id': int(), 'name': String()}) row,
  ];
  return (valid: valid, skipped: rows.length - valid.length);
}

User _toUser(Json row) => User(id: UserId(row['id']! as int), name: row['name']! as String);

List<User> parseUsers(JsonList rows) {
  final (:valid, :skipped) = _partition(rows);
  if (skipped > 0) print('parseUsers: skipped $skipped malformed row(s)');
  return mapAll(valid, _toUser);
}

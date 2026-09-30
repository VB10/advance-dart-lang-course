import 'package:dartadvance_examples/04_libraries_metadata/imports/api_v1.dart' as v1;
import 'package:dartadvance_examples/04_libraries_metadata/imports/api_v2.dart' as v2;
import 'package:dartadvance_examples/04_libraries_metadata/imports/user_migration.dart';
import 'package:test/test.dart';

void main() {
  test('prefixed and unprefixed libraries with the same names coexist', () {
    final migrated = migrateUser(const v1.User('ada'), id: 7);

    expect(migrated, isA<v2.User>());
    expect(migrated.displayName, 'Ada'); // via the `_`-prefixed extension
    expect(v1.apiVersion, 1);
    expect(v2.apiVersion, 2);
  });

  test('parseAny dispatches on a prefixed constant', () {
    expect(parseAny({'version': 1, 'name': 'ada'}), isA<v1.User>());
    expect(
      parseAny({'version': 2, 'id': 1, 'display_name': 'Ada'}),
      isA<v2.User>().having((user) => user.id, 'id', 1),
    );
  });

  test('a prefixed dart:math import is used at the call site', () {
    final users = [
      const v2.User(id: 1, displayName: 'Ada'),
      const v2.User(id: 2, displayName: 'Grace'),
    ];
    expect(longestName(users), 5);
  });
}

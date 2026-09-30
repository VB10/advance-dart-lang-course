import 'package:dartadvance_examples/00_architecture/user_feature.dart' show UserId;
import 'package:dartadvance_examples/02_typedefs/generic_mapper.dart';
import 'package:dartadvance_examples/02_typedefs/json_alias.dart';
import 'package:dartadvance_examples/02_typedefs/private_record_alias.dart';
import 'package:test/test.dart';

void main() {
  test('Json is just Map<String, Object?> under another name', () {
    expect(Json, Map<String, Object?>);
    expect(JsonList, List<Map<String, Object?>>);
  });

  test('mapAll converts every source with a Mapper', () {
    expect(mapAll<int, String>([1, 2], (i) => '#$i'), ['#1', '#2']);
  });

  test('parseUsers keeps only well-formed rows via the private record alias', () {
    final users = parseUsers([
      {'id': 1, 'name': 'Ada'},
      {'id': '2', 'name': 'Bad id'},
      {'id': 3, 'name': 'Linus'},
    ]);
    expect(users.map((user) => user.name), ['Ada', 'Linus']);
    expect(users.first.id, const UserId(1));
  });
}

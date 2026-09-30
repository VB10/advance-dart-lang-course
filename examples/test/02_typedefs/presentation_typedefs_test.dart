import 'package:dartadvance_examples/00_architecture/user_feature.dart';
import 'package:dartadvance_examples/02_typedefs/callback_typedefs.dart';
import 'package:test/test.dart';

void main() {
  test('a callback typedef accepts any function with a matching signature', () {
    UserId? tapped;
    final controller = UserListController(
      onTap: (id) => tapped = id,
      validateQuery: (query) => (query == null || query.isEmpty) ? 'Required' : null,
    );
    controller.onTap(const UserId(9));
    expect(tapped, const UserId(9));
    expect(controller.search(''), 'Required');
    expect(controller.search('ada'), isNull);
  });
}

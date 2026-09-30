import 'package:dartadvance_examples/01_builtin_types/keyword_identifiers.dart';
import 'package:test/test.dart';

void main() {
  test('unrestricted keywords and built-in identifiers work as field names', () {
    final model = NotificationModel(type: 'promo', show: true, on: DateTime(2026));
    expect([model.type, model.show, model.on.year], ['promo', true, 2026]);
  });
}

import 'package:characters/characters.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/chat_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const message = 'Pazar kahvaltısı 👨‍👩‍👧 sizde mi?';
  final preview = ChatPreview();

  test('substring cuts the family emoji down to two people', () {
    final text = preview.textWrong(message);
    expect(text, contains('👨‍👩'));
    expect(text, isNot(contains('👨‍👩‍👧')));
  });

  test('characters keeps the emoji whole', () {
    final text = preview.text(message);
    expect(text, contains('👨‍👩‍👧'));
    expect(text.characters.length, ChatPreview.maxLength + 1);
  });

  test('short messages are left as they are', () {
    expect(preview.text('Tamam'), 'Tamam');
  });
}

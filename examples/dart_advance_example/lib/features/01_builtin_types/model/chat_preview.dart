import 'package:characters/characters.dart';

/// Sohbet listesinde son mesajın tek satırlık önizlemesi.
final class ChatPreview {
  static const maxLength = 22;

  // Olumsuz: substring UTF-16 birimiyle keser; aile emojisi 👨‍👩‍👧 ortadan bölünür → 👨‍👩.
  String textWrong(String message) => message.length <= maxLength
      ? message
      : '${message.substring(0, maxLength)}…';

  // Olumlu: characters ekranda görünen karakterle keser; emoji bütün kalır.
  String text(String message) {
    final characters = message.characters;
    return characters.length <= maxLength
        ? message
        : '${characters.take(maxLength)}…';
  }
}

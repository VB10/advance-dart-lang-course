// Düzelt: /dartadvance Projemde kullanıcıya görünen metni length, substring ya da [0] ile sayan,
//    kesen veya baş harfini alan yerleri bul (önizleme, sayaç, avatar). characters ile düzelt,
//    emojili girdiyle test yaz.
// Üret: /dartadvance Bana sohbet listesi için son mesaj önizlemesi yaz: 22 karakterde kessin,
//    emojiyi bölmesin.
import 'package:characters/characters.dart';

/// Chat list: one-line preview of the last message.
final class ChatPreview {
  static const maxLength = 22;

  // ✗ substring cuts UTF-16 units: the family emoji 👨‍👩‍👧 is split into 👨‍👩.
  String textWrong(String message) =>
      message.length <= maxLength ? message : '${message.substring(0, maxLength)}…';

  String text(String message) {
    final characters = message.characters;
    return characters.length <= maxLength
        ? message
        : '${characters.take(maxLength)}…'; // emoji stays whole
  }
}

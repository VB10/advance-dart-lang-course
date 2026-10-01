// /dartadvance Projemde kullanıcıya görünen metni `length` ya da `substring` ile
// sayan veya kesen yerleri bul, `characters` ile düzelt, her biri için test yaz.
import 'package:characters/characters.dart';

const wave = '👋🏽';

int codeUnitLength(String text) => text.length; // wave: 4

int visibleLength(String text) => text.characters.length; // wave: 1

String truncateBio(String bio, int maxCharacters) {
  final characters = bio.characters;
  if (characters.length <= maxCharacters) return bio;
  return '${characters.take(maxCharacters)}…';
}

import 'package:characters/characters.dart';

/// What the user sees, not UTF-16 code units: '👋🏽'.length is 4.
int visibleLength(String text) => text.characters.length;

String truncateBio(String bio, int maxCharacters) {
  final characters = bio.characters;
  if (characters.length <= maxCharacters) return bio;
  return '${characters.take(maxCharacters)}…';
}

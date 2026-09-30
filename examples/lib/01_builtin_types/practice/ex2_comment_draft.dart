// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 2)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int remaining = maxLength - _text.length;
//    Kullanıcı tek bir emoji ('👋🏽') girdiğinde Dart `.length == 4` sayar!
//    Kullanıcı ekranda 1 karakter görürken sistem 4 karakter harcar;
//    SMS sınırı veya tweet sınırı vaktinden önce dolar, kullanıcı çıldırır!
//
// 🎯 AMAÇ:
//    Grapheme cluster (`package:characters`) kullanarak kullanıcı gözündeki
//    gerçek karakterleri sayan ve sınırı aşan kısmı emojiyi parçalamadan kesen
//    temiz bir `CommentDraft` form state sınıfı yazmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana package:characters kullanarak emojileri tek karakter sayan,
//     maxLength sınırını aşan girdiyi doğru noktadan kesen ve remaining
//     kalan karakter sayısını hesaplayan bir CommentDraft sınıfı yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex2_comment_draft.dart
//    Test:  dart test test/01_builtin_types/practice/ex2_comment_draft_test.dart
// ============================================================================

import 'package:characters/characters.dart';

final class CommentDraft {
  CommentDraft({required this.maxLength});

  final int maxLength;
  String _text = '';

  String get text => _text;

  int get remaining => maxLength - _text.characters.length;

  void update(String input) {
    final characters = input.characters;
    _text = characters.length <= maxLength ? input : characters.take(maxLength).toString();
  }
}

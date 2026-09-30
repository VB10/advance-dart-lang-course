// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Model: Grapheme Length)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int count = '👋🏽'.length; // 4 döner!
//    text.substring(0, 3); // Emojiyi ortadan ikiye yarar, UI'da '' basar!
//
// 🎯 AMAÇ:
//    Görsel karakterleri (Grapheme Clusters) saymak ve metni kullanıcı
//    algısına uygun biçimde emojileri bozmadan güvenle kırpmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana package:characters kullanarak metnin ekranda görünen karakter
//     sayısını veren ve maxCharacters sınırına göre emojiyi bölmeden sonuna '…'
//     ekleyerek kesen bir truncate fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/grapheme_length.dart
//    Test:  dart test test/01_builtin_types/grapheme_test.dart
// ============================================================================

import 'package:characters/characters.dart';

int visibleLength(String text) => text.characters.length;

String truncate(String text, int maxCharacters) {
  final characters = text.characters;
  if (characters.length <= maxCharacters) return text;
  return '${characters.take(maxCharacters)}…';
}

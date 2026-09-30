// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 1)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    int day = -7 ~/ 2; // Sonuç: -3 döner! Beklenen: -4.
//    Dart'ın ~/ operatörü tabana (floor) değil sıfıra doğru yuvarlar (truncate).
//    Takvimde 7 gün geriye gitmek istediğinizde gün Pazar yerine Cumartesiye kayar!
//
// 🎯 AMAÇ:
//    Negatif sayıları da matematiksel olarak tabana yuvarlayan (floor division)
//    ve haftanın gün ofsetini (0-6) asla kaydırmayan güvenli bir takvim yardımcısı.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana negatif sayıları da güvenle tabana yuvarlayan (floor division)
//     ve haftalık gün ofsetini (0-6) doğru hesaplayan bir takvim fonksiyonu yaz.
//     Örnek: floorDiv(-7, 2) == -4 olmalı ve negatif böleni reddetmeli."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex1_floor_division.dart
//    Test:  dart test test/01_builtin_types/practice/ex1_floor_division_test.dart
// ============================================================================

int floorDiv(int a, int b) {
  if (b <= 0) throw ArgumentError.value(b, 'b', 'must be positive');
  return (a - a % b) ~/ b; // `%` is never negative, so this rounds down.
}

int weekdayIndex(int offset) => offset % 7;

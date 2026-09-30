// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Model: Integer Division)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    -7 ~/ 2; // -3 döner (Python'daki // gibi -4 değil!)
//    Dart'ın ~/ operatörü tabana değil sıfıra yuvarlar.
//    Ayrıca: -7 % 2 == 1 (asla negatif olmaz) iken (-7).remainder(2) == -1 döner!
//
// 🎯 AMAÇ:
//    Dart'taki 5 farklı bölme ve kalan operatörünün davranışını tek bir
//    tip güvenli record ile kanıtlamak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana iki tamsayı için /, ~/, negatif tilde, modulo (%) ve remainder
//     hesaplayıp isimli bir record dönen divide fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/integer_division.dart
//    Test:  dart test test/01_builtin_types/division_test.dart
// ============================================================================

({double slash, int tilde, int negativeTilde, int modulo, int remainder}) divide(int a, int b) => (
  slash: a / b,
  tilde: a ~/ b,
  negativeTilde: -a ~/ b, // Truncates toward zero: -3, not -4.
  modulo: -a % b, // Euclidean: never negative.
  remainder: (-a).remainder(b), // Keeps the sign of the dividend.
);

// Düzelt: /dartadvance Projemde iki List, Set ya da Map'i == veya != ile karşılaştıran yerleri ve
//    koleksiyon alanı olan sınıfların == metotlarını bul. ListEquality, SetEquality ya da
//    DeepCollectionEquality ile düzelt, aynı içerikli iki ayrı nesneyle test yaz.
// Üret: /dartadvance Bana filtre sheet'i için uygulanan ve taslak seçimi karşılaştıran,
//    değişiklik yoksa "Uygula"yı kapatan bir sınıf yaz.
import 'package:collection/collection.dart';

/// Filter sheet: "Uygula" is enabled only when the draft differs from the applied filter.
final class FilterDraft {
  // ✗ Set == compares identity: nothing changed, yet "Uygula" is enabled.
  bool canApplyWrong(Set<String> applied, Set<String> draft) => applied != draft;

  bool canApply(Set<String> applied, Set<String> draft) =>
      !const SetEquality<String>().equals(applied, draft); // order does not matter
}

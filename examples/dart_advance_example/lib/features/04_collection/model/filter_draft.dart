import 'package:collection/collection.dart';

/// Filtre sheet'i: seçim uygulanandan farklıysa "Uygula" açılır.
final class FilterDraft {
  // Olumsuz: Set'te `!=` içeriğe değil nesneye bakar → hiçbir şey değişmeden "Uygula" açık.
  bool canApplyWrong(Set<String> applied, Set<String> draft) =>
      applied != draft;

  // Olumlu: SetEquality içeriği karşılaştırır, sıra önemsiz.
  bool canApply(Set<String> applied, Set<String> draft) =>
      !const SetEquality<String>().equals(applied, draft);
}

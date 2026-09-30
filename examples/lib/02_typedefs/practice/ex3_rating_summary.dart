import '../json_alias.dart';

typedef _Totals = ({num sum, int count, int skipped});

_Totals _collect(JsonList rows) {
  num sum = 0;
  var count = 0;
  for (final row in rows) {
    if (row case {'score': num score}) {
      sum += score;
      count++;
    }
  }
  return (sum: sum, count: count, skipped: rows.length - count);
}

final class RatingSummary {
  const RatingSummary({required this.average, required this.count, required this.skipped});
  final double average;
  final int count;
  final int skipped;
}

RatingSummary summarize(JsonList rows) {
  final (:sum, :count, :skipped) = _collect(rows);
  return RatingSummary(average: count == 0 ? 0 : sum / count, count: count, skipped: skipped);
}

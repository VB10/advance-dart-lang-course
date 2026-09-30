import 'package:collection/collection.dart';

({String? firstLong, String? lastShort, String? onlyEmpty}) lookups(List<String> words) => (
  firstLong: words.firstWhereOrNull((word) => word.length > 4),
  lastShort: words.lastWhereOrNull((word) => word.length < 3),
  onlyEmpty: words.singleWhereOrNull((word) => word.isEmpty), // two-plus matches: null
);

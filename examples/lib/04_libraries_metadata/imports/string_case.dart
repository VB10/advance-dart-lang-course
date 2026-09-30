/// Extension-only library, meant to be imported with the `_` prefix.
library;

extension StringCase on String {
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

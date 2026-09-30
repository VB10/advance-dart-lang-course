// Formats amounts for the legacy export.
// @dart = 3.9

/// Pinned to 3.9: dot shorthands (3.10) are compile errors in this file.
String formatCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  return '$sign${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
}

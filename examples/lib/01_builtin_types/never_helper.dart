Never fail(String message) => throw FormatException(message);

int readCount(Object? raw) {
  if (raw is! int) fail('count must be an int, got $raw');
  return raw; // Promoted to int: `fail` never returns.
}

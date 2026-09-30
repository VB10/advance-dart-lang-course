int castLength(Object value) => (value as String).length;

int? safeLength(Object value) => value is String ? value.length : null;

bool isNotText(Object value) => value is! String;

int? patternLength(Object value) => switch (value) {
  String(:final length) => length,
  _ => null,
};

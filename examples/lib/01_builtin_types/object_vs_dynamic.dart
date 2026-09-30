String describeValue(Object? value) => switch (value) {
  null => 'nothing',
  String text => 'text of ${text.length} code units',
  int number => 'int $number',
  _ => value.toString(),
};

int unsafeLength(dynamic value) => value.length as int; // Compiles; fails at runtime for an int.

String buildQuery(Map<String, String> params) {
  final buffer = StringBuffer()..write('?');
  params.forEach(
    (key, value) => buffer
      ..write(key)
      ..write('=')
      ..write(value)
      ..write('&'),
  );
  return buffer.toString();
}

List<String>? appendDone(List<String>? log) => log
  ?..add('done')
  ..add('closed');

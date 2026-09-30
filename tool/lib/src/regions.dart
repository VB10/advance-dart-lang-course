final _start = RegExp(r'^\s*//\s*#docregion\s+([\w-]+)\s*$');
final _end = RegExp(r'^\s*//\s*#enddocregion\s+([\w-]+)\s*$');

/// Extracts `// #docregion name` … `// #enddocregion name` blocks.
///
/// Regions may nest or overlap; marker lines are never part of any output.
/// Each region is dedented by its smallest common indentation. When [source]
/// has no markers, the whole file is returned under the empty key `''`.
Map<String, String> extractRegions(String source) {
  final open = <String, List<String>>{};
  final done = <String, List<String>>{};
  final plain = <String>[];
  var hasMarkers = false;

  for (final line in source.split('\n')) {
    final start = _start.firstMatch(line);
    final end = _end.firstMatch(line);
    if (start != null) {
      hasMarkers = true;
      final name = start.group(1)!;
      if (open.containsKey(name) || done.containsKey(name)) {
        throw FormatException('Duplicate region "$name".');
      }
      open[name] = [];
    } else if (end != null) {
      final name = end.group(1)!;
      final lines = open.remove(name);
      if (lines == null) throw FormatException('Unopened region "$name".');
      done[name] = lines;
    } else {
      for (final lines in open.values) {
        lines.add(line);
      }
      plain.add(line);
    }
  }
  if (open.isNotEmpty) {
    throw FormatException('Unclosed region(s): ${open.keys.join(', ')}.');
  }
  if (!hasMarkers) return {'': _dedent(plain)};
  return {for (final MapEntry(:key, :value) in done.entries) key: _dedent(value)};
}

String _dedent(List<String> lines) {
  final trimmed = [...lines];
  while (trimmed.isNotEmpty && trimmed.first.trim().isEmpty) {
    trimmed.removeAt(0);
  }
  while (trimmed.isNotEmpty && trimmed.last.trim().isEmpty) {
    trimmed.removeLast();
  }
  final indents = [
    for (final line in trimmed)
      if (line.trim().isNotEmpty) line.length - line.trimLeft().length,
  ];
  final cut = indents.isEmpty ? 0 : indents.reduce((a, b) => a < b ? a : b);
  return [
    for (final line in trimmed) line.length >= cut ? line.substring(cut) : line.trimLeft(),
  ].join('\n');
}

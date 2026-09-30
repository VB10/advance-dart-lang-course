import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'regions.dart';
import 'workspace.dart';

/// The skill directory (relative to the workspace root); every `.md` file
/// under it is synced, SKILL.md included.
const skillDir = 'skills/dartadvance';

/// All markdown files of the skill, sorted.
List<File> skillMarkdownFiles(String root) =>
    Directory(p.join(root, skillDir))
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

final _marker = RegExp(r'^<!-- snippet: ([\w/.-]+(?:#[\w-]+)?) -->$');

/// Collects every snippet under `examples/lib`, keyed by snippet id.
///
/// Id format: `<topic>/<file>#<region>`, or `<topic>/<file>` for files
/// without region markers.
Map<String, String> collectSnippets(String root) {
  final libDir = Directory(p.join(root, 'examples', 'lib'));
  final files =
      libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final snippets = <String, String>{};
  for (final file in files) {
    final base = p.withoutExtension(p.relative(file.path, from: libDir.path));
    final id = p.posix.joinAll(p.split(base));
    for (final MapEntry(key: region, value: code) in extractRegions(
      file.readAsStringSync(),
    ).entries) {
      snippets[region.isEmpty ? id : '$id#$region'] = code;
    }
  }
  return snippets;
}

/// Rewrites every fenced block that directly follows a
/// `<!-- snippet: <id> -->` marker line with the snippet's current source.
///
/// Throws [FormatException] for unknown ids or a marker not followed by a
/// fenced block.
String syncMarkdown(String markdown, Map<String, String> snippets) {
  final lines = markdown.split('\n');
  final out = <String>[];
  for (var i = 0; i < lines.length; i++) {
    out.add(lines[i]);
    final match = _marker.firstMatch(lines[i].trim());
    if (match == null) continue;

    final id = match.group(1)!;
    final code = snippets[id];
    if (code == null) throw FormatException('Unknown snippet id "$id".');
    if (i + 1 >= lines.length || !lines[i + 1].startsWith('```')) {
      throw FormatException('Snippet "$id" must be followed by a fenced code block.');
    }
    final fence = lines[i + 1];
    var end = i + 2;
    while (end < lines.length && lines[end].trim() != '```') {
      end++;
    }
    if (end >= lines.length) throw FormatException('Unclosed code block after "$id".');
    out
      ..add(fence)
      ..addAll(code.split('\n'))
      ..add('```');
    i = end;
  }
  return out.join('\n');
}

class SnippetsCommand extends Command<int> {
  SnippetsCommand() {
    argParser.addFlag(
      'check',
      negatable: false,
      help: 'Fail if any reference is out of date instead of rewriting it.',
    );
  }

  @override
  String get name => 'snippets';

  @override
  String get description => 'Sync code blocks in $skillDir/**.md from examples/lib.';

  @override
  Future<int> run() async {
    final root = findWorkspaceRoot();
    final snippets = collectSnippets(root);
    final check = argResults!.flag('check');
    final stale = <String>[];

    for (final doc in skillMarkdownFiles(root)) {
      final current = doc.readAsStringSync();
      final synced = syncMarkdown(current, snippets);
      if (synced == current) continue;
      stale.add(p.relative(doc.path, from: root));
      if (!check) doc.writeAsStringSync(synced);
    }

    if (check && stale.isNotEmpty) {
      stderr.writeln('snippets: stale — run `dart run dartadvance_tool:dartadvance snippets`:');
      stale.forEach(stderr.writeln);
      return 1;
    }
    stdout.writeln(
      check ? 'snippets: up to date' : 'snippets: updated ${stale.length} file(s)',
    );
    return 0;
  }
}

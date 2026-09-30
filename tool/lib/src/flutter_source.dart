import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'workspace.dart';

/// Pinned flutter/flutter stable tag. Every permalink points at this tag.
const flutterTag = '3.47.5';

/// Only this subtree is checked out (sparse clone).
const flutterSubtree = 'packages/flutter/lib';

/// Clone location, relative to the workspace root (git-ignored).
const flutterCache = '.cache/flutter';

/// GitHub permalink for [path] (repo-relative) at [flutterTag].
String flutterPermalink(String path, int line) =>
    'https://github.com/flutter/flutter/blob/$flutterTag/$path#L$line';

class FlutterSourceCommand extends Command<int> {
  FlutterSourceCommand() {
    addSubcommand(_SyncCommand());
    addSubcommand(_GrepCommand());
  }

  @override
  String get name => 'flutter-src';

  @override
  String get description => 'Look up real usages in flutter/flutter $flutterSubtree @ $flutterTag.';
}

class _SyncCommand extends Command<int> {
  @override
  String get name => 'sync';

  @override
  String get description => 'Shallow + sparse clone of flutter/flutter at the pinned tag.';

  @override
  Future<int> run() async {
    final root = findWorkspaceRoot();
    final dir = p.join(root, flutterCache);
    if (Directory(p.join(dir, '.git')).existsSync()) {
      final head = await Process.run('git', ['-C', dir, 'describe', '--tags', '--exact-match']);
      if ('${head.stdout}'.trim() == flutterTag) {
        stdout.writeln('flutter-src: $flutterCache already at $flutterTag');
        return 0;
      }
      stdout.writeln('flutter-src: tag changed, re-cloning');
      Directory(dir).deleteSync(recursive: true);
    }
    final clone = await runStreaming('git', [
      'clone',
      '--depth=1',
      '--branch=$flutterTag',
      '--filter=blob:none',
      '--sparse',
      'https://github.com/flutter/flutter.git',
      dir,
    ]);
    if (clone != 0) return clone;
    return runStreaming('git', ['-C', dir, 'sparse-checkout', 'set', flutterSubtree]);
  }
}

class _GrepCommand extends Command<int> {
  _GrepCommand() {
    argParser
      ..addFlag('json', negatable: false, help: 'Emit JSON (one object per hit).')
      ..addFlag('count', negatable: false, help: 'Print only the number of hits.');
  }

  @override
  String get name => 'grep';

  @override
  String get description => 'Extended-regex search in $flutterSubtree with permalinks.';

  @override
  String get invocation => 'dartadvance flutter-src grep [--json|--count] <regex>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 1) usageException('Expected exactly one <regex>.');
    final dir = p.join(findWorkspaceRoot(), flutterCache);
    if (!Directory(p.join(dir, '.git')).existsSync()) {
      stderr.writeln(
        'flutter-src: no clone yet — run `dart run dartadvance_tool:dartadvance flutter-src sync`.',
      );
      return 1;
    }
    final result = await Process.run('git', [
      '-C',
      dir,
      'grep',
      '-n',
      '-E',
      rest.single,
      '--',
      flutterSubtree,
    ]);
    // git grep exits 1 when nothing matched.
    if (result.exitCode > 1) {
      stderr.write(result.stderr);
      return result.exitCode;
    }
    final hits = [
      for (final line in const LineSplitter().convert('${result.stdout}')) ?_parse(line),
    ];
    if (argResults!.flag('count')) {
      stdout.writeln(hits.length);
    } else if (argResults!.flag('json')) {
      for (final hit in hits) {
        stdout.writeln(jsonEncode(hit));
      }
    } else {
      for (final hit in hits) {
        stdout.writeln('${hit['path']}:${hit['line']}  ${hit['code']}\n    ${hit['url']}');
      }
    }
    return 0;
  }

  Map<String, Object>? _parse(String raw) {
    final match = RegExp(r'^([^:]+):(\d+):(.*)$').firstMatch(raw);
    if (match == null) return null;
    final path = match.group(1)!;
    final line = int.parse(match.group(2)!);
    return {
      'path': path,
      'line': line,
      'code': match.group(3)!.trim(),
      'url': flutterPermalink(path, line),
    };
  }
}

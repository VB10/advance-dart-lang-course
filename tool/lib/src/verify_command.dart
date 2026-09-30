import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'workspace.dart';

/// `dartadvance verify <topic>` — the gate a reference must pass before it is "done":
/// format, analyze (zero issues, infos included), test, references in sync.
///
/// `dartadvance verify --all` runs the same gate once over every topic.
class VerifyCommand extends Command<int> {
  VerifyCommand() {
    argParser.addFlag('all', negatable: false, help: 'Verify every topic under examples/.');
  }

  @override
  String get name => 'verify';

  @override
  String get description =>
      'Format-check, analyze and test the examples of one topic (e.g. 01_typedefs), or --all.';

  @override
  String get invocation => 'dartadvance verify <topic> | --all';

  @override
  Future<int> run() async {
    final all = argResults!.flag('all');
    final rest = argResults!.rest;
    if (all ? rest.isNotEmpty : rest.length != 1) {
      usageException('Expected exactly one <topic>, or --all.');
    }
    final topic = all ? 'all' : rest.single; // e.g. 01_typedefs

    final root = findWorkspaceRoot();
    final examples = p.join(root, 'examples');
    final targets = all ? ['lib', 'test'] : [p.join('lib', topic), p.join('test', topic)];
    for (final target in targets) {
      if (!Directory(p.join(examples, target)).existsSync()) {
        stderr.writeln('verify: missing examples/$target');
        return 1;
      }
    }

    final steps = <(String, Future<int> Function())>[
      (
        'format',
        () => runStreaming('dart', [
          'format',
          '--output=none',
          '--set-exit-if-changed',
          ...targets,
        ], workingDirectory: examples),
      ),
      (
        'analyze',
        () => runStreaming('dart', [
          'analyze',
          '--fatal-infos',
          ...targets,
        ], workingDirectory: examples),
      ),
      ('test', () => runStreaming('dart', ['test', targets[1]], workingDirectory: examples)),
      (
        'snippets',
        () => runStreaming('dart', [
          'run',
          'dartadvance_tool:dartadvance',
          'snippets',
          '--check',
        ], workingDirectory: root),
      ),
    ];

    for (final (label, step) in steps) {
      final code = await step();
      if (code != 0) {
        stderr.writeln('verify($topic): FAILED at $label');
        return code;
      }
    }
    stdout.writeln('verify($topic): PASSED');
    return 0;
  }
}

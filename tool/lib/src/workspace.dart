import 'dart:io';

import 'package:path/path.dart' as p;

/// Absolute path of the Dart Atlas workspace root (the directory whose
/// `pubspec.yaml` declares `workspace:`), searched upward from [from].
String findWorkspaceRoot([String? from]) {
  var dir = Directory(from ?? Directory.current.path).absolute;
  while (true) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsLinesSync().any((line) => line.startsWith('workspace:'))) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Not inside the Dart Atlas workspace.');
    }
    dir = parent;
  }
}

/// Runs [executable] with [args], streaming output. Returns the exit code.
Future<int> runStreaming(
  String executable,
  List<String> args, {
  String? workingDirectory,
}) async {
  stdout.writeln('\$ $executable ${args.join(' ')}');
  final process = await Process.start(
    executable,
    args,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

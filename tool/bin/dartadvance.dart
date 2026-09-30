import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dartadvance_tool/dartadvance_tool.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>('dartadvance', 'dartadvance project automation.')
    ..addCommand(SnippetsCommand())
    ..addCommand(VerifyCommand())
    ..addCommand(LinksCommand())
    ..addCommand(FlutterSourceCommand());
  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  }
}

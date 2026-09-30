import 'dart:async';

Future<void> _loadConfig(List<String> log) async {
  log.add('loadConfig: before await');
  await null;
  log.add('loadConfig: after await');
}

Future<List<String>> bootOrder() {
  final log = <String>[];
  final done = Completer<List<String>>();

  Timer.run(() => log.add('Timer.run'));
  scheduleMicrotask(() => log.add('scheduleMicrotask'));
  unawaited(_loadConfig(log));
  log.add('boot: end of function');

  Timer.run(() => done.complete(log));
  return done.future;
}

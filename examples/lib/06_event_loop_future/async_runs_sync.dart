import 'dart:async';

Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null; // `await_only_futures` allows this microtask delay.
  log.add('greet: after await');
}

List<String> callWithoutAwait() {
  final log = <String>[];
  unawaited(greet(log));
  log.add('caller: next statement');
  return log;
}

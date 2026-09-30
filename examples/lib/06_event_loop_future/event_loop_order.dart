import 'dart:async';

/// Records the order in which each kind of callback runs.
Future<List<String>> orderOfExecution() {
  final log = <String>[];
  final finished = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()')));
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask'));
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function');

  Timer.run(() => finished.complete(log));
  return finished.future;
}

/// An async function runs synchronously until its first await.
Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null; // the rest continues in a microtask
  log.add('greet: after await');
}

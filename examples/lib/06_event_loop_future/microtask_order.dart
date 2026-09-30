import 'dart:async';

/// Returns the order in which each kind of callback ran.
Future<List<String>> eventLoopOrder() {
  final log = <String>[];
  final done = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()')));
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask'));
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function');

  Timer.run(() => done.complete(log));
  return done.future;
}

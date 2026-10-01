// Skill'e ver: "Projemde `scheduleMicrotask`, `Timer.run` veya `Future(...)` ile sıra
// varsayan yerleri bul, event loop sırasına göre düzelt, her biri için test yaz."
import 'dart:async';

/// Sync code first, then every microtask, then event-queue callbacks.
Future<List<String>> orderOfExecution() {
  final log = <String>[];
  final finished = Completer<List<String>>();

  Timer.run(() => log.add('event: Timer.run'));
  unawaited(Future<void>(() => log.add('event: Future()'))); // log[4]: last
  scheduleMicrotask(() => log.add('microtask: scheduleMicrotask')); // log[1]
  unawaited(Future<void>.microtask(() => log.add('microtask: Future.microtask')));
  log.add('sync: end of function'); // log[0]: first, though written last

  Timer.run(() => finished.complete(log));
  return finished.future;
}

/// An async function runs synchronously until its first await.
Future<void> greet(List<String> log) async {
  log.add('greet: before await');
  await null;
  log.add('greet: after await');
}

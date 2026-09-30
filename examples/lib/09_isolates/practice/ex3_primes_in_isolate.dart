import 'dart:async';
import 'dart:isolate';

import '../exit_port.dart';
import 'ex3_prime_worker.dart';

/// Nothing is spawned before `onListen`; cancelling kills the worker.
({Stream<int> primes, Future<void> exited}) primesInIsolate({int? limit}) {
  final source = _PrimeSource(limit);
  return (primes: source.controller.stream, exited: source.exited.future);
}

final class _PrimeSource {
  _PrimeSource(this._limit) {
    controller = StreamController<int>(onListen: () => unawaited(_start()), onCancel: _cancel);
  }
  final int? _limit;
  final exited = Completer<void>();
  late final StreamController<int> controller;
  ReceivePort? _messages;
  Isolate? _isolate;
  var _cancelled = false;

  Future<void> _start() async {
    final messages = _messages = ReceivePort()..listen(_onMessage);
    final onExit = exitPort(exited);
    try {
      _isolate = await _spawn(messages.sendPort, onExit.sendPort);
    } on Object catch (error, stackTrace) {
      messages.close();
      onExit.close();
      controller.addError(error, stackTrace);
      unawaited(controller.close());
      return;
    }
    // Cancelled while spawning: stop the worker right away.
    if (_cancelled) _kill();
  }

  Future<Isolate> _spawn(SendPort results, SendPort onExit) =>
      Isolate.spawn(primeWorker, (_limit, results), onExit: onExit, debugName: 'primes');

  void _onMessage(Object? message) {
    if (message case final int prime) {
      controller.add(prime);
      return;
    }
    _messages?.close();
    unawaited(controller.close());
  }

  void _cancel() {
    _cancelled = true;
    _kill();
    _messages?.close();
  }

  void _kill() => _isolate?.kill(priority: Isolate.immediate);
}

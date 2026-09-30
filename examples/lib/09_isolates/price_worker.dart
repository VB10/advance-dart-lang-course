import 'dart:isolate';

final class PriceWorker {
  PriceWorker._(this._commands, this.exited);
  final SendPort _commands;
  final Future<void> exited;
  static Future<PriceWorker> spawn() async {
    final ready = ReceivePort();
    final exitPort = ReceivePort();
    await Isolate.spawn(_serve, ready.sendPort, onExit: exitPort.sendPort);
    return PriceWorker._(await ready.first as SendPort, exitPort.first);
  }

  Future<int> withTax(int cents) async {
    final reply = ReceivePort();
    _commands.send((cents, reply.sendPort));
    // A dead worker never replies, so the exit signal must win the race.
    final died = exited.then((_) => StateError('Worker exited'));
    final result = await Future.any<Object?>([reply.first, died]);
    reply.close();
    return result is Error ? throw result : result! as int;
  }

  void close() => _commands.send(null);
}

void _serve(SendPort ready) {
  final commands = ReceivePort();
  ready.send(commands.sendPort);
  commands.listen((Object? message) {
    if (message == null) return commands.close(); // last port closed: isolate exits
    final (int cents, SendPort replyTo) = message as (int, SendPort);
    replyTo.send(cents < 0 ? RemoteError('Negative price', '') : cents * 120 ~/ 100);
  });
}

import 'dart:async';
import 'dart:isolate';

import 'exit_port.dart';
import 'robust_worker_remote.dart';

final class JsonWorker {
  // #docregion spawn
  static Future<JsonWorker> spawn() async {
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (Object? initialMessage) {
      final commandPort = initialMessage! as SendPort;
      connection.complete((ReceivePort.fromRawReceivePort(initPort), commandPort));
    };
    final exited = Completer<void>();
    final onExit = exitPort(exited);

    try {
      await Isolate.spawn(startJsonWorkerIsolate, initPort.sendPort, onExit: onExit.sendPort);
    } on Object {
      initPort.close();
      onExit.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) = await connection.future;
    return JsonWorker._(receivePort, sendPort, exited.future);
  }
  // #enddocregion spawn

  JsonWorker._(this._responses, this._commands, this.exited) {
    _responses.listen(_handleResponsesFromIsolate);
  }
  final SendPort _commands;
  final ReceivePort _responses;
  final Future<void> exited;

  // #docregion request
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Future<Object?> parseJson(String message) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<Object?>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, message));
    return await completer.future;
  }

  void _handleResponsesFromIsolate(Object? message) {
    final (int id, Object? response) = message! as (int, Object?);
    final completer = _activeRequests.remove(id)!;
    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }
    if (_closed && _activeRequests.isEmpty) _responses.close();
  }
  // #enddocregion request

  // #docregion close
  void close() {
    if (_closed) return;
    _closed = true;
    _commands.send('shutdown');
    if (_activeRequests.isEmpty) _responses.close();
  }

  // #enddocregion close
}

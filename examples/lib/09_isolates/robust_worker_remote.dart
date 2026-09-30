import 'dart:convert';
import 'dart:isolate';

void startJsonWorkerIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((Object? message) => _handleCommand(message, receivePort, sendPort));
}

void _handleCommand(Object? message, ReceivePort receivePort, SendPort sendPort) {
  if (message == 'shutdown') {
    receivePort.close(); // the last open port closes, so the isolate exits
    return;
  }
  final (int id, String jsonText) = message! as (int, String);
  sendPort.send((id, _decode(jsonText)));
}

Object? _decode(String jsonText) {
  try {
    return jsonDecode(jsonText);
  } catch (error) {
    return RemoteError(error.toString(), '');
  }
}

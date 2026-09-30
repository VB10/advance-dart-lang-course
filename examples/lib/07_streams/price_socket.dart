import 'dart:async';

/// Connected only while someone listens: `onListen` opens, `onCancel` closes.
final class InMemoryPriceSocket {
  late final StreamController<String> _frames = StreamController<String>.broadcast(
    onListen: () => _connected = true,
    onCancel: () => _connected = false,
  );
  var _connected = false;

  bool get isConnected => _connected;

  Stream<String> get frames => _frames.stream;

  void push(String frame) => _frames.add(frame);

  Future<void> close() => _frames.close();
}

import 'dart:async';

/// Events reported while nobody listens are dropped.
final class ConnectivityEvents {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get changes => _controller.stream;

  void report({required bool online}) => _controller.add(online);

  Future<void> close() => _controller.close();
}

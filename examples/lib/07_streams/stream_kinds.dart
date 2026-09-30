import 'dart:async';

final class OrderStatusFeed {
  final _controller = StreamController<String>.broadcast();

  // Broadcast: many listeners, events nobody hears are dropped.
  Stream<String> get statusChanges => _controller.stream;

  void publish(String status) => _controller.add(status);

  Future<void> close() => _controller.close();
}

// Single-subscription (the default): one listener for the stream's whole life.
Stream<String> orderHistory(List<String> statuses) async* {
  for (final status in statuses) {
    yield status;
  }
}

// A single-subscription stream becomes shareable with asBroadcastStream.
Stream<String> shareable(Stream<String> source) => source.asBroadcastStream();

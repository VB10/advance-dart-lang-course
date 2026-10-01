// Skill'e ver: "Projemde aynı stream'i birden çok yerde dinleyen yerleri bul,
// single-subscription/broadcast ayrımıyla düzelt, her biri için test yaz."
import 'dart:async';

Stream<String> orderHistory(List<String> statuses) async* {
  for (final status in statuses) {
    yield status;
  }
} // single-subscription: a 2nd listen throws StateError

Stream<String> shareable(Stream<String> source) => source.asBroadcastStream(); // 2 listeners: ok

final class OrderStatusFeed {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get statusChanges => _controller.stream;

  void publish(String status) => _controller.add(status); // no listener: event dropped

  Future<void> close() => _controller.close();
}

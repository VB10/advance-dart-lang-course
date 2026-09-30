import 'dart:async';

/// Produces one value per event-loop turn, so a pause stops the next value
/// from being produced at all instead of piling it up in the buffer.
Stream<int> pausableCounter(int maxCount, {void Function(String event)? log}) {
  late final StreamController<int> controller;
  var next = 1;
  var running = false;

  void produce() {
    if (!running) return;
    if (next > maxCount) {
      running = false;
      controller.close();
      return;
    }
    log?.call('produce $next');
    controller.add(next++);
    Timer.run(produce);
  }

  void start(String event) {
    log?.call(event);
    running = true;
    Timer.run(produce);
  }

  void stop(String event) {
    log?.call(event);
    running = false;
  }

  controller = StreamController<int>(
    onListen: () => start('onListen'),
    onPause: () => stop('onPause'),
    onResume: () => start('onResume'),
    onCancel: () => stop('onCancel'),
  );
  return controller.stream;
}

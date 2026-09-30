import 'dart:async';

/// Tracking starts on listen, stops on pause/cancel, resumes on resume.
Stream<int> courierPositions({required void Function(String event) log}) {
  late final StreamController<int> controller;
  Timer? timer;
  var position = 0;

  void start(String event) {
    log(event);
    timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => controller.add(++position),
    );
  }

  void stop(String event) {
    log(event);
    timer?.cancel();
  }

  controller = StreamController<int>(
    onListen: () => start('onListen'),
    onPause: () => stop('onPause'),
    onResume: () => start('onResume'),
    onCancel: () => stop('onCancel'),
  );
  return controller.stream;
}

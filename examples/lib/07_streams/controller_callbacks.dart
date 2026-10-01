// /dartadvance Projemde Timer, soket veya sensörü stream dinlenmeden başlatan yerleri
// bul, `StreamController` onListen/onCancel ile düzelt, her biri için test yaz.
import 'dart:async';

Stream<int> courierPositions({required void Function(String event) log}) {
  late final StreamController<int> controller;
  Timer? timer;
  var position = 0;

  void start(String event) {
    log(event); // nobody listening: log stays empty, no timer
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) => controller.add(++position));
  }

  void stop(String event) {
    log(event); // pause and cancel both stop the source
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

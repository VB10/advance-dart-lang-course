// Düzelt: /dartadvance Projemde Timer, soket veya sensörü dinlenmeden başlatan yerleri
//    bul, `StreamController` onListen/onCancel ile düzelt, test yaz.
// Üret: /dartadvance Bana sıcaklık sensörünü yalnız biri dinlerken okuyan, dinleyen
//    kalmayınca durduran bir akış yaz.
import 'dart:async';

Stream<int> courierPositionsWrong({required void Function(String event) log}) {
  final controller = StreamController<int>();
  Timer.periodic(const Duration(milliseconds: 10), (_) {
    log('read'); // no listener yet: the sensor is read anyway
    controller.add(1);
  }); // never cancelled: keeps reading after the last listener leaves
  return controller.stream;
}

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

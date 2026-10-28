/// Harita kontrolcüsü; harita çizilene kadar yoktur (`onMapCreated` ile gelir).
final class MapCamera {
  String? target;
  String? pin;

  void moveTo(String place) => target = place;

  void showPin(String place) => pin = place;
}

/// Haritadaki "Konumum" butonu.
final class LocateButton {
  LocateButton([this.camera]);

  MapCamera? camera;

  // Olumsuz: `!` harita hazır değilken TypeError atar → erken dokunuşta ekran çöker.
  void onTapWrong(String place) => camera!
    ..moveTo(place)
    ..showPin(place);

  // Olumlu: `?..` camera null ise tüm zinciri atlar; hazır olunca aynı satır çalışır.
  void onTap(String place) => camera
    ?..moveTo(place)
    ..showPin(place);
}

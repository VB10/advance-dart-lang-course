// Düzelt: /dartadvance Projemde geç gelen nullable kontrolcüleri (harita, kamera, video,
//    animasyon) ! ile ya da if (x != null) { x.a(); x.b(); } bloklarıyla kullanan yerleri bul.
//    ?.. cascade ile düzelt, null durumda çağrının çökmediğini test et.
// Üret: /dartadvance Bana harita ekranı için "Konumum" butonu yaz: kontrolcü onMapCreated ile
//    gelsin, hazır değilken dokunuş çökmesin, hazır olunca kamerayı taşıyıp pin koysun.

/// Map controller; it arrives with onMapCreated, null until the map is drawn.
final class MapCamera {
  String? target;
  String? pin;

  void moveTo(String place) => target = place;

  void showPin(String place) => pin = place;
}

/// The "my location" button on the map.
final class LocateButton {
  LocateButton([this.camera]);

  MapCamera? camera;

  // ✗ `!` throws TypeError when the map is not ready: an early tap crashes the screen.
  void onTapWrong(String place) => camera!
    ..moveTo(place)
    ..showPin(place);

  void onTap(String place) => camera
    ?..moveTo(place)
    ..showPin(place); // skipped while camera is null
}

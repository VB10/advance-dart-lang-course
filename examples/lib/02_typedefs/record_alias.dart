// Düzelt: /dartadvance Projemde konum, boyut ya da aralık için `(double, double)` gibi
//    konumsal record kullanan yerleri bul, isimli alanlı `typedef` ile düzelt, test yaz.
// Üret: /dartadvance Bana mağaza seçme ekranı için konumu ve seçim callback'ini typedef ile
//    adlandıran bir harita sınıfı yaz.
typedef Point = ({double lat, double lng});
typedef OnPicked = void Function(Point point);

(double, double) storeWrong() => (29.0, 41.0); // lng first by mistake: still compiles
double latWrong() => storeWrong().$1; // 29.0: not a latitude

Point store() => (lng: 29.0, lat: 41.0); // Names, not order, decide the meaning.
String pinLabel(Point point) => '${point.lat}, ${point.lng}'; // 41.0, 29.0

class MapScreen {
  MapScreen({required this.onPicked});
  final OnPicked onPicked; // One name for the callback shape.

  void tapStore() => onPicked(store());
}

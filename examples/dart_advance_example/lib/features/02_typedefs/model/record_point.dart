typedef Point = ({double lat, double lng});
typedef OnPicked = void Function(Point point);

/// Mağaza seçme ekranında seçilen mağazanın konumunu veren sınıf.
final class StoreMap {
  // Olumsuz: konumsal record'da boylam yanlışlıkla başa yazıldı; derlenir, `.$1` enlem diye 29.0 okur.
  (double, double) storeWrong() => (29.0, 41.0);

  // Olumlu: isimli alanlar; sıra değil isim anlamı belirler → enlem 41.0.
  Point store() => (lng: 29.0, lat: 41.0);
}

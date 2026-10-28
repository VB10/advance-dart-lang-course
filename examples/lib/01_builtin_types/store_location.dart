// Düzelt: /dartadvance Projemde JSON'dan okunan sayıları as double ile cast eden yerleri bul
//    (konum, fiyat, puan, oran). (x as num).toDouble() ile düzelt, tam sayı gelen JSON ile
//    test yaz.
// Üret: /dartadvance Bana API'den gelen mağaza listesini (ad, enlem, boylam, puan) okuyan bir
//    fromJson yaz; sayılar int de gelebilir.

/// Store map pin read from the API.
final class StoreLocation {
  const StoreLocation(this.latitude, this.longitude);

  // ✗ jsonDecode gives 41 as int; `41 as double` throws TypeError at runtime.
  factory StoreLocation.fromJsonWrong(Map<String, Object?> json) =>
      StoreLocation(json['latitude'] as double, json['longitude'] as double);

  /// int and double are both num.
  factory StoreLocation.fromJson(Map<String, Object?> json) => StoreLocation(
    (json['latitude'] as num).toDouble(), // 41: 41.0
    (json['longitude'] as num).toDouble(),
  );

  final double latitude;
  final double longitude;
}

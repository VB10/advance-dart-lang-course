/// Mağaza haritasında pin olarak gösterilen konum; API'den JSON gelir.
final class StoreLocation {
  const StoreLocation(this.latitude, this.longitude);

  // Olumsuz: JSON tam sayıyı int çözer; `41 as double` TypeError fırlatır → pin hiç çizilmez.
  factory StoreLocation.fromJsonWrong(Map<String, dynamic> json) =>
      StoreLocation(json['latitude'] as double, json['longitude'] as double);

  // Olumlu: int ve double ikisi de num; `as num` sonra toDouble() → 41.0.
  factory StoreLocation.fromJson(Map<String, dynamic> json) => StoreLocation(
    (json['latitude'] as num).toDouble(),
    (json['longitude'] as num).toDouble(),
  );

  final double latitude;
  final double longitude;
}

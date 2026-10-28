/// Haritada pine dokununca adres sunucudan bir kez alınır, sonra önbellekten gelir.
final class PinAddressCache {
  int requestsWrong = 0;
  int requests = 0;

  final _byList = <List<double>, String>{};
  final _byRecord = <(double, double), String>{};

  // Olumsuz: List eşitliği referansa bakar; her dokunuşta yeni [lat, lng] → önbellek hiç tutmaz.
  String addressWrong(double lat, double lng) =>
      _byList.putIfAbsent([lat, lng], () => _fetch(() => requestsWrong++));

  // Olumlu: record içerik eşitliği kullanır; aynı (lat, lng) aynı anahtar.
  String address(double lat, double lng) =>
      _byRecord.putIfAbsent((lat, lng), () => _fetch(() => requests++));

  String _fetch(void Function() count) {
    count();
    return 'Caferağa Mah., Kadıköy';
  }
}

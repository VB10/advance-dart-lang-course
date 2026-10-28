// Düzelt: /dartadvance Projemde Map anahtarı ya da Set elemanı olarak List, ya da '$a-$b' gibi
//    birleştirilmiş String kullanan yerleri bul. Record ile düzelt, aynı anahtarla iki çağrıda
//    tek istek gittiğini test et.
// Üret: /dartadvance Bana haritada pin adresini (lat, lng) anahtarlı önbellekte tutan bir sınıf
//    yaz; aynı pine ikinci dokunuşta sunucuya gitmesin.

/// Map pin: the address is fetched once, then served from the cache.
final class PinAddressCache {
  int requestsWrong = 0;
  int requests = 0;

  final _byList = <List<double>, String>{};
  final _byRecord = <(double, double), String>{};

  // ✗ List equality is identity: every tap builds a new [lat, lng], the cache never hits.
  String addressWrong(double lat, double lng) =>
      _byList.putIfAbsent([lat, lng], () => _fetch(() => requestsWrong++));

  String address(double lat, double lng) =>
      _byRecord.putIfAbsent((lat, lng), () => _fetch(() => requests++));

  String _fetch(void Function() count) {
    count();
    return 'Caferağa Mah., Kadıköy';
  }
}

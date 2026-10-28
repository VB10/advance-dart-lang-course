// Düzelt: /dartadvance Projemde API'den gelen tarihi DateTime.parse ile okuyup toLocal olmadan
//    ekrana yazan yerleri bul. toLocal ekle, Z'li girdiyle isUtc kontrolü yapan test yaz.
// Üret: /dartadvance Bana etkinlik başlangıcını API'nin UTC metninden okuyup cihaz saatinde
//    HH:mm yazan bir sınıf yaz.

/// Event detail: start time; the API sends UTC ('...Z').
final class EventTime {
  // ✗ A 'Z' time stays UTC; hour is the UTC hour, 3 hours early in Türkiye.
  DateTime startWrong(String iso) => DateTime.parse(iso);

  DateTime start(String iso) => DateTime.parse(iso).toLocal();

  String label(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

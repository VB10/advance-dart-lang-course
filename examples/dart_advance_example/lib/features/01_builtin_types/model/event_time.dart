/// Etkinlik detayında başlangıç saati; API saati UTC gönderir ('...Z').
final class EventTime {
  // Olumsuz: parse 'Z'li metni UTC tutar; saat kullanıcının saatine çevrilmez → Türkiye'de 3 saat erken.
  DateTime startWrong(String iso) => DateTime.parse(iso);

  // Olumlu: toLocal cihazın saat dilimine çevirir.
  DateTime start(String iso) => DateTime.parse(iso).toLocal();

  String label(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

/// Etkinlik ekranındaki filtre sheet'i; seçenek başlıkları uygulamanın o anki dilinde.
final class EventFilterSheet {
  EventFilterSheet(this.language);

  static const _titles = {
    'tr': ['Bekleyen', 'Onaylanan', 'Reddedilen'],
    'en': ['Pending', 'Approved', 'Declined'],
  };

  /// Kullanıcı ayarlardan dili değiştirince güncellenir.
  String language;

  // Olumsuz: late final ilk okumada bir kez kurulur; dil 'en' olunca başlıklar Türkçe kalır.
  late final List<String> titlesWrong = _titles[language]!;

  // Olumlu: kaynak (dil) değişebiliyorsa getter her okumada o anki dilden kurar.
  List<String> get titles => _titles[language]!;
}

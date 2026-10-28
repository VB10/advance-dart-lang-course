// Düzelt: /dartadvance Projemde late final alanları bul. Kaynağı sonradan değişebilenleri (dil,
//    tema, kullanıcı, filtre) getter'a ya da değiştiği yerde yeniden kurmaya çevir, kaynağı
//    değiştiren bir testle kanıtla.
// Üret: /dartadvance Bana uygulama dili değişince seçenek başlıkları da değişen bir filtre
//    sheet'i state'i yaz.

/// Event filter sheet; chip titles follow the app language.
final class EventFilterSheet {
  EventFilterSheet(this.language);

  static const _titles = {
    'tr': ['Bekleyen', 'Onaylanan', 'Reddedilen'],
    'en': ['Pending', 'Approved', 'Declined'],
  };

  String language;

  // ✗ Built on first read and never again: after 'tr' → 'en' the chips stay Turkish.
  late final List<String> titlesWrong = _titles[language]!;

  List<String> get titles => _titles[language]!; // follows language
}

// Düzelt: /dartadvance Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları
//    bul, `mixin class` ile birleştir, test yaz.
// Üret: /dartadvance Bana hem bir sınıfa karıştırılabilen hem miras alınabilen, çalma
//    listesi değişikliklerini kaydeden sınıf yaz.

// `mixin class` works both as `with Auditable` and as `extends Auditable`.
mixin class Auditable {
  final List<String> _entries = [];

  List<String> get auditLog => List.unmodifiable(_entries); // add() throws

  void audit(String entry) => _entries.add(entry);
}

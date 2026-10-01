// /dartadvance Projemde hem `with` hem `extends` ile kullanılan ortak sınıfları bul,
// `mixin class` ile birleştir, her biri için test yaz.

// `mixin class` works both as `with Auditable` and as `extends Auditable`.
mixin class Auditable {
  final List<String> _entries = [];

  List<String> get auditLog => List.unmodifiable(_entries); // add() throws

  void audit(String entry) => _entries.add(entry);
}

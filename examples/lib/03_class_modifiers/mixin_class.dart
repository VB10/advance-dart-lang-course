// `mixin class` works both as `with Auditable` and as `extends Auditable`.
mixin class Auditable {
  final List<String> _entries = [];

  List<String> get auditLog => List.unmodifiable(_entries);

  void audit(String entry) => _entries.add(entry);
}

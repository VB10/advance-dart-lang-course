final class ProfileCache {
  String? _name;

  bool get isLoaded => _name != null;
  String get name => _name ?? 'Guest';
  void load(String name) => _name = name;
}

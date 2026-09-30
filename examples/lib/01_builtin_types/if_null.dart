String playerName(String? name) => name ?? 'Guest';

final class ThemeCache {
  String? _mode;
  int loads = 0;

  String get mode => _mode ??= _load();

  String _load() {
    loads++;
    return 'dark';
  }
}

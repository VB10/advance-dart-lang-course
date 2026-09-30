final class Debouncer {
  Debouncer(this._onFire);
  final void Function(String query) _onFire; // Used once: no typedef needed.

  void fire(String query) => _onFire(query);
}

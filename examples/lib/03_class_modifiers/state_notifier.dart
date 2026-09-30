abstract base class StateNotifier<S> {
  StateNotifier(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void addListener(void Function(S state) listener) => _listeners.add(listener);

  void removeListener(void Function(S state) listener) => _listeners.remove(listener);

  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }
}

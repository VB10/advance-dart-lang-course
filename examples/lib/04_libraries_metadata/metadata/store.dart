import 'package:meta/meta.dart';

abstract base class Store<S> {
  Store(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void listen(void Function(S state) listener) => _listeners.add(listener);

  @protected
  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }

  @mustCallSuper
  void dispose() => _listeners.clear();

  @visibleForTesting
  int get listenerCount => _listeners.length;
}

// /dartadvance Projemde taban store sınıflarında alt sınıfa ait metotları ve dispose
// zincirini bul, `@protected` ve `@mustCallSuper` ekle, her biri için test yaz.
import 'package:meta/meta.dart';

abstract base class CartStore<S> {
  CartStore(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void listen(void Function(S state) listener) => _listeners.add(listener);

  // Only subclasses should change state; outside callers get a warning.
  @protected
  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }

  // Overrides that forget super.dispose() are reported.
  @mustCallSuper
  void dispose() => _listeners.clear();
}

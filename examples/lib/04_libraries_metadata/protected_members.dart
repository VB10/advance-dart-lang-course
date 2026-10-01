// Düzelt: /dartadvance Projemde taban store sınıflarında alt sınıfa ait metotları ve
//    dispose zincirini bul, `@protected` ve `@mustCallSuper` ekle, her biri için test yaz.
// Üret: /dartadvance Bana durumu yalnızca alt sınıfların değiştirdiği, dinleyicileri
//    temizleyen PlaylistStore tabanı yaz.
import 'package:meta/meta.dart';

abstract base class CartStore<S> {
  CartStore(this._state);

  S _state;
  final List<void Function(S state)> _listeners = [];

  S get state => _state;

  void listen(void Function(S state) listener) => _listeners.add(listener);

  // ✗ store.emit(1);  // analyzer: invalid_use_of_protected_member, called from outside
  @protected
  void emit(S next) {
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }

  // ✗ @override void dispose() {}  // analyzer: must_call_super, listeners would leak
  @mustCallSuper
  void dispose() => _listeners.clear();
}

// Düzelt: /dartadvance Projemde store/controller taban sınıflarında durumu doğrudan değiştiren
//    (emit, setState, value =) public metotları ve bunları ekrandan çağıran yerleri bul.
//    @protected ekle, ekranın yalnız iş metodunu çağırdığını test et (pay_button.dart).
// Üret: /dartadvance Bana ödeme durumu tutan bir store yaz: durumu yalnız pay metodu
//    değiştirsin, kart reddedilirse "reddedildi" olsun.
import 'package:meta/meta.dart';

enum PaymentStatus { waiting, paid, declined }

/// Base store: subclasses change the state, screens only read it.
abstract base class Store<S> {
  Store(this._state);

  S _state;

  S get state => _state;

  @protected
  void emit(S next) => _state = next;
}

final class PaymentStore extends Store<PaymentStatus> {
  PaymentStore() : super(PaymentStatus.waiting);

  /// Validates the card, then emits.
  void pay({required bool cardAccepted}) =>
      emit(cardAccepted ? PaymentStatus.paid : PaymentStatus.declined);
}

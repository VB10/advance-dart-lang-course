// Düzelt: /dartadvance Projemde ekran, widget ya da başka bir library'den store'un emit /
//    setState / value = metodunu doğrudan çağıran yerleri bul. Taban metoda @protected ekle,
//    ekranın iş metodunu (pay, submit) çağırdığını test et.
// Üret: /dartadvance Bana ödeme ekranı için yalnız store.pay çağıran bir buton sınıfı yaz.
import 'package:dart_advance_example/features/03_class_design/model/order_store.dart';

/// The pay button on the checkout screen; lives outside the store's library.
final class PayButton {
  // ✗ The screen skips pay() and emits directly: a declined card shows "Ödendi".
  void onTapWrong(PaymentStore store) {
    // ignore: invalid_use_of_protected_member
    store.emit(PaymentStatus.paid);
  }

  void onTap(PaymentStore store, {required bool cardAccepted}) =>
      store.pay(cardAccepted: cardAccepted);
}

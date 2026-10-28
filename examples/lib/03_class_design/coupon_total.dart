// Düzelt: /dartadvance Projemde yeni değer döndüren (copyWith, withX, add, apply) metotları
//    ve sonucunu atan çağrıları bul. @useResult ekle, atılan sonuçları düzelt, toplamın
//    değiştiğini test et.
// Üret: /dartadvance Bana sepet toplamı için kupon indirimini uygulayıp yeni toplam döndüren
//    bir sınıf yaz; sonucu atılırsa analyzer uyarsın.
import 'package:meta/meta.dart';

/// Checkout total in cents; applying a coupon returns a new total.
@immutable
final class CheckoutTotal {
  const CheckoutTotal(this.cents);

  final int cents;

  @useResult
  CheckoutTotal withDiscount(int discountCents) => CheckoutTotal(cents - discountCents);
}

final class CouponField {
  CouponField(this.total);

  CheckoutTotal total;
  bool applied = false;

  // ✗ The new total is dropped: "Kupon uygulandı", yet the total is unchanged.
  void applyWrong(int discountCents) {
    // ignore: unused_result
    total.withDiscount(discountCents);
    applied = true;
  }

  void apply(int discountCents) {
    total = total.withDiscount(discountCents);
    applied = true;
  }
}

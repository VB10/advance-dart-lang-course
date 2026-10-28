sealed class PaymentResult {
  const PaymentResult();
}

final class PaymentApproved extends PaymentResult {
  const PaymentApproved(this.receipt);
  final String receipt;
}

final class PaymentDeclined extends PaymentResult {
  const PaymentDeclined(this.reason);
  final String reason;
}

final class PaymentPending extends PaymentResult {
  const PaymentPending();
}

/// Ödeme ekranında ödeme sonucunu kullanıcıya gösterilecek metne çeviren sınıf.
final class PaymentMessages {
  // Olumsuz: `_` reddedilen ödemeyi de yutar → 'Bilinmiyor'; yeni alt tipte uyarı gelmez.
  String textWrong(PaymentResult result) => switch (result) {
    PaymentApproved(:final receipt) => 'Ödendi: $receipt',
    _ => 'Bilinmiyor',
  };

  // Olumlu: `sealed` + `_`'siz switch her alt tipi zorlar; eksik olursa analyzer hata verir.
  String text(PaymentResult result) => switch (result) {
    PaymentApproved(:final receipt) => 'Ödendi: $receipt',
    PaymentDeclined(:final reason) => 'Reddedildi: $reason',
    PaymentPending() => 'Beklemede',
  };
}

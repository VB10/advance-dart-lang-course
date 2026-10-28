import 'package:dart_advance_example/features/03_class_design/model/payment_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final messages = PaymentMessages();

  test('_ swallows declined, sealed switch names it', () {
    const declined = PaymentDeclined('Yetersiz bakiye');
    expect(messages.textWrong(declined), 'Bilinmiyor');
    expect(messages.text(declined), 'Reddedildi: Yetersiz bakiye');
  });

  test('each subtype has its own text', () {
    expect(messages.text(const PaymentApproved('R1')), 'Ödendi: R1');
    expect(messages.text(const PaymentPending()), 'Beklemede');
  });
}

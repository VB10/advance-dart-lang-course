import 'package:dartadvance_examples/03_class_design/library_privacy.dart';
import 'package:dartadvance_examples/03_class_design/part_files/order_builder.dart';
import 'package:dartadvance_examples/03_class_design/cart_line.dart';
import 'package:dartadvance_examples/03_class_design/chat_controller.dart';
import 'package:dartadvance_examples/03_class_design/coupon_total.dart';
import 'package:dartadvance_examples/03_class_design/order_store.dart';
import 'package:dartadvance_examples/03_class_design/pay_button.dart';
import 'package:test/test.dart';

void main() {
  group('library_privacy', () {
    test('another class in the same library reads and writes a private field', () {
      final wallet = Wallet(100)..spend(250);
      const auditor = WalletAuditor();

      expect(auditor.isOverdrawn(wallet), isTrue);
      auditor.writeOff(wallet);
      expect(wallet.balanceCents, 0);
      expect(auditor.isOverdrawn(wallet), isFalse);
    });
  });

  group('part_files', () {
    test('a part file shares private members and imports with its library', () {
      final order = OrderBuilder()
        ..add('apple', quantity: 3)
        ..add('pear');

      expect(order.skus, ['apple', 'pear']);
      expect(order.totalQuantity, 4);
    });
  });

  group('cart_line', () {
    test('mutating in place republishes the same object: the screen keeps 1', () {
      final store = CartStore(CartLineWrong('Kupa', 1), (l) => '${l.quantity}');
      QuantityButton().increaseWrong(store);
      expect(store.line.quantity, 2);
      expect(store.shown, '1');
    });

    test('@immutable + copyWith publishes a new line: the screen shows 2', () {
      final store = CartStore(const CartLine('Kupa', 1), (l) => '${l.quantity}');
      QuantityButton().increase(store);
      expect(store.shown, '2');
    });
  });

  group('coupon_total', () {
    test('a dropped @useResult value leaves the total unchanged', () {
      final field = CouponField(const CheckoutTotal(25000))..applyWrong(5000);
      expect(field.applied, isTrue);
      expect(field.total.cents, 25000);
    });

    test('assigning the result applies the discount', () {
      final field = CouponField(const CheckoutTotal(25000))..apply(5000);
      expect(field.total.cents, 20000);
    });
  });

  group('order_store', () {
    test('emitting from the screen skips validation: a declined card is paid', () {
      final store = PaymentStore();
      PayButton().onTapWrong(store);
      expect(store.state, PaymentStatus.paid);
    });

    test('pay validates the card', () {
      final store = PaymentStore();
      PayButton().onTap(store, cardAccepted: false);
      expect(store.state, PaymentStatus.declined);
    });
  });

  group('chat_controller', () {
    test('dispose without super keeps marking messages as read', () {
      final chat = ChatControllerWrong()..dispose();
      for (var i = 0; i < 3; i++) {
        chat.onMessage();
      }
      expect(chat.markedRead, 3);
    });

    test('super.dispose stops listening', () {
      final chat = ChatController()..dispose();
      for (var i = 0; i < 3; i++) {
        chat.onMessage();
      }
      expect(chat.markedRead, 0);
      expect(chat.typingCleared, isTrue);
    });
  });
}

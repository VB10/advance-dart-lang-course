import 'package:dartadvance_examples/04_libraries_metadata/privacy/wallet.dart';
import 'package:test/test.dart';

void main() {
  test('another class in the same library reads and writes a private field', () {
    final wallet = Wallet(100)..spend(250);
    const auditor = WalletAuditor();

    expect(auditor.isOverdrawn(wallet), isTrue);
    auditor.writeOff(wallet);
    expect(wallet.balanceCents, 0);
    expect(auditor.isOverdrawn(wallet), isFalse);
  });
}

/// Wallet domain: the balance can only change through this library.
///
/// Privacy is per LIBRARY, not per class: [WalletAuditor] below reads and
/// writes `Wallet._balanceCents` directly.
library;

final class Wallet {
  Wallet(this._balanceCents);

  int _balanceCents;

  int get balanceCents => _balanceCents;

  void spend(int cents) => _balanceCents -= cents;
}

final class WalletAuditor {
  const WalletAuditor();

  bool isOverdrawn(Wallet wallet) => wallet._balanceCents < 0;

  void writeOff(Wallet wallet) {
    if (isOverdrawn(wallet)) wallet._balanceCents = 0;
  }
}

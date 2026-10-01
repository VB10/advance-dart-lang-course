// /dartadvance Projemde `_` alanına aynı dosyadaki başka sınıfın eriştiği yerleri bul,
// library gizliliği kuralıyla ayır veya bilerek kabul et, her biri için test yaz.
// Same file = same library: no per-class privacy.
final class Wallet {
  Wallet(this._balanceCents);

  int _balanceCents;

  int get balanceCents => _balanceCents;

  void spend(int cents) => _balanceCents -= cents;
}

// WalletAuditor lives in this file, so it may touch the private field.
final class WalletAuditor {
  const WalletAuditor();

  bool isOverdrawn(Wallet wallet) => wallet._balanceCents < 0; // true

  void writeOff(Wallet wallet) {
    if (isOverdrawn(wallet)) wallet._balanceCents = 0; // balance: 0
  }
}

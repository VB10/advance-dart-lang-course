String formatPrice(int minorUnits) {
  final whole = minorUnits ~/ 100;
  final cents = (minorUnits % 100).toString().padLeft(2, '0');
  return '$whole,$cents ₺';
}

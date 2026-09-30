final recentSearches = <String>['dart'];

const supportedLocales = ['en', 'tr'];

final class Money {
  const Money(this.minorUnits, this.currency);
  final int minorUnits;
  final String currency;
}

const zeroTry = Money(0, 'TRY');

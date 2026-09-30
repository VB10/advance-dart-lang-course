import 'dart:collection';

final class PriceIndex {
  final SplayTreeMap<int, String> _byPrice = SplayTreeMap<int, String>();

  void add(int priceMinor, String productId) => _byPrice[priceMinor] = productId;

  List<int> get pricesAscending => _byPrice.keys.toList();
  String? get cheapest => _byPrice.isEmpty ? null : _byPrice[_byPrice.firstKey()];

  /// The most expensive product strictly cheaper than [budget].
  String? bestUnder(int budget) {
    final key = _byPrice.lastKeyBefore(budget);
    return key == null ? null : _byPrice[key];
  }
}

SplayTreeSet<String> sortedTags(Iterable<String> tags) =>
    SplayTreeSet<String>((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))..addAll(tags);

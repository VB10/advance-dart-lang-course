final class Cart {
  final List<String> items = [];
  String? note;
}

// `?..` runs the cascade only when the cart is not null.
Cart? withNote(Cart? cart, String note) => cart?..note = note;

// `...?` spreads nothing when the list is null.
List<String> allTags(List<String> base, List<String>? extra) => [...base, ...?extra];

int countItems(List<Cart> carts) {
  var count = 0;
  for (final _ in carts) {
    count++;
  }
  return count;
}

// Since Dart 3.7, several `_` parameters can coexist.
void Function(int, String) ignoreBoth = (_, _) {};

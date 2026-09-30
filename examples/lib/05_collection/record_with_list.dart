typedef CartLine = ({String sku, List<String> options});

/// A `List` field inside a record still compares by identity.
bool sameLine(CartLine a, CartLine b) => a == b;

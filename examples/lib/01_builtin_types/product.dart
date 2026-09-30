final class Product {
  const Product({required this.id, required this.name, required this.priceMinor, this.rating});
  final int id;
  final String name;
  final int priceMinor; // Exact amount in kuruş/cents, not a double.
  final double? rating;
}

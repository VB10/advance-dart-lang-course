import 'package:collection/collection.dart';

typedef Product = ({String name, int stock});

// Core (Dart 3.0): no import needed for the OrNull helpers.
Product? cheapest(List<Product> sortedByPrice) => sortedByPrice.firstOrNull;

// Package: the predicate version still lives in package:collection.
Product? firstInStock(List<Product> products) =>
    products.firstWhereOrNull((product) => product.stock > 0);

// Two or more elements gives null, not an error.
Product? onlyProduct(List<Product> products) => products.singleOrNull;

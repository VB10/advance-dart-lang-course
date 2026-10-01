// Düzelt: /dartadvance Projemde `first`/`firstWhere`/`try-catch StateError` ile arama yapan
//    yerleri bul, `firstOrNull`/`firstWhereOrNull` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana siparişlerde bir müşterinin ilk siparişini bulan, yoksa null
//    dönen bir fonksiyon yaz.
import 'package:collection/collection.dart';

typedef Product = ({String name, int stock});

Product naiveFirst(List<Product> products) => products.first; // empty: StateError

Product? cheapest(List<Product> sortedByPrice) => sortedByPrice.firstOrNull; // empty: null

Product naiveInStock(List<Product> products) => products.firstWhere((product) => product.stock > 0);

Product? firstInStock(List<Product> products) =>
    products.firstWhereOrNull((product) => product.stock > 0); // no match: null

Product? onlyProduct(List<Product> products) => products.singleOrNull;

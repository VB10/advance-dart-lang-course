// ============================================================================
// 🎬 YOUTUBE SAHNESİ: "Advance Dart - Bölüm 01 (Alıştırma 3)"
//
// ❌ OLMADIĞI SENARYO (BUG / YANILGI):
//    final rating = json['rating'] as double;
//    Backend'den puan 4.5 gelince çalışan kod, tam puan 4 (int) gelince patlar:
//    "type 'int' is not a subtype of type 'double' in type cast" crash'i gelir!
//    Çünkü Dart'ta (native VM) int, double'ın alt tipi değildir.
//
// 🎯 AMAÇ:
//    JSON sayılarını pattern matching ile `num?` olarak yakalayıp `.toDouble()`
//    ile dönüştürmek ve sonucu Clean Architecture `Result<Product>` içine sarmak.
//
// 🤖 SKILL DEMO PROMPTU:
//    "Bana JSON string'ini güvenle parse eden, rating alanı int veya double
//     gelebilen, hata durumunda UnexpectedFailure ile Result<Product> dönen
//     bir decodeProduct fonksiyonu yaz."
//
// 📁 HEDEF DOSYA & TEST:
//    Dosya: lib/01_builtin_types/practice/ex3_decode_product.dart
//    Test:  dart test test/01_builtin_types/practice/ex3_decode_product_test.dart
// ============================================================================

import 'dart:convert';

import '../../00_architecture/result.dart';
import '../never_helper.dart';
import '../product.dart';

Product? _match(Object? json) => switch (json) {
  {
    'id': int id,
    'name': String name,
    'price_minor': int priceMinor,
    'rating': num? rating,
  } =>
    Product(id: id, name: name, priceMinor: priceMinor, rating: rating?.toDouble()),
  _ => null,
};

Result<Product> decodeProduct(String source) {
  try {
    final product = _match(jsonDecode(source));
    if (product == null) fail('Malformed product: $source');
    return Ok(product);
  } on FormatException catch (error, stackTrace) {
    return Err(UnexpectedFailure(error, stackTrace));
  }
}

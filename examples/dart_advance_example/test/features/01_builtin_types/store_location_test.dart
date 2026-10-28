import 'dart:convert';

import 'package:dart_advance_example/features/01_builtin_types/model/store_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json =
      jsonDecode('{"latitude": 41, "longitude": 29.0}') as Map<String, dynamic>;

  test('as double throws when JSON sends a whole number', () {
    expect(json['latitude'], isA<int>());
    expect(() => StoreLocation.fromJsonWrong(json), throwsA(isA<TypeError>()));
  });

  test('as num then toDouble accepts int and double', () {
    final location = StoreLocation.fromJson(json);
    expect(location.latitude, 41.0);
    expect(location.longitude, 29.0);
  });
}

import 'package:dart_advance_example/features/01_builtin_types/model/pin_address_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a List key never hits: every tap asks the server', () {
    final cache = PinAddressCache();
    for (var i = 0; i < 3; i++) {
      cache.addressWrong(40.99, 29.02);
    }
    expect(cache.requestsWrong, 3);
  });

  test('a record key compares by value: one request', () {
    final cache = PinAddressCache();
    for (var i = 0; i < 3; i++) {
      cache.address(40.99, 29.02);
    }
    expect(cache.requests, 1);
  });
}

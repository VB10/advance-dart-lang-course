import 'package:dartadvance_examples/05_collection/canonicalized_map.dart';
import 'package:test/test.dart';

void main() {
  test('CanonicalizedMap keeps one entry per canonical key and the last key written', () {
    final map = headers()
      ..['Content-Type'] = 'text/plain'
      ..['content-type'] = 'application/json';
    expect(map.length, 1);
    expect(map['CONTENT-TYPE'], 'application/json');
    expect(map.keys, ['content-type']);
  });
}

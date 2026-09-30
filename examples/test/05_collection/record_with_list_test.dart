import 'package:dartadvance_examples/05_collection/record_with_list.dart';
import 'package:test/test.dart';

void main() {
  test('records compare structurally, but a List field compares by identity', () {
    final options = ['red'];
    expect(sameLine((sku: 'a', options: options), (sku: 'a', options: options)), isTrue);
    expect(sameLine((sku: 'a', options: ['red']), (sku: 'a', options: ['red'])), isFalse);
    expect((a: 1, b: 2) == (b: 2, a: 1), isTrue);
    expect(const (a: [1]) == const (a: [1]), isTrue); // const lists are canonicalized
  });
}

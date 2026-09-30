import 'package:dartadvance_examples/02_typedefs/compare_function.dart';
import 'package:dartadvance_examples/02_typedefs/int_list.dart';
import 'package:dartadvance_examples/02_typedefs/list_mapper.dart';
import 'package:test/test.dart';

void main() {
  test('an alias denotes the very same type', () {
    expect(IntList, List<int>);
    expect(il, isA<List<int>>());
    expect(m2, isA<Map<String, List<String>>>());
  });

  test('a function is an instance of a matching function typedef', () {
    expect(sort, isA<Compare<int>>());
    expect(sort(3, 1), 2);
  });
}

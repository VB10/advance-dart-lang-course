import 'package:dart_advance_example/features/02_typedefs/model/invoice_lines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rows = <Json>[
    {'price': 4},
    {'price': 12.5},
  ];

  test('Json is the same type as Map<String, Object?>', () {
    expect(Json, Map<String, Object?>);
  });

  test('as double throws on int, as num reads both', () {
    final lines = InvoiceLines();
    expect(() => lines.totalWrong(rows), throwsA(isA<TypeError>()));
    expect(lines.total(rows), 16.5);
  });
}

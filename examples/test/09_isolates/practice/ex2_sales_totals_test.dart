import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/09_isolates/practice/ex2_sales_domain.dart';
import 'package:dartadvance_examples/09_isolates/practice/ex2_sales_repository_impl.dart';
import 'package:dartadvance_examples/09_isolates/practice/ex2_sum_by_category.dart';
import 'package:test/test.dart';

final class _FakeSalesRemote implements SalesRemoteDataSource {
  const _FakeSalesRemote(this.csv);
  final String csv;

  @override
  Future<String> fetchCsv() async => csv;
}

void main() {
  test('totals are computed on another isolate and returned as Ok', () async {
    const csv = 'books, 10\ntoys,5.5\n\nbooks,2.5\n';
    final result = await const LoadSalesTotals(SalesRepositoryImpl(_FakeSalesRemote(csv)))();
    expect(result, isA<Ok<Map<String, double>>>());
    expect((result as Ok<Map<String, double>>).value, {'books': 12.5, 'toys': 5.5});
  });

  test('a FormatException in the isolate becomes Err(UnexpectedFailure)', () async {
    final result = await const LoadSalesTotals(SalesRepositoryImpl(_FakeSalesRemote('books;10')))();
    expect(
      result,
      isA<Err<Map<String, double>>>().having(
        (err) => err.failure,
        'failure',
        isA<UnexpectedFailure>().having((failure) => failure.error, 'error', isFormatException),
      ),
    );
    expect(sumByCategory(''), isEmpty);
  });
}

import 'dart:isolate';

import '../../00_architecture/result.dart';
import 'ex2_sales_domain.dart';
import 'ex2_sum_by_category.dart';

abstract interface class SalesRemoteDataSource {
  Future<String> fetchCsv();
}

/// Captures only [csv]: the repository is never copied into the isolate.
Future<Map<String, double>> _sumInBackground(String csv) =>
    Isolate.run(() => sumByCategory(csv), debugName: 'sumByCategory');

final class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remote);
  final SalesRemoteDataSource _remote;

  @override
  Future<Result<Map<String, double>>> totalsByCategory() async {
    try {
      final csv = await _remote.fetchCsv();
      return Ok(await _sumInBackground(csv));
    } catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

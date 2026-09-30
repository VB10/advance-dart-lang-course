import '../../00_architecture/result.dart';

abstract interface class SalesRepository {
  Future<Result<Map<String, double>>> totalsByCategory();
}

final class LoadSalesTotals {
  const LoadSalesTotals(this._repository);
  final SalesRepository _repository;

  Future<Result<Map<String, double>>> call() => _repository.totalsByCategory();
}

typedef Json = Map<String, Object?>;

final class ServerException implements Exception {
  const ServerException(this.statusCode);
  final int statusCode;
}

abstract interface class UserRemoteDataSource {
  /// Throws [ServerException] on a non-2xx response.
  Future<Json> fetchUser(int id);
}

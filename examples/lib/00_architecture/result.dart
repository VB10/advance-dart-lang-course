// #docregion result
/// Outcome of an operation that can fail with a domain [Failure].
///
/// `sealed` makes `switch` over a `Result` exhaustive: the compiler rejects a
/// switch that forgets `Err`.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
// #enddocregion result

// #docregion failure
/// Every failure the domain layer knows about. New subtypes must be handled
/// by every exhaustive `switch` — that is the point of `sealed`.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('No connection');
}

final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode) : super('Server error');
  final int statusCode;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error, this.stackTrace) : super('Unexpected error');
  final Object error;
  final StackTrace stackTrace;
}
// #enddocregion failure

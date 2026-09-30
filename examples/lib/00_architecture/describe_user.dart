import 'result.dart';
import 'user.dart';

String describe(Result<User> result) => switch (result) {
  Ok(value: User(:final name)) => 'Hello, $name',
  Err(failure: ServerFailure(:final statusCode)) => 'Server said $statusCode',
  Err(:final failure) => failure.message,
};

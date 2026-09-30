import 'package:async/async.dart' hide Result;
import 'package:async/async.dart' as async_pkg show Result;

import '../00_architecture/result.dart';

Result<T> toDomain<T>(async_pkg.Result<T> captured) => switch (captured) {
  ValueResult<T>(:final value) => Ok(value),
  ErrorResult(:final error, :final stackTrace) => Err(UnexpectedFailure(error, stackTrace)),
  // package:async's Result is not sealed, so a fallback arm is required.
  _ => throw StateError('Unknown Result implementation: $captured'),
};

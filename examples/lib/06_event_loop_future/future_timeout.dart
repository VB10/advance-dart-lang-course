import 'dart:async';

/// Fails with a [TimeoutException] when [limit] passes first.
Future<String> fetchOrThrow(Future<String> request, Duration limit) => request.timeout(limit);

/// The source future is not cancelled; its late result is ignored.
Future<String> fetchOrCached(Future<String> request, Duration limit) =>
    request.timeout(limit, onTimeout: () => 'cached');

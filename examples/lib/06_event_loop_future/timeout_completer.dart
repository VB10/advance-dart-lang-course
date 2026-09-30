import 'dart:async';

abstract interface class LegacyLocationClient {
  void requestCity(void Function(String? city, Object? error) onDone);
}

/// Wraps a callback API into a Future; a Completer completes only once.
Future<String> currentCity(LegacyLocationClient client) {
  final completer = Completer<String>();
  client.requestCity((city, error) {
    if (completer.isCompleted) return;
    if (error != null) return completer.completeError(error);
    completer.complete(city ?? 'unknown');
  });
  return completer.future;
}

/// Throws [TimeoutException] when [limit] passes first.
Future<String> cityOrThrow(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit);

/// The source future is not cancelled; its late result is ignored.
Future<String> cityOrDefault(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit, onTimeout: () => 'Istanbul');

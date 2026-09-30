import 'dart:async';

abstract interface class LegacyLocationClient {
  void requestCity(void Function(String? city, Object? error) onDone);
}

Future<String> currentCity(LegacyLocationClient client) {
  final completer = Completer<String>();
  client.requestCity((city, error) {
    if (completer.isCompleted) return;
    if (error != null) return completer.completeError(error);
    completer.complete(city ?? 'unknown');
  });
  return completer.future;
}

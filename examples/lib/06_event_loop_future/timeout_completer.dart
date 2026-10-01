// Skill'e ver: "Projemde callback tabanlı eski API'leri, süresiz bekleyen çağrıları bul,
// `Completer` ile Future'a çevir, `timeout` ile sınırla, her biri için test yaz."
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

/// No limit: a silent client leaves the caller waiting forever.
Future<String> cityForever(LegacyLocationClient client) => currentCity(client); // pending

Future<String> cityOrThrow(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit); // silent client: TimeoutException

Future<String> cityOrDefault(LegacyLocationClient client, Duration limit) =>
    currentCity(client).timeout(limit, onTimeout: () => 'Istanbul'); // silent: Istanbul

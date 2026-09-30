import 'dart:async';

final class AnalyticsClient {
  Future<void> send(String event) async => throw StateError('offline: $event');
}

/// unawaited only silences the lint; a failure is still an unhandled error.
void trackScreenOpenedLoud(AnalyticsClient analytics) {
  unawaited(analytics.send('screen_opened'));
}

/// ignore() also marks the error as handled, so nothing is reported.
void trackScreenOpenedQuiet(AnalyticsClient analytics) {
  analytics.send('screen_opened').ignore();
}

/// Safest: handle the failure yourself, then fire and forget.
void trackScreenOpenedSafe(AnalyticsClient analytics, void Function(Object) report) {
  unawaited(analytics.send('screen_opened').catchError(report));
}

import 'dart:async';

import '../../00_architecture/result.dart';

sealed class ScanEvent {
  const ScanEvent();
}

final class ScanFound extends ScanEvent {
  const ScanFound(this.code);
  final String code;
}

final class ScanFailed extends ScanEvent {
  const ScanFailed(this.error);
  final Object error;
}

final class ScanCancelled extends ScanEvent {
  const ScanCancelled();
}

/// A callback SDK that may fire its callback more than once.
abstract interface class BarcodeScanner {
  void start(void Function(ScanEvent event) onEvent);
}

/// The first event wins; a timeout counts as a cancel.
Future<Result<String?>> scanOnce(
  BarcodeScanner scanner, {
  Duration timeLimit = const Duration(seconds: 30),
}) async {
  final completer = Completer<ScanEvent>();
  scanner.start((event) {
    if (!completer.isCompleted) completer.complete(event);
  });
  final event = await completer.future.timeout(
    timeLimit,
    onTimeout: () => const ScanCancelled(),
  );
  return switch (event) {
    ScanFound(:final code) => Ok(code),
    ScanCancelled() => const Ok(null),
    ScanFailed(:final error) => Err(UnexpectedFailure(error, StackTrace.current)),
  };
}

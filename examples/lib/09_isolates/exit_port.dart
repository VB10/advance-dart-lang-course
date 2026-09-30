import 'dart:async';
import 'dart:isolate';

/// Pass its `sendPort` as `onExit`; [exited] completes when the isolate ends.
RawReceivePort exitPort(Completer<void> exited) {
  final port = RawReceivePort();
  port.handler = (Object? _) {
    port.close();
    exited.complete();
  };
  return port;
}

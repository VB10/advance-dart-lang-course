import 'dart:isolate';

Future<int> captureUnsendable() async {
  final port = ReceivePort();
  try {
    // The closure captures a ReceivePort, which cannot be sent: this fails.
    return await Isolate.run(() => port.hashCode);
  } finally {
    port.close();
  }
}

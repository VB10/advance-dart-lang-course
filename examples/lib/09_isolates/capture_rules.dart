import 'dart:isolate';

int loadedOrderCount = 0;

/// The list is copied into the isolate: the caller's list stays unsorted.
Future<List<int>> sortedTotals(List<int> totals) => Isolate.run(() => totals..sort());

/// A global is a separate variable inside the new isolate.
Future<int> countInIsolate() => Isolate.run(() => ++loadedOrderCount);

Future<int> captureReceivePort() async {
  final port = ReceivePort();
  try {
    // The closure captures a ReceivePort, which cannot be sent: this fails.
    return await Isolate.run(() => port.hashCode);
  } finally {
    port.close();
  }
}
